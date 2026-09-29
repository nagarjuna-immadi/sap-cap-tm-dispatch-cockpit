/**
 * DispatchService handlers (blueprint §5, development plan 1.4).
 *
 * - FreightOrders / FreightUnits are read from TM through tm-client and never touch the
 *   database. List reads pass $filter/$top/$skip/$orderby through; filters on local
 *   elements are resolved to freight order numbers first (local-filter.js, §12). Each
 *   page is then enriched with two local queries (enrich.js).
 * - The single read of a freight order lazily creates its FreightOrderDispatch (NEW), and
 *   so do startTender / cancelTender, which are bound to FreightOrders for the list toolbar.
 * - Actions work on the active Dispatch only, check award-rules.js before any write, lock
 *   the dispatch row, and report violations with req.error. TM stays read-only.
 */
import cds from '@sap/cds'
import * as tm from './lib/tm-client.js'
import { enrich, enrichmentOf } from './lib/enrich.js'
import { cached } from './lib/cache.js'
import * as rules from './lib/award-rules.js'
import { splitWhere, refsOf, resolveIds, FilterError } from './lib/local-filter.js'

const { SELECT, INSERT, UPDATE } = cds.ql

const DB = {
  Dispatch: 'tm.dispatch.FreightOrderDispatch',
  Rounds: 'tm.dispatch.TenderRounds',
  Offers: 'tm.dispatch.CarrierOffers',
  Events: 'tm.dispatch.ExecutionEvents',
  Notes: 'tm.dispatch.DispatchNotes',
  Carriers: 'tm.dispatch.Carriers',
  DispatchStatus: 'tm.dispatch.DispatchStatus',
  TenderModes: 'tm.dispatch.TenderModes',
  EventTypes: 'tm.dispatch.EventTypes',
  DelayReasons: 'tm.dispatch.DelayReasons',
}

/** FreightOrders elements that TM does not have. Only the first two can be filtered on. */
const FILTERABLE_LOCAL = ['dispatchStatus', 'deadlineExpired']
const LOCAL_ELEMENTS = [
  ...FILTERABLE_LOCAL, 'dispatchStatusCriticality', 'bestQuote', 'bestQuoteCurrency', 'quoteCount',
  'quoteDeadline', 'sourceLocation', 'destinationLocation', 'pickupDateTime', 'deliveryDateTime',
  'dispatch', 'freightUnits',
]

/** Dispatch fields that only actions may change; never taken from a draft or a PATCH. */
const ACTION_OWNED = [
  'freightOrderId', 'dispatchStatus_code', 'awardedCarrier', 'awardedPrice', 'currency_code',
  'awardedAt', 'awardedBy', 'quoteDeadline', 'rounds',
]

// --- reference data (cached, cache.js) ----------------------------------------------

const codes = entity => cached(entity, async () =>
  new Set((await SELECT.from(entity).columns('code')).map(c => c.code)))

const statusCriticality = () => cached(DB.DispatchStatus, async () =>
  new Map((await SELECT.from(DB.DispatchStatus).columns('code', 'criticality')).map(c => [c.code, c.criticality])))

const activeCarriers = () => cached(DB.Carriers, async () =>
  new Map((await SELECT.from(DB.Carriers).columns('carrierId', 'name').where({ active: true }))
    .map(c => [c.carrierId, c.name])))

// --- helpers ------------------------------------------------------------------------

/** The value of a single key, whether CAP passes it as the value or as `{ key: value }`. */
const keyValue = (param, name) => (param && typeof param === 'object' ? param[name] : param)

/** The `$expand` column for a navigation, if the incoming query asks for it. */
const expandOf = (query, name) =>
  query.SELECT.columns?.find(c => c.ref?.[0] === name && c.expand)

/**
 * The pass-through parts of the incoming query with another where clause. Named
 * explicitly: `limit` and `count` are inherited, not own, properties of an OData
 * request's SELECT, so an object spread would drop $top/$skip/$count.
 */
const withWhere = (query, where) => {
  const { orderBy, limit, count } = query.SELECT
  return { SELECT: { where, orderBy, limit, count } }
}

/** Lane and dates from the stops: first stop (position F) and last stop (position L). */
const laneOf = (stops = []) => {
  const sorted = [...stops].sort((a, b) => a.TransportationOrderStop.localeCompare(b.TransportationOrderStop))
  const first = sorted.find(s => s.TranspOrdStopSequencePosition === 'F') ?? sorted[0]
  const last = sorted.findLast(s => s.TranspOrdStopSequencePosition === 'L') ?? sorted.at(-1)
  return {
    sourceLocation: first?.LocationId ?? null,
    destinationLocation: last?.LocationId ?? null,
    pickupDateTime: first?.TranspOrdStopPlanTranspDteTme ?? null,
    deliveryDateTime: last?.TranspOrdStopPlanTranspDteTme ?? null,
  }
}

