/**
 * Read access to the TM remote services (blueprint §6, §12; development plan 1.3).
 *
 * The only module outside `srv/external/` that knows TM entity and field names (see the
 * real-names table in development-plan/phase-0-setup.md). TM is read-only here.
 *
 * - `connect()` connects once to CE_FREIGHTORDER_0001 and CE_FREIGHTUNIT_0001; the
 *   connections are shared by every request. Locally these are the auto-mocks.
 * - Every query carries an explicit column list ($select), because the A2X entities
 *   are wide and a list read would otherwise pull every field of every order.
 * - `$filter`, `$top`, `$skip`, `$orderby` (and `$count`) are taken from the incoming
 *   `req.query`. The caller's projection must keep the TM element names, and must strip
 *   local-only elements (dispatchStatus, deadlineExpired, …) from `where` / `orderBy`
 *   first; local filters come back in as `onlyIds` / `excludeIds` (plan 1.4, §12).
 *
 * The build* functions are pure (CQN in, CQN out) so they can be unit-tested; the
 * read* functions run them against the connected services.
 */
import cds from '@sap/cds'

const { SELECT } = cds.ql

export const FO_SERVICE = 'CE_FREIGHTORDER_0001'
export const FU_SERVICE = 'CE_FREIGHTUNIT_0001'
export const FREIGHT_ORDER = `${FO_SERVICE}.FreightOrder`
export const FREIGHT_ORDER_ITEM = `${FO_SERVICE}.FreightOrderItem`
export const FREIGHT_UNIT = `${FU_SERVICE}.FreightUnit`

// --- column lists ($select) ---------------------------------------------------------

const refs = names => names.map(n => ({ ref: [n] }))
const expand = (nav, columns) => ({ ref: [nav], expand: columns })

/** Stop fields: lane (first and last stop) and planned dates. */
export const STOP_COLUMNS = refs([
  'TransportationOrderStopUUID', 'TransportationOrderStop', 'TranspOrdStopCategory',
  'TranspOrdStopRole', 'TranspOrdStopSequencePosition', 'LocationId',
  'TranspOrdStopPlanTranspDteTme',
])

export const STAGE_COLUMNS = refs([
  'TransportationOrderStageUUID', 'TransportationOrderStage', 'TranspOrdStageType',
  'TransportationMode', 'TranspOrdStageSrceStopUUID', 'TranspOrdStageDestStopUUID',
  'TranspOrdStageDistance', 'TranspOrdStageDistanceUnit', 'TranspOrdStageNetDuration',
])

export const ITEM_COLUMNS = refs([
  'TransportationOrderItemUUID', 'TranspOrdItem', 'TranspOrdItemType', 'TranspOrdItemDesc',
  'IsMainCargoItem', 'FreightUnitUUID', 'ProductID',
  'TranspOrdItemQuantity', 'TranspOrdItemQuantityUnit',
  'TranspOrdItemGrossWeight', 'TranspOrdItemGrossWeightUnit',
  'TranspOrdItemGrossVolume', 'TranspOrdItemGrossVolumeUnit',
])

/** Header fields for the list; stops are expanded because they hold the lane and dates. */
export const FREIGHT_ORDER_LIST_COLUMNS = [
  ...refs([
    'TransportationOrderUUID', 'TransportationOrder', 'TransportationOrderType',
    'TransportationMode', 'Carrier', 'Shipper', 'Consignee', 'TranspPurgOrg',
    'TranspPurgGroup', 'TranspOrdResponsiblePerson', 'TranspOrdLifeCycleStatus',
    'TranspOrdExecutionIsBlocked', 'TranspOrdOrderDateTime',
  ]),
  expand('_FreightOrderStop', STOP_COLUMNS),
]

/** Object page: header, stops with their stages (stages sit under stops), and items. */
export const FREIGHT_ORDER_DETAIL_COLUMNS = [
  ...FREIGHT_ORDER_LIST_COLUMNS.filter(c => c.ref[0] !== '_FreightOrderStop'),
  expand('_FreightOrderStop', [...STOP_COLUMNS, expand('_FreightOrderStage', STAGE_COLUMNS)]),
  expand('_FreightOrderItem', ITEM_COLUMNS),
]

export const FREIGHT_UNIT_COLUMNS = refs([
  'TransportationOrderUUID', 'TransportationOrder', 'TransportationOrderType',
  'TransportationMode', 'Shipper', 'Consignee', 'TranspOrdLifeCycleStatus',
  'TranspOrdPlanningStatus', 'TranspOrdExecutionIsBlocked',
])

// --- CQN helpers --------------------------------------------------------------------

const val = v => ({ val: v })

/** `<element> in (…)` as a CQN token list. */
export const inList = (element, values) => [{ ref: [element] }, 'in', { list: values.map(val) }]

/** ANDs CQN where-token lists, bracketing each so an `or` in one cannot leak. */
export const and = (...parts) => {
  const present = parts.filter(p => p?.length)
  if (present.length <= 1) return present[0]
  return present.flatMap((p, i) => (i ? ['and', { xpr: p }] : [{ xpr: p }]))
}

/**
 * The pass-through parts of an incoming query: `$filter` → where, `$orderby` → orderBy,
 * `$top`/`$skip` → limit, `$count` → count. Accepts a CQN SELECT or `req.query`.
 */
