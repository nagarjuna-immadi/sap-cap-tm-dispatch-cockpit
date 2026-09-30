/**
 * TenderAgentService handlers (blueprint §13, development plan 6.3).
 *
 * The service is the tool surface of the tender agent and of its MCP server. It holds no
 * rules of its own: functions and actions delegate to TenderService in the caller's
 * cds.context, so the user and roles carry over and award-rules.js stays the only place
 * where a quote or a decline is checked.
 *
 * - Invitations are read from TenderService.OpenInvitations, which adds lane and dates
 *   from TM and the countdown. carrierId and offerId filter the local offers only.
 * - invitationDetails reads by key, which TenderService also answers for an invitation
 *   that is no longer open. The carrier's own answer (price, transit time, comment) comes
 *   from the offer itself: OpenInvitations has no price, and no other offer is read.
 */
import cds from '@sap/cds'
import * as rules from '../../lib/award-rules.js'
import { resolveMessages } from '../../lib/agent-errors.js'

const { SELECT } = cds.ql

const DB = {
  Offers: 'tm.dispatch.CarrierOffers',
  Carriers: 'tm.dispatch.Carriers',
}

/** The fixed invitation context the agent gets: offer, carrier, freight order, deadline. */
const compact = (r, now) => ({
  offerId: r.ID,
  freightOrderId: r.freightOrderId,
  carrierId: r.carrierId,
  carrierName: r.carrierName,
  roundNumber: r.roundNumber,
  mode: r.tenderMode,
  deadline: r.deadline,
  timeLeft: r.timeLeft ?? rules.timeLeft(r.deadline, now),
  lessThan24hLeft: rules.deadlineCriticality(r.deadline, now) === 2,
  sourceLocation: r.sourceLocation ?? null,
  destinationLocation: r.destinationLocation ?? null,
  pickupDateTime: r.pickupDateTime ?? null,
  deliveryDateTime: r.deliveryDateTime ?? null,
})

export default class TenderAgentService extends cds.ApplicationService {
  async init() {
    this.tenderService = await cds.connect.to('TenderService')

    this.on('openInvitations', req => this.onOpenInvitations(req))
    this.on('invitationDetails', req => this.detailsOf(req, this.offerIdOf(req)))

    this.on('submitQuote', req => this.onSubmitQuote(req))
    this.on('decline', req => this.onDecline(req))

    // validation errors carry only a code; MCP and A2A need the text (agent-errors.js)
    this.on('error', resolveMessages)

    return super.init()
  }

  // --- functions --------------------------------------------------------------------

  async onOpenInvitations(req) {
    const carrierId = req.data.carrierId?.trim()
    if (carrierId && !await SELECT.one.from(DB.Carriers).columns('carrierId').where({ carrierId }))
      return req.reject(404, `Unknown carrier ID '${carrierId}'`)

    const { OpenInvitations } = this.tenderService.entities
    const query = SELECT.from(OpenInvitations).orderBy('deadline', 'freightOrderId', 'carrierName')
    if (carrierId) query.where({ carrierId })
    const rows = await this.tenderService.run(query)

    const now = new Date()
    return { total: rows.length, invitations: rows.map(r => compact(r, now)) }
  }

  /** One invitation with the carrier's own answer; also the result of both actions. */
  async detailsOf(req, offerId) {
    const { OpenInvitations } = this.tenderService.entities
    // by key: TenderService falls back to the offer when it is no longer open. The key goes
    // in params too, because a query from code leaves req.params empty (plan 6.2).
    const query = SELECT.one.from(OpenInvitations, offerId)
    const invitation = await this.tenderService.send({ query, params: [{ ID: offerId }] })
    if (!invitation) return req.reject(404, `Invitation ${offerId} not found`)
    const answer = await SELECT.one.from(DB.Offers)
      .columns('status_code as status', 'price', 'currency_code as currency', 'transitHours', 'comment', 'respondedAt')
      .where({ ID: offerId })

    const now = new Date()
    const status = rules.effectiveOfferStatus(answer, invitation, now)
    const canRespond = status === 'INVITED'
    return {
      ...compact(invitation, now),
      // the countdown is the time left to quote, so none once that is over
      ...!canRespond && { timeLeft: null, lessThan24hLeft: false },
      ...answer,
      status,
      canRespond,
    }
  }

  // --- actions ----------------------------------------------------------------------
  // All rules are checked by TenderService; a violation comes back as its error.

  async onSubmitQuote(req) {
    const offerId = this.offerIdOf(req)
    const { price, currency, transitHours, comment } = req.data
    await this.bound('submitQuote', offerId, { price, currency, transitHours, comment })
    return this.detailsOf(req, offerId)
  }

  async onDecline(req) {
    const offerId = this.offerIdOf(req)
    await this.bound('decline', offerId, { comment: req.data.comment })
    return this.detailsOf(req, offerId)
  }

  // --- helpers ----------------------------------------------------------------------

  /** Calls an action that TenderService binds to OpenInvitations, as the caller. */
  bound(event, offerId, data) {
    const target = this.tenderService.entities.OpenInvitations
    return this.tenderService.send({ event, target, params: [{ ID: offerId }], data })
  }

  /** The offer ID parameter, trimmed; rejects an empty one. */
  offerIdOf(req) {
    const id = String(req.data.offerId ?? '').trim()
    if (!id) return req.reject(400, 'An offer ID is required')
    return id
  }
}