/** Reports a failed award-rules check; returns true when the check passed. */
const passes = (req, check) => {
  if (check.ok) return true
  req.error({ status: 400, code: check.code, message: check.message })
  return false
}

const bad = (req, code, message) => req.error({ status: 400, code, message })

export default class DispatchService extends cds.ApplicationService {
  init() {
    const {
      FreightOrders, FreightOrderStops, FreightOrderStages, FreightOrderItems, FreightUnits,
      Dispatch, CarrierOffers,
    } = this.entities

    // --- TM reads -------------------------------------------------------------------

    this.on('READ', FreightOrders, req => (req.params.length
      ? this.readFreightOrder(req, keyValue(req.params[0], 'TransportationOrder'))
      : this.readFreightOrderList(req)))

    this.on('READ', FreightUnits, req => this.readFreightUnits(req))

    this.on('READ', [FreightOrderStops, FreightOrderStages, FreightOrderItems], req =>
      req.reject(400, `Read ${req.target.name.split('.').pop()} with $expand on a single freight order`))

    // --- Dispatch lifecycle ---------------------------------------------------------

    this.before(['NEW', 'CREATE'], Dispatch, req =>
      req.reject(405, 'A dispatch is created when its freight order is first opened'))
    this.before('DELETE', Dispatch, req => req.reject(405, 'A dispatch cannot be deleted; cancel the tender instead'))

    // Saving a draft must not overwrite what actions changed meanwhile (status, award,
    // rounds and offers written by TenderService): drop those from the deep update.
    this.before('UPDATE', Dispatch, req => { for (const f of ACTION_OWNED) delete req.data[f] })

    // --- actions --------------------------------------------------------------------

    this.on('startTender', FreightOrders, async req => this.onStartTender(req, await this.dispatchOf(req)))
    this.on('cancelTender', FreightOrders, async req => this.onCancelTender(req, await this.dispatchOf(req)))
    this.on('closeRound', Dispatch, req => this.onCloseRound(req))
    this.on('reportException', Dispatch, req => this.onReportException(req))
    this.on('award', CarrierOffers, req => this.onAward(req))

    return super.init()
  }

  // --- FreightOrders ----------------------------------------------------------------

  async readFreightOrderList(req) {
    const now = new Date()
    const { where, orderBy } = req.query.SELECT
    const sortedLocally = orderBy?.find(o => LOCAL_ELEMENTS.includes(o.ref?.[0]))
    if (sortedLocally) return req.reject(400, `Sorting by ${sortedLocally.ref[0]} is not supported`)
    if (expandOf(req.query, 'freightUnits'))
      return req.reject(400, 'Expand freightUnits on a single freight order only')

    let split
    try { split = splitWhere(where, LOCAL_ELEMENTS) } catch (e) {
      if (e instanceof FilterError) return req.reject(400, e.message)
      throw e
    }
    const unsupported = [...refsOf(split.local ?? [])].filter(r => !FILTERABLE_LOCAL.includes(r))
    if (unsupported.length) return req.reject(400, `Filtering by ${unsupported.join(', ')} is not supported`)

    let ids = {}
    try {
      if (split.local) ids = resolveIds(split.local, await this.localEnrichment(now), enrichmentOf(undefined, undefined, now))
    } catch (e) {
      if (e instanceof FilterError) return req.reject(400, e.message)
      throw e
    }

    const rows = await tm.readFreightOrders(withWhere(req.query, split.remote), ids)
    await this.enrichPage(req, rows, now)
    return rows
  }

  async readFreightOrder(req, id) {
    const now = new Date()
    const { row } = await this.openFreightOrder(req, id)
    await this.enrichPage(req, [row], now)
    const units = expandOf(req.query, 'freightUnits')
    if (units) row.freightUnits = (await tm.readFreightUnits(id)).map(u => ({ ...u, freightOrderId: id }))
    return row
  }

  /** Enrichment, criticality and lane; the dispatch expand; drops TM expands not asked for. */
  async enrichPage(req, rows, now) {
    await enrich(rows, { now })
    const criticality = await statusCriticality()
    for (const r of rows) {
      r.dispatchStatusCriticality = criticality.get(r.dispatchStatus) ?? 0
      Object.assign(r, laneOf(r._FreightOrderStop))
      for (const nav of ['_FreightOrderStop', '_FreightOrderItem'])
        if (!expandOf(req.query, nav)) delete r[nav]
    }
    const dispatch = expandOf(req.query, 'dispatch')
    if (dispatch && rows.length) {
      const { Dispatch } = this.entities
      const columns = [...dispatch.expand, { ref: ['freightOrderId'], as: '_fo' }]
      const found = await this.run(SELECT.from(Dispatch).columns(columns)
        .where({ freightOrderId: { in: rows.map(r => r.TransportationOrder) } }))
      const byId = new Map(found.map(({ _fo, ...d }) => [_fo, d]))
      for (const r of rows) r.dispatch = byId.get(r.TransportationOrder) ?? null
    }
  }