export const passThrough = query => {
  const { where, orderBy, limit, count } = query?.SELECT ?? {}
  return { where, orderBy, limit, count }
}

/** Applies where/orderBy/limit/count to a query built with SELECT.from(…).columns(…). */
const apply = (q, { where, orderBy, limit, count }) => {
  if (where?.length) q.SELECT.where = where
  if (orderBy?.length) q.SELECT.orderBy = orderBy
  if (limit) q.SELECT.limit = limit
  if (count) q.SELECT.count = true
  return q
}

// --- query builders (pure) ----------------------------------------------------------

/**
 * List read of freight orders for one page.
 *
 * @param {object} [query]  incoming CQN (req.query), local-only elements already removed
 * @param {object} [opts]
 * @param {boolean} [opts.unassignedOnly=true]  only orders with no carrier (`Carrier eq ''`)
 * @param {string[]} [opts.onlyIds]     restrict to these `TransportationOrder` numbers
 * @param {string[]} [opts.excludeIds]  leave out these `TransportationOrder` numbers
 * @returns the CQN, or `null` when `onlyIds` is empty (nothing can match; skip the call)
 */
export const buildFreightOrderListQuery = (query, { unassignedOnly = true, onlyIds, excludeIds } = {}) => {
  if (onlyIds && !onlyIds.length) return null
  const pt = passThrough(query)
  const where = and(
    pt.where,
    unassignedOnly && [{ ref: ['Carrier'] }, '=', val('')],
    onlyIds && inList('TransportationOrder', onlyIds),
    excludeIds?.length && ['not', { xpr: inList('TransportationOrder', excludeIds) }],
  )
  return apply(SELECT.from(FREIGHT_ORDER).columns(FREIGHT_ORDER_LIST_COLUMNS), { ...pt, where })
}

/** Single freight order by its readable number, expanded for the object page. */
export const buildFreightOrderQuery = freightOrderId =>
  SELECT.one.from(FREIGHT_ORDER)
    .columns(FREIGHT_ORDER_DETAIL_COLUMNS)
    .where({ TransportationOrder: freightOrderId })

/** Step 1 of the freight-unit lookup: the order's items, for their FreightUnitUUIDs. */
export const buildFreightUnitRefsQuery = freightOrderId =>
  SELECT.one.from(FREIGHT_ORDER)
    .columns([{ ref: ['TransportationOrderUUID'] }, expand('_FreightOrderItem', refs(['FreightUnitUUID']))])
    .where({ TransportationOrder: freightOrderId })

/** Step 2: the freight units themselves, by UUID. `null` when there are none. */
export const buildFreightUnitsQuery = (freightUnitUUIDs, query) => {
  if (!freightUnitUUIDs.length) return null
  const pt = passThrough(query)
  const where = and(pt.where, inList('TransportationOrderUUID', freightUnitUUIDs))
  return apply(SELECT.from(FREIGHT_UNIT).columns(FREIGHT_UNIT_COLUMNS), { ...pt, where })
}

// --- remote reads -------------------------------------------------------------------

let connections

/** Connects once; later calls reuse the same promise (also while the first is pending). */
export const connect = () => {
  connections ??= Promise.all([cds.connect.to(FO_SERVICE), cds.connect.to(FU_SERVICE)])
    .then(([fo, fu]) => ({ fo, fu }))
    .catch(e => { connections = undefined; throw e })
  return connections
}

/** One page of freight orders; see buildFreightOrderListQuery for the options. */
export const readFreightOrders = async (query, opts) => {
  const q = buildFreightOrderListQuery(query, opts)
  if (!q) return emptyPage(query)
  const { fo } = await connect()
  return fo.run(q)
}

/** One freight order with stops, stages and items; nothing (null/undefined) if TM has none. */
export const readFreightOrder = async freightOrderId => {
  const { fo } = await connect()
  return fo.run(buildFreightOrderQuery(freightOrderId))
}

/**
 * Freight units of a freight order. A freight unit has no reference to its freight
 * order, so this reads the order's items for FreightUnitUUID, then the units by UUID.
 */
export const readFreightUnits = async (freightOrderId, query) => {
  const { fo, fu } = await connect()
  const order = await fo.run(buildFreightUnitRefsQuery(freightOrderId))
  const uuids = [...new Set((order?._FreightOrderItem ?? []).map(i => i.FreightUnitUUID).filter(Boolean))]
  const q = buildFreightUnitsQuery(uuids, query)
  return q ? fu.run(q) : emptyPage(query)
}

/**
 * Read-only context of several freight orders (TenderService): header and stops, by
 * number, whether or not a carrier is assigned. One TM call for the whole page.
 * @returns {Promise<Map<string, object>>} freight order number → TM row
 */
export const readFreightOrderContexts = async freightOrderIds => {
  const ids = [...new Set(freightOrderIds.filter(Boolean))]
  if (!ids.length) return new Map()
  const rows = await readFreightOrders(null, { unassignedOnly: false, onlyIds: ids })
  return new Map(rows.map(r => [r.TransportationOrder, r]))
}

// --- derived values -----------------------------------------------------------------

/** Lane and dates from the stops: first stop (position F) and last stop (position L). */
export const laneOf = (stops = []) => {
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

/** An empty result that still answers `$count`. */
const emptyPage = query => {
  const rows = []
  if (query?.SELECT?.count) rows.$count = 0
  return rows
}
