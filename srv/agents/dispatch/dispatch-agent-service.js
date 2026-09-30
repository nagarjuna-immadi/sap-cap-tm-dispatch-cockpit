/**
 * DispatchAgentService handlers (blueprint §13, development plan 6.2).
 *
 * The service is the tool surface of the dispatch agent and of its MCP server. It holds
 * no rules of its own: functions and actions delegate to DispatchService in the caller's
 * cds.context, so the user and roles carry over and award-rules.js stays the only place
 * where a tender or an award is checked.
 *
 * - Freight orders and freight units come from TM through DispatchService, which keeps
 *   its explicit $select. No function parameter reaches the TM $filter: the status is
 *   checked against the code list and resolved locally (local-filter.js), the lane is
 *   matched here on the rows TM returned, and the freight order ID is a plain key value.
 * - Rounds and offers are read from this service's own projections, so the functions
 *   show the same values as the query tool (offer status with expiry applied).
 * - The functions only read. freightOrderSummary uses the list read with a key filter,
 *   not the single read, which would create the dispatch of a freight order.
 */
import cds from '@sap/cds'
import { cached } from '../../lib/cache.js'
import * as rules from '../../lib/award-rules.js'

const { SELECT } = cds.ql

const DISPATCH_STATUS = 'tm.dispatch.DispatchStatus'

const DEFAULT_TOP = 20
const MAX_TOP = 50
/** Freight orders read from TM when a lane filter has to be applied in memory. */
const LANE_SCAN_LIMIT = 500

/** Offer statuses that carry a submitted price (see enrich.js). */
const QUOTED_STATUSES = ['QUOTED', 'WON', 'LOST']

const OFFER_COLUMNS = [
  { ref: ['ID'], as: 'offerId' },
  ...['carrierId', 'carrierName', 'status', 'price', 'currency', 'transitHours', 'respondedAt', 'comment']
    .map(name => ({ ref: [name] })),
]

const ROUND_COLUMNS = [
  ...['roundNumber', 'mode', 'deadline', 'closed', 'deadlineExpired'].map(name => ({ ref: [name] })),
  { ref: ['offers'], expand: OFFER_COLUMNS, orderBy: [{ ref: ['carrierName'] }] },
]

// --- helpers ------------------------------------------------------------------------

const statusCodes = () => cached(`${DISPATCH_STATUS}#codes`, async () =>
  (await SELECT.from(DISPATCH_STATUS).columns('code')).map(c => c.code))

const contains = (value, part) => !part || (value ?? '').toUpperCase().includes(part)

/**
 * A row predicate for a lane filter, or null without one. 'A -> B' matches source and
 * destination, 'A ->' / '-> B' one end, and a single term either end; by substring of
 * the location ID, ignoring case. Undefined when the text is not a lane.
 */
const laneMatcher = lane => {
  const text = lane?.trim().toUpperCase()
  if (!text) return null
  const parts = text.split(/\s*(?:->|→|>)\s*/)
  if (parts.length > 2) return undefined
  if (parts.length === 1) return r => contains(r.sourceLocation, text) || contains(r.destinationLocation, text)
  const [from, to] = parts
  return r => contains(r.sourceLocation, from) && contains(r.destinationLocation, to)
}

/** The fixed freight order context the agent gets: ID, lane, dates and tender state. */
const compact = r => ({
  freightOrderId: r.TransportationOrder,
  sourceLocation: r.sourceLocation,
  destinationLocation: r.destinationLocation,
  pickupDateTime: r.pickupDateTime,
  deliveryDateTime: r.deliveryDateTime,
  dispatchStatus: r.dispatchStatus,
  bestQuote: r.bestQuote,
  bestQuoteCurrency: r.bestQuoteCurrency,
  quoteCount: r.quoteCount,
  quoteDeadline: r.quoteDeadline,
  deadlineExpired: r.deadlineExpired,
})

const hasQuote = o => QUOTED_STATUSES.includes(o.status) && o.price !== null && o.price !== undefined

/** Cheapest first, then shortest transit; the carrier name keeps the order stable. */
const byPriceAndTransit = (a, b) =>
  Number(a.price) - Number(b.price)
  || (a.transitHours ?? Infinity) - (b.transitHours ?? Infinity)
  || (a.carrierName ?? '').localeCompare(b.carrierName ?? '')

