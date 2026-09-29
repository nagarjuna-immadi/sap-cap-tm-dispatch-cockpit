/**
 * Local enrichment of one page of freight orders (blueprint §6, development plan 1.3).
 *
 * TM rows carry no dispatch data, so after tm-client has read a page, this adds the
 * virtual elements of DispatchService.FreightOrders to every row:
 *
 *   dispatchStatus    code from FreightOrderDispatch; a missing dispatch reads as NEW
 *   bestQuote         lowest quoted price in the current round (+ bestQuoteCurrency)
 *   quoteCount        number of quotes received in the current round
 *   quoteDeadline     deadline of the current round (falls back to the dispatch's copy)
 *   deadlineExpired   the current round is open and its deadline has passed (on read, UTC)
 *
 * The current round is the one with the highest roundNumber. The page costs exactly two
 * local queries, run in parallel and never one per row: one SELECT on
 * FreightOrderDispatch ... WHERE freightOrderId IN (...), and one aggregate over
 * CarrierOffers grouped by round. The merge happens in memory (`merge`, pure).
 */
import cds from '@sap/cds'
import { isExpired } from './award-rules.js'

const { SELECT } = cds.ql

export const DISPATCH = 'tm.dispatch.FreightOrderDispatch'
export const OFFERS = 'tm.dispatch.CarrierOffers'

/** Offer statuses that carry a submitted price. LOST and WON offers were quoted too. */
export const QUOTED_STATUSES = ['QUOTED', 'WON', 'LOST']

const inList = (path, values) => [{ ref: path }, 'in', { list: values.map(v => ({ val: v })) }]
const quoted = `status_code in (${QUOTED_STATUSES.map(s => `'${s}'`).join(',')})`

// --- queries (pure) -----------------------------------------------------------------

/** The dispatch records of one page, by freight order number. */
export const buildDispatchQuery = ids =>
  SELECT.from(DISPATCH)
    .columns('ID', 'freightOrderId', 'dispatchStatus_code', 'quoteDeadline')
    .where(inList(['freightOrderId'], ids))

/**
 * Per tender round of the page's dispatches: its number, deadline and state, plus the
 * quote count and lowest price among quoted offers. Every round has at least one offer
 * (startTender invites ≥ 1 carrier), so starting from the offers loses no round, and
 * the conditional aggregates keep rounds that have no quote yet.
 *
 * minCurrency/maxCurrency differ when quotes in a round come in more than one currency.
 */
export const buildRoundAggregateQuery = ids =>
  SELECT.from(OFFERS)
    .columns(
      'parent.parent.freightOrderId as freightOrderId',
      'parent.ID as roundId',
      'parent.roundNumber as roundNumber',
      'parent.deadline as deadline',
      'parent.closed as closed',
      `count(case when ${quoted} then ID end) as quoteCount`,
      `min(case when ${quoted} then price end) as bestQuote`,
      `min(case when ${quoted} then currency_code end) as minCurrency`,
      `max(case when ${quoted} then currency_code end) as maxCurrency`,
    )
    .where(inList(['parent', 'parent', 'freightOrderId'], ids))
    .groupBy(
      'parent.parent.freightOrderId', 'parent.ID', 'parent.roundNumber',
      'parent.deadline', 'parent.closed',
    )

// --- merge (pure) -------------------------------------------------------------------

/** The enrichment for one freight order, from its dispatch (or none) and its latest round (or none). */
export const enrichmentOf = (dispatch, round, now) => {
  const mixedCurrencies = round && round.minCurrency !== round.maxCurrency
  const open = !!round && !round.closed
  const quoteDeadline = round?.deadline ?? dispatch?.quoteDeadline ?? null
  return {
    dispatchStatus: dispatch?.dispatchStatus_code ?? 'NEW',
    // Prices in different currencies are not comparable; show no best quote then.
    bestQuote: mixedCurrencies ? null : round?.bestQuote ?? null,
    bestQuoteCurrency: mixedCurrencies ? null : round?.minCurrency ?? null,
    quoteCount: Number(round?.quoteCount ?? 0),
    quoteDeadline,
    deadlineExpired: open && isExpired(quoteDeadline, now),
  }
}

/**
 * Merges dispatches and round aggregates into the rows, in place.
 * @param {object[]} rows        TM freight orders
 * @param {object[]} dispatches  result of buildDispatchQuery
 * @param {object[]} rounds      result of buildRoundAggregateQuery
 * @param {object} [opts]  `key`: row element holding the freight order number; `now`
 */
export const merge = (rows, dispatches, rounds, { key = 'TransportationOrder', now = new Date() } = {}) => {
  const dispatchById = new Map(dispatches.map(d => [d.freightOrderId, d]))
  const latestRound = new Map()
  for (const r of rounds) {
    const current = latestRound.get(r.freightOrderId)
    if (!current || r.roundNumber > current.roundNumber) latestRound.set(r.freightOrderId, r)
  }
  for (const row of rows) {
    const id = row[key]
    Object.assign(row, enrichmentOf(dispatchById.get(id), latestRound.get(id), now))
  }
  return rows
}

// --- run ----------------------------------------------------------------------------

/**
 * Enriches one page of freight orders in place and returns it (keeping `$count`).
 * Accepts an array or a single row (object page read); null/undefined passes through.
 */
export const enrich = async (rows, { key = 'TransportationOrder', now = new Date() } = {}) => {
  if (!rows) return rows
  const page = Array.isArray(rows) ? rows : [rows]
  const ids = [...new Set(page.map(r => r[key]).filter(Boolean))]
  const [dispatches, rounds] = ids.length
    ? await Promise.all([cds.run(buildDispatchQuery(ids)), cds.run(buildRoundAggregateQuery(ids))])
    : [[], []]
  merge(page, dispatches, rounds, { key, now })
  return rows
}