  /** Enrichment values of every local dispatch, as filter records for resolveIds. */
  async localEnrichment(now) {
    const all = await SELECT.from(DB.Dispatch).columns('freightOrderId')
    const rows = await enrich(all.map(d => ({ TransportationOrder: d.freightOrderId })), { now })
    return rows.map(r => ({ id: r.TransportationOrder, ...r }))
  }

  /** The TM freight order, if it is still to tender; ensures its dispatch exists. */
  async openFreightOrder(req, id) {
    const row = await tm.readFreightOrder(id)
    if (!row || row.Carrier !== '') return req.reject(404, `Freight order ${id} not found or already assigned to a carrier`)
    return { row, dispatchId: await this.ensureDispatch(id) }
  }

  /** The dispatch ID for an action bound to FreightOrders. */
  async dispatchOf(req) {
    const { dispatchId } = await this.openFreightOrder(req, keyValue(req.params.at(-1), 'TransportationOrder'))
    return dispatchId
  }

  /**
   * The ID of the dispatch of a freight order, created (NEW) on its first open;
   * tolerates a concurrent open.
   */
  async ensureDispatch(freightOrderId) {
    const exists = () => SELECT.one.from(DB.Dispatch).columns('ID').where({ freightOrderId })
    const found = await exists()
    if (found) return found.ID
    try {
      await INSERT.into(DB.Dispatch).entries({ freightOrderId, dispatchStatus_code: 'NEW' })
    } catch (e) {
      if (!(await exists())) throw e   // not a lost race on the unique freightOrderId
    }
    return (await exists()).ID
  }

  // --- FreightUnits -----------------------------------------------------------------

  async readFreightUnits(req) {
    const { from, where } = req.query.SELECT
    let id, remote = where
    if (from.ref.length > 1) {
      id = keyValue(req.params[0], 'TransportationOrder')   // FreightOrders('…')/freightUnits
    } else if (req.params.length) {
      return req.reject(400, 'Read freight units through their freight order')
    } else {
      let split
      try { split = splitWhere(where, ['freightOrderId']) } catch (e) {
        if (e instanceof FilterError) return req.reject(400, e.message)
        throw e
      }
      const [lhs, op, rhs] = split.local?.length === 1 ? split.local[0].xpr : []
      if (lhs?.ref?.[0] !== 'freightOrderId' || op !== '=' || !rhs || !('val' in rhs))
        return req.reject(400, "Filter freight units by exactly one freight order: $filter=freightOrderId eq '…'")
      id = rhs.val
      remote = split.remote
    }
    const rows = await tm.readFreightUnits(id, withWhere(req.query, remote))
    for (const r of rows) r.freightOrderId = id
    return rows
  }

  // --- actions ----------------------------------------------------------------------

  /**
   * The active dispatch an action runs on, locked for the rest of the transaction, with
   * its rounds. Rejects draft instances and dispatches that someone has open in a draft
   * (saving that draft would drop the exceptions and notes the action adds).
   */
  async lockDispatch(req, ID) {
    const key = req.params.at(-1)
    if (key?.IsActiveEntity === false) return req.reject(400, 'Actions work on the saved dispatch, not on a draft')
    const dispatch = await SELECT.one.from(DB.Dispatch).where({ ID }).forUpdate()
    if (!dispatch) return req.reject(404, 'Dispatch not found')
    const draft = await SELECT.one.from(this.entities.Dispatch.drafts)
      .columns('DraftAdministrativeData.InProcessByUser as user').where({ ID })
    if (draft) return req.reject(409, `The dispatch is being edited by ${draft.user}; save or discard the draft first`)
    dispatch.rounds = await SELECT.from(DB.Rounds).where({ parent_ID: ID }).orderBy('roundNumber')
    return dispatch
  }

  /** Closes a round and expires its offers that were never answered. */
  async closeOpenRound(round) {
    await UPDATE(DB.Rounds, round.ID).set({ closed: true })
    await UPDATE(DB.Offers).set({ status_code: 'EXPIRED' }).where({ parent_ID: round.ID, status_code: 'INVITED' })
  }

  /** The action result: the active dispatch as the service shows it. */
  readDispatch(ID) {
    return this.run(SELECT.one.from(this.entities.Dispatch).where({ ID, IsActiveEntity: true }))
  }