export default class DispatchAgentService extends cds.ApplicationService {
  async init() {
    // not `this.dispatch`: that is the method every service dispatches its requests with
    this.dispatchService = await cds.connect.to('DispatchService')

    this.on('openFreightOrders', req => this.onOpenFreightOrders(req))
    this.on('freightOrderSummary', req => this.onFreightOrderSummary(req))
    this.on('compareOffers', req => this.onCompareOffers(req))

    this.on('startTender', req => this.onStartTender(req))
    this.on('cancelTender', req => this.onCancelTender(req))
    this.on('closeRound', req => this.onCloseRound(req))
    this.on('award', req => this.onAward(req))
    this.on('reportException', req => this.onReportException(req))

    // Input validation errors (@mandatory, wrong type) carry only a code; CAP adds their
    // text in the OData error response. MCP and A2A report err.message, so resolve it
    // here, with the parameter, or the LLM gets "undefined" and cannot correct the call.
    this.on('error', err => {
      for (const e of [err, ...(err.details ?? [])]) {
        if (e.message || !e.code) continue
        const locale = cds.context?.locale || cds.i18n.default_language
        const text = cds.i18n.messages.at(e.code, locale, e.args) ?? e.code
        e.message = e.target ? `${text} (${e.target})` : text
      }
    })

    return super.init()
  }

  // --- functions --------------------------------------------------------------------

  async onOpenFreightOrders(req) {
    const matchesLane = laneMatcher(req.data.lane)
    if (matchesLane === undefined)
      return req.reject(400, "Give the lane as 'SOURCE -> DESTINATION', as one end ('SOURCE ->', '-> DESTINATION') or as a single location")

    const status = req.data.status?.trim().toUpperCase()
    const codes = await statusCodes()
    if (status && !codes.includes(status))
      return req.reject(400, `Unknown dispatch status '${req.data.status}'; use one of ${codes.join(', ')}`)

    const top = Math.min(Math.max(Math.trunc(Number(req.data.top)) || DEFAULT_TOP, 1), MAX_TOP)

    const { FreightOrders } = this.dispatchService.entities
    const query = SELECT.from(FreightOrders).orderBy('TransportationOrder').limit(matchesLane ? LANE_SCAN_LIMIT : top)
    if (status) query.where({ dispatchStatus: status })
    query.SELECT.count = true
    const rows = await this.dispatchService.run(query)

    const matching = matchesLane ? rows.filter(matchesLane) : rows
    return {
      total: matchesLane ? matching.length : rows.$count ?? rows.length,
      freightOrders: matching.slice(0, top).map(compact),
    }
  }

  onFreightOrderSummary(req) {
    return this.summaryOf(req, this.freightOrderIdOf(req))
  }

  /** The summary of one freight order; also the result of every action. */
  async summaryOf(req, id) {
    const { FreightOrders, FreightUnits } = this.dispatchService.entities
    const { Dispatches, TenderRounds } = this.entities

    const [order] = await this.dispatchService.run(SELECT.from(FreightOrders).where({ TransportationOrder: id }))
    if (!order) return req.reject(404, `Freight order ${id} not found or already assigned to a carrier`)

    const [units, dispatch, rounds] = await Promise.all([
      this.dispatchService.run(SELECT.from(FreightUnits).where({ freightOrderId: id })),
      this.run(SELECT.one.from(Dispatches)
        .columns('awardedCarrier', 'awardedPrice', 'currency', 'awardedAt', 'awardedBy')
        .where({ freightOrderId: id })),
      this.run(SELECT.from(TenderRounds).columns(ROUND_COLUMNS).where({ freightOrderId: id }).orderBy('roundNumber')),
    ])

    return {
      ...compact(order),
      freightUnitCount: units.length,
      awardedCarrier: dispatch?.awardedCarrier ?? null,
      awardedPrice: dispatch?.awardedPrice ?? null,
      awardedCurrency: dispatch?.currency ?? null,
      awardedAt: dispatch?.awardedAt ?? null,
      awardedBy: dispatch?.awardedBy ?? null,
      rounds,
    }
  }

