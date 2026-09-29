/**
 * TenderService handlers (blueprint §5): the carrier desk quotes or declines an open
 * invitation on behalf of the carrier.
 *
 * - Both actions lock the offer's dispatch first (the same row DispatchService's award
 *   locks), then read offer and round, so a quote cannot interleave with an award.
 * - award-rules.js decides; violations go to req.error. Only the quote fields and the
 *   offer status change, never the dispatch or the award fields.
 */
import cds from '@sap/cds'
import * as rules from './lib/award-rules.js'

const { SELECT, UPDATE } = cds.ql

const DB = {
  Dispatch: 'tm.dispatch.FreightOrderDispatch',
  Rounds: 'tm.dispatch.TenderRounds',
  Offers: 'tm.dispatch.CarrierOffers',
}

/** The value of a single key, whether CAP passes it as the value or as `{ key: value }`. */
const keyValue = (param, name) => (param && typeof param === 'object' ? param[name] : param)

/** Reports a failed award-rules check; returns true when the check passed. */
const passes = (req, check) => {
  if (check.ok) return true
  req.error({ status: 400, code: check.code, message: check.message })
  return false
}

export default class TenderService extends cds.ApplicationService {
  init() {
    const { OpenInvitations } = this.entities
    this.on('submitQuote', OpenInvitations, req => this.onSubmitQuote(req))
    this.on('decline', OpenInvitations, req => this.onDecline(req))
    return super.init()
  }

  /** Offer and round, read after locking their dispatch for the rest of the transaction. */
  async lockOffer(req) {
    const ID = keyValue(req.params.at(-1), 'ID')
    const found = await SELECT.one.from(DB.Offers).columns('parent.parent_ID as dispatchId').where({ ID })
    if (!found) return req.reject(404, 'Invitation not found')
    await SELECT.one.from(DB.Dispatch).columns('ID').where({ ID: found.dispatchId }).forUpdate()
    const offer = await SELECT.one.from(DB.Offers).where({ ID })
    const round = await SELECT.one.from(DB.Rounds).where({ ID: offer.parent_ID })
    return { ID, offer, round }
  }

  async onSubmitQuote(req) {
    const { ID, offer, round } = await this.lockOffer(req)
    const { price, transitHours, comment } = req.data
    const currency = req.data.currency?.trim().toUpperCase()
    const now = new Date()
    if (!passes(req, rules.canSubmitQuote({ offer: { ...offer, price, transitHours }, round, now }))) return
    if (!/^[A-Z]{3}$/.test(currency ?? ''))
      return req.error({ status: 400, code: 'INVALID_CURRENCY', message: `Not a currency code: '${req.data.currency}'` })

    await UPDATE(DB.Offers, ID).set({
      status_code: 'QUOTED',
      price,
      currency_code: currency,
      transitHours,
      comment: comment ?? null,
      respondedAt: now.toISOString(),
    })
  }

  async onDecline(req) {
    const { ID, offer, round } = await this.lockOffer(req)
    if (!passes(req, rules.canDecline({ offer, round }))) return
    await UPDATE(DB.Offers, ID).set({
      status_code: 'DECLINED',
      comment: req.data.comment ?? null,
      respondedAt: new Date().toISOString(),
    })
  }
}
