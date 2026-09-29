/**
 * TenderService handlers (blueprint §5, development plan phase 3): the carrier desk
 * quotes or declines an open invitation on behalf of the carrier.
 *
 * - Reads add the freight order context (lane, dates) from TM with one call per page,
 *   and the countdown (deadlineCriticality, timeLeft) evaluated against `now`. If TM
 *   cannot be reached the invitations are still served, without the context.
 * - A read by key falls back to the offer itself when it is no longer open, so the
 *   object page shows the new status after Submit Quote or Decline instead of a 404.
 * - Both actions lock the offer's dispatch first (the same row DispatchService's award
 *   locks), then read offer and round, so a quote cannot interleave with an award.
 * - award-rules.js decides; violations go to req.error. Only the quote fields and the
 *   offer status change, never the dispatch or the award fields.
 */
import cds from '@sap/cds'
import * as rules from './lib/award-rules.js'
import * as tm from './lib/tm-client.js'

const { SELECT, UPDATE } = cds.ql
const LOG = cds.log('tender')

const DB = {
  Dispatch: 'tm.dispatch.FreightOrderDispatch',
  Rounds: 'tm.dispatch.TenderRounds',
  Offers: 'tm.dispatch.CarrierOffers',
}

/** OpenInvitations' columns, read from CarrierOffers directly (key read of an answered offer). */
const INVITATION_COLUMNS = [
  'ID',
  'parent.parent.freightOrderId as freightOrderId',
  'parent.roundNumber as roundNumber',
  'parent.mode.code as tenderMode',
  'parent.mode.name as tenderModeName',
  'parent.deadline as deadline',
  'carrierId',
  'carrierName',
  'status.code as status',
  'status.name as statusName',
  'status.criticality as statusCriticality',
]

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
    this.on('READ', OpenInvitations, (req, next) => this.onReadInvitations(req, next))
    this.after('READ', OpenInvitations, rows => this.addContext(rows))
    this.on('submitQuote', OpenInvitations, req => this.onSubmitQuote(req))
    this.on('decline', OpenInvitations, req => this.onDecline(req))
    return super.init()
  }

  async onReadInvitations(req, next) {
    // the context and the countdown are derived from these, whatever $select asked for
    const { columns } = req.query.SELECT
    if (columns && !columns.some(c => c === '*')) {
      for (const name of ['freightOrderId', 'deadline'])
        if (!columns.some(c => c.ref?.[0] === name && !c.as)) columns.push({ ref: [name] })
    }
    const result = await next()
    if (!req.params.length || result) return result
    // not open any more: the offer as it is now, for the object page
    const ID = keyValue(req.params.at(-1), 'ID')
    const offer = await SELECT.one.from(DB.Offers).columns(INVITATION_COLUMNS).where({ ID })
    if (!offer) return req.reject(404, 'Invitation not found')
    return { ...offer, canRespond: offer.status === 'INVITED' }
  }

  /** Lane and dates from TM (one call for the page) and the deadline countdown. */
  async addContext(result) {
    const rows = [result ?? []].flat().filter(Boolean)
    if (!rows.length) return
    const now = new Date()
    let orders = new Map()
    try {
      orders = await tm.readFreightOrderContexts(rows.map(r => r.freightOrderId))
    } catch (e) {
      LOG.warn('Freight order context not available from TM:', e.message)
    }
    for (const r of rows) {
      Object.assign(r, tm.laneOf(orders.get(r.freightOrderId)?._FreightOrderStop))
      if (r.deadline !== undefined) {
        r.deadlineCriticality = rules.deadlineCriticality(r.deadline, now)
        r.timeLeft = rules.timeLeft(r.deadline, now)
      }
    }
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