  async onCompareOffers(req) {
    const id = this.freightOrderIdOf(req)
    const { Dispatches, TenderRounds } = this.entities
    const now = new Date()

    const [dispatch, rounds] = await Promise.all([
      this.run(SELECT.one.from(Dispatches).columns('status').where({ freightOrderId: id })),
      this.run(SELECT.from(TenderRounds).columns(ROUND_COLUMNS).where({ freightOrderId: id }).orderBy('roundNumber')),
    ])
    const round = rounds.find(r => !r.closed) ?? rounds.at(-1)
    if (!round) return req.reject(404, `No tender round has been started for freight order ${id}`)

    const quoted = round.offers.filter(hasQuote).sort(byPriceAndTransit)
    const others = round.offers.filter(o => !hasQuote(o))
    // prices in different currencies are not comparable (as for bestQuote in enrich.js)
    const comparable = new Set(quoted.map(o => o.currency)).size <= 1

    const verdict = offer => {
      const check = rules.canAward({ dispatch: { dispatchStatus: dispatch?.status }, round, offer, now })
      return { canAward: check.ok, reason: check.ok ? null : check.message }
    }

    const { offers, ...header } = round
    return {
      freightOrderId: id,
      dispatchStatus: dispatch?.status ?? 'NEW',
      ...header,
      note: comparable ? null : 'The quotes are in different currencies, so they are not ranked; the order is by price as quoted.',
      offers: [
        ...quoted.map((o, i) => ({ ...o, rank: comparable ? i + 1 : null, ...verdict(o) })),
        ...others.map(o => ({ ...o, rank: null, ...verdict(o) })),
      ],
    }
  }

  // --- actions ----------------------------------------------------------------------
  // All rules are checked by DispatchService; a violation comes back as its error.

  async onStartTender(req) {
    const id = this.freightOrderIdOf(req)
    const { mode, deadline, carriers } = req.data
    await this.bound('startTender', 'FreightOrders', { TransportationOrder: id }, { mode, deadline, carriers })
    return this.summaryOf(req, id)
  }

  async onCancelTender(req) {
    const id = this.freightOrderIdOf(req)
    await this.bound('cancelTender', 'FreightOrders', { TransportationOrder: id }, { reason: req.data.reason })
    return this.summaryOf(req, id)
  }

  async onCloseRound(req) {
    const id = this.freightOrderIdOf(req)
    await this.bound('closeRound', 'Dispatch', await this.dispatchKeyOf(req, id))
    return this.summaryOf(req, id)
  }

  async onAward(req) {
    const { offerId } = req.data
    await this.bound('award', 'CarrierOffers', { ID: offerId, IsActiveEntity: true })
    const { freightOrderId } = await this.run(
      SELECT.one.from(this.entities.CarrierOffers).columns('freightOrderId').where({ ID: offerId }))
    return this.summaryOf(req, freightOrderId)
  }

  async onReportException(req) {
    const id = this.freightOrderIdOf(req)
    const { type, reason, minutes } = req.data
    await this.bound('reportException', 'Dispatch', await this.dispatchKeyOf(req, id), { type, reason, minutes })
    return this.summaryOf(req, id)
  }

  // --- helpers ----------------------------------------------------------------------

  /** Calls an action that DispatchService binds to one of its entities, as the caller. */
  bound(event, entity, key, data = {}) {
    return this.dispatchService.send({ event, target: this.dispatchService.entities[entity], params: [key], data })
  }

  /** The key of the active dispatch of a freight order, for the actions bound to Dispatch. */
  async dispatchKeyOf(req, freightOrderId) {
    const found = await this.run(SELECT.one.from(this.entities.Dispatches).columns('ID').where({ freightOrderId }))
    if (!found) return req.reject(404, `No tender has been started for freight order ${freightOrderId}`)
    return { ID: found.ID, IsActiveEntity: true }
  }

  /** The freight order ID parameter, trimmed; rejects an empty one. */
  freightOrderIdOf(req) {
    const id = String(req.data.freightOrderId ?? '').trim()
    if (!id) return req.reject(400, 'A freight order ID is required')
    return id
  }
}
