/**
 * Tender and award rules (blueprint §5, development plan 1.2).
 *
 * Pure functions: no CDS imports, no I/O. Callers pass plain objects as read from the
 * DB (`dispatchStatus_code`, `status_code`, `mode_code`) or with the association
 * expanded (`dispatchStatus: { code }`), plus a `now` value. Timestamps may be Date
 * objects, ISO strings (UTC) or epoch milliseconds.
 *
 * Every can* function returns `{ ok: true }` or `{ ok: false, code, message }`, so the
 * service can pass a violation straight to `req.error(400, message)`.
 */

const OK = Object.freeze({ ok: true })
const fail = (code, message) => ({ ok: false, code, message })

// --- helpers ------------------------------------------------------------------------

/** Epoch millis for a Date, ISO string or number; NaN when missing or unparsable. */
const toMillis = t => {
  if (t === null || t === undefined || t === '') return NaN
  if (t instanceof Date) return t.getTime()
  if (typeof t === 'number') return t
  return new Date(t).getTime()
}

/** Reads a code-list value from `<name>_code`, `<name>.code` or `<name>` itself. */
const codeOf = (obj, name) => {
  if (!obj) return undefined
  const flat = obj[`${name}_code`]
  if (flat !== undefined && flat !== null) return flat
  const v = obj[name]
  return v && typeof v === 'object' ? v.code : v ?? undefined
}

const dispatchStatus = d => codeOf(d, 'dispatchStatus') ?? 'NEW'   // a missing dispatch reads as NEW
const offerStatus = o => codeOf(o, 'status')
const roundMode = r => codeOf(r, 'mode')
const isOpen = r => !!r && !r.closed

// --- deadline -----------------------------------------------------------------------

/** A deadline has expired once `now` reaches it (`now >= deadline`). No deadline never expires. */
export function isExpired (deadline, now) {
  const d = toMillis(deadline)
  if (Number.isNaN(d)) return false
  return toMillis(now) >= d
}

/** The offer status as it should be shown: an INVITED offer past the round deadline reads as EXPIRED. */
export function effectiveOfferStatus (offer, round, now) {
  const status = offerStatus(offer)
  if (status === 'INVITED' && isExpired(round?.deadline, now)) return 'EXPIRED'
  return status
}

/** Number for the next round: highest existing `roundNumber` + 1, or 1 when there are none. */
export function nextRoundNumber (rounds) {
  const numbers = (rounds ?? []).map(r => Number(r?.roundNumber)).filter(Number.isFinite)
  return numbers.length ? Math.max(...numbers) + 1 : 1
}

// --- rules --------------------------------------------------------------------------

/**
 * Start a new tender round on a dispatch.
 * @param {object} dispatch  FreightOrderDispatch, with `rounds` if any exist
 * @param {{ carriers: string[], deadline: any, now: any }} args
 */
export function canStartTender (dispatch, { carriers, deadline, now } = {}) {
  const status = dispatchStatus(dispatch)
  if (status !== 'NEW' && status !== 'TENDERING')
    return fail('INVALID_DISPATCH_STATUS', `A tender cannot be started while the dispatch is ${status}`)

  if ((dispatch?.rounds ?? []).some(isOpen))
    return fail('ROUND_ALREADY_OPEN', 'Close the open tender round before starting a new one')

  const d = toMillis(deadline)
  if (Number.isNaN(d))
    return fail('DEADLINE_MISSING', 'A quote deadline is required')
  if (d <= toMillis(now))
    return fail('DEADLINE_NOT_IN_FUTURE', 'The quote deadline must be in the future')

  if (!Array.isArray(carriers) || carriers.length === 0)
    return fail('NO_CARRIERS', 'Select at least one carrier')
  if (carriers.some(c => typeof c !== 'string' || c.trim() === ''))
    return fail('INVALID_CARRIER', 'Every carrier must have an ID')
  const ids = carriers.map(c => c.trim())
  const duplicates = [...new Set(ids.filter((c, i) => ids.indexOf(c) !== i))]
  if (duplicates.length)
    return fail('DUPLICATE_CARRIERS', `Carriers are selected more than once: ${duplicates.join(', ')}`)

  return OK
}

/** Award an offer: it must be QUOTED, its round open, the dispatch not yet AWARDED, and a BROADCAST deadline passed. */
export function canAward ({ dispatch, round, offer, now } = {}) {
  if (!offer) return fail('OFFER_NOT_FOUND', 'Offer not found')
  if (!round) return fail('ROUND_NOT_FOUND', 'Tender round not found')

  if (offerStatus(offer) !== 'QUOTED')
    return fail('OFFER_NOT_QUOTED', 'Only a quoted offer can be awarded')
  if (!isOpen(round))
    return fail('ROUND_CLOSED', 'The tender round is already closed')
  if (dispatchStatus(dispatch) === 'AWARDED')
    return fail('ALREADY_AWARDED', 'The freight order has already been awarded')
  if (roundMode(round) === 'BROADCAST' && !isExpired(round.deadline, now))
    return fail('DEADLINE_NOT_PASSED', 'In a broadcast round, award only after the quote deadline has passed')

  return OK
}

/**
 * Submit a quote on an invitation. `offer` carries the price and transit hours
 * being submitted (the draft values merged onto the offer).
 */
export function canSubmitQuote ({ offer, round, now } = {}) {
  if (!offer) return fail('OFFER_NOT_FOUND', 'Offer not found')
  if (!round) return fail('ROUND_NOT_FOUND', 'Tender round not found')

  if (offerStatus(offer) !== 'INVITED')
    return fail('OFFER_NOT_INVITED', 'Only an open invitation can be quoted')
  if (!isOpen(round))
    return fail('ROUND_CLOSED', 'The tender round is already closed')
  if (isExpired(round.deadline, now))
    return fail('DEADLINE_PASSED', 'The quote deadline has passed')

  const price = Number(offer.price)
  if (offer.price === null || offer.price === undefined || !(price > 0))
    return fail('INVALID_PRICE', 'The price must be greater than 0')
  const hours = Number(offer.transitHours)
  if (offer.transitHours === null || offer.transitHours === undefined || !(hours > 0))
    return fail('INVALID_TRANSIT_HOURS', 'The transit time must be greater than 0 hours')

  return OK
}

/** Decline an invitation: it must be INVITED and its round open. The deadline does not matter. */
export function canDecline ({ offer, round } = {}) {
  if (!offer) return fail('OFFER_NOT_FOUND', 'Offer not found')
  if (!round) return fail('ROUND_NOT_FOUND', 'Tender round not found')

  if (offerStatus(offer) !== 'INVITED')
    return fail('OFFER_NOT_INVITED', 'Only an open invitation can be declined')
  if (!isOpen(round))
    return fail('ROUND_CLOSED', 'The tender round is already closed')

  return OK
}

/** Close a round: it must exist and still be open. */
export function canCloseRound (round) {
  if (!round) return fail('ROUND_NOT_FOUND', 'There is no tender round to close')
  if (!isOpen(round)) return fail('ROUND_CLOSED', 'The tender round is already closed')
  return OK
}

/** Cancel a tender: allowed from any status (→ FAILED), but the reason is mandatory. */
export function canCancel (dispatch, reason) {
  if (!dispatch) return fail('DISPATCH_NOT_FOUND', 'Dispatch not found')
  if (typeof reason !== 'string' || reason.trim() === '')
    return fail('REASON_REQUIRED', 'A reason is required to cancel the tender')
  return OK
}