  async onStartTender(req, ID) {
    const dispatch = await this.lockDispatch(req, ID)
    const { mode, deadline } = req.data
    const carriers = (req.data.carriers ?? []).map(c => (typeof c === 'string' ? c.trim() : c))
    const now = new Date()

    if (!passes(req, rules.canStartTender(dispatch, { carriers, deadline, now }))) return
    if (!(await codes(DB.TenderModes)).has(mode)) return bad(req, 'INVALID_MODE', `Unknown tender mode '${mode}'`)
    const active = await activeCarriers()
    const unknown = carriers.filter(c => !active.has(c))
    if (unknown.length) return bad(req, 'UNKNOWN_CARRIER', `Not an active carrier: ${unknown.join(', ')}`)

    const quoteDeadline = new Date(deadline).toISOString()
    await INSERT.into(DB.Rounds).entries({
      parent_ID: ID,
      roundNumber: rules.nextRoundNumber(dispatch.rounds),
      mode_code: mode,
      deadline: quoteDeadline,
      closed: false,
      offers: carriers.map(carrierId => ({ carrierId, carrierName: active.get(carrierId), status_code: 'INVITED' })),
    })
    await UPDATE(DB.Dispatch, ID).set({ dispatchStatus_code: 'TENDERING', quoteDeadline })
  }

  async onAward(req) {
    const offerId = keyValue(req.params.at(-1), 'ID')
    if (req.params.at(-1)?.IsActiveEntity === false) return req.reject(400, 'Actions work on the saved offer, not on a draft')
    const found = await SELECT.one.from(DB.Offers).columns('parent.parent_ID as dispatchId').where({ ID: offerId })
    if (!found) return req.reject(404, 'Offer not found')

    // lock first, then read offer and round, so a concurrent award or quote cannot interleave
    const dispatch = await this.lockDispatch(req, found.dispatchId)
    const offer = await SELECT.one.from(DB.Offers).where({ ID: offerId })
    const round = await SELECT.one.from(DB.Rounds).where({ ID: offer.parent_ID })
    const now = new Date()
    if (!passes(req, rules.canAward({ dispatch, round, offer, now }))) return

    await UPDATE(DB.Offers, offerId).set({ status_code: 'WON' })
    await UPDATE(DB.Offers).set({ status_code: 'LOST' }).where({ parent_ID: round.ID, status_code: 'QUOTED' })
    await this.closeOpenRound(round)
    await UPDATE(DB.Dispatch, dispatch.ID).set({
      dispatchStatus_code: 'AWARDED',
      awardedCarrier: offer.carrierId,
      awardedPrice: offer.price,
      currency_code: offer.currency_code,
      awardedBy: req.user.id,
      awardedAt: now.toISOString(),
    })
    return this.run(SELECT.one.from(this.entities.CarrierOffers).where({ ID: offerId, IsActiveEntity: true }))
  }

  async onCloseRound(req) {
    const ID = keyValue(req.params.at(-1), 'ID')
    const dispatch = await this.lockDispatch(req, ID)
    const round = dispatch.rounds.find(r => !r.closed)
    if (!passes(req, rules.canCloseRound(round))) return
    await this.closeOpenRound(round)
    return this.readDispatch(ID)
  }

  async onCancelTender(req, ID) {
    const dispatch = await this.lockDispatch(req, ID)
    const { reason } = req.data
    if (!passes(req, rules.canCancel(dispatch, reason))) return
    for (const round of dispatch.rounds.filter(r => !r.closed)) await this.closeOpenRound(round)
    await UPDATE(DB.Dispatch, ID).set({ dispatchStatus_code: 'FAILED' })
    await INSERT.into(DB.Notes).entries({ parent_ID: ID, text: `Tender cancelled: ${reason.trim()}` })
  }

  async onReportException(req) {
    const ID = keyValue(req.params.at(-1), 'ID')
    await this.lockDispatch(req, ID)
    const { type, reason, minutes } = req.data
    if (!(await codes(DB.EventTypes)).has(type)) return bad(req, 'INVALID_EVENT_TYPE', `Unknown event type '${type}'`)
    if (reason && !(await codes(DB.DelayReasons)).has(reason)) return bad(req, 'INVALID_DELAY_REASON', `Unknown delay reason '${reason}'`)
    if (type === 'DELAY' && !reason) return bad(req, 'REASON_REQUIRED', 'A delay needs a reason')
    if (minutes !== null && minutes !== undefined && !(minutes >= 0))
      return bad(req, 'INVALID_MINUTES', 'The delay in minutes cannot be negative')

    await INSERT.into(DB.Events).entries({
      parent_ID: ID,
      eventType_code: type,
      eventTime: new Date().toISOString(),
      delayReason_code: reason || null,
      delayMins: minutes ?? null,
    })
    return this.readDispatch(ID)
  }
}
