# Phase 1: Core model and Dispatch service

[← Development plan](README.md) · Previous: [Phase 0](phase-0-setup.md) · Next: [Phase 2](phase-2-dispatch-cockpit.md)

**Goal:** the local domain model, a Dispatch service with remote read plus enrichment, and the tender and award rules enforced on every action.

## 1.1 Domain model: `db/schema.cds`

- [x] Entities as in §4, namespace `tm.dispatch`: `FreightOrderDispatch`, `TenderRounds`, `CarrierOffers`, `ExecutionEvents`, `DispatchNotes`, `Carriers`, and the code lists.
- [x] Seed data in `db/data/`:
  - `tm.dispatch-Carriers.csv` with 12 carriers, BP-style IDs, and 1–2 set to `active=false`.
  - Code lists with criticality (1 = red, 2 = yellow, 3 = green):
    - `DispatchStatus`: NEW 0, TENDERING 2, AWARDED 3, FAILED 1, CLOSED 0
    - `OfferStatus`: INVITED 2, QUOTED 3, DECLINED 1, EXPIRED 1, WON 3, LOST 0
    - `TenderModes`, `EventTypes` and `DelayReasons` as listed in §4
- [x] Add a `_texts` / `name` column to the code lists so value helps show readable text.

## 1.2 Business rules: `srv/lib/award-rules.js` (pure, no CDS imports)

Each function takes plain objects and a `now` value, and returns `{ ok: true }` or `{ ok: false, code, message }`:

- [x] `canStartTender(dispatch, { carriers, deadline, now })`: status is NEW or TENDERING, no other round is open, the deadline is in the future, and there is at least one carrier with no duplicates.
- [x] `canAward({ dispatch, round, offer, now })`: the offer is QUOTED, the round is not closed, the dispatch is not already AWARDED, and in BROADCAST mode `now >= round.deadline`.
- [x] `canSubmitQuote({ offer, round, now })`: the offer is INVITED, the round is open, `now < deadline`, the price is greater than 0, and transit hours are greater than 0.
- [x] `canDecline({ offer, round, now })`: the offer is INVITED and the round is open.
- [x] `canCloseRound(round)` and `canCancel(dispatch, reason)` (the reason is mandatory).
- [x] `isExpired(deadline, now)` and `effectiveOfferStatus(offer, round, now)`: an INVITED offer after the deadline reads as EXPIRED.
- [x] `nextRoundNumber(rounds)`.
- [x] `test/award-rules.test.js`: one `describe` block per function, covering every branch, including the boundary where `now` equals the deadline.

## 1.3 Remote access helpers: `srv/lib/`

- [x] `tm-client.js`: connects once to `CE_FREIGHTORDER_0001` and `CE_FREIGHTUNIT_0001`, builds queries with an explicit `$select`, and passes `$filter`, `$top`, `$skip` and `$orderby` through from `req.query`.
- [x] `enrich.js`: for one page of freight orders, runs **one** `SELECT … WHERE freightOrderId IN (…)` for dispatches, plus one aggregate query over rounds and offers for best quote, quote count and current deadline. It merges the results in memory. A missing dispatch reads as NEW.
- [x] `cache.js`: a small TTL cache (about 5 minutes) for carriers and code lists.

## 1.4 `srv/dispatch-service.cds` + `.js`: `@requires: 'Dispatcher'`

- [x] `FreightOrders`: read-only projection on the remote freight order, with virtual elements `dispatchStatus`, `bestQuote`, `quoteCount`, `quoteDeadline` and `deadlineExpired`. It excludes orders that already have a carrier. The `READ` handler delegates to `tm-client` and then calls `enrich`.
  - Keyed by the readable `TransportationOrder` (`FreightOrders('6100000002')`), so the key is the same value as `FreightOrderDispatch.freightOrderId`. `TransportationOrderUUID` stays as a plain element.
  - Also has virtual `dispatchStatusCriticality` and `bestQuoteCurrency`, plus the lane (`sourceLocation`, `destinationLocation`, `pickupDateTime`, `deliveryDateTime`) taken from the first and last stop.
  - Stops, stages and items are slim projections. They can be read only through `$expand` on a single order.
  - It has the associations `dispatch` (expandable on list and single reads) and `freightUnits` (single read only).
  - Virtual elements cannot be sorted on. `@Capabilities` annotations mark this, and the handler returns 400.
- [x] Filters on local fields (`dispatchStatus`, `deadlineExpired`): first pre-select the matching freight order IDs locally, then pass them to TM as an `in` filter, so paging stays correct (§12). This lives in `srv/lib/local-filter.js`.
  - A missing dispatch reads as NEW. So when the condition matches NEW, the result is a `not in` of the local dispatches that do not match.
  - Local conditions may be combined with TM conditions only through top-level `and`. `or` / `not` across both kinds, and filters on the other virtual elements, return 400.
- [x] Single-entity read of a freight order: **lazily upsert** the `FreightOrderDispatch` record (status NEW). A concurrent first open is tolerated. An unknown order, or one that already has a carrier, returns 404.
- [x] `Dispatch`: `@odata.draft.enabled` projection of `FreightOrderDispatch`, with its compositions, `ExecutionEvents` and `DispatchNotes` editable.
  - `TenderRounds` and `CarrierOffers` are `@readonly`, and so are the status and award fields.
  - Saving a draft drops those fields and `rounds` from the update, so a stale draft cannot overwrite what the actions (or TenderService) changed.
  - Creating and deleting a dispatch returns 405.
- [x] `FreightUnits`: read-only projection on the remote freight unit, filtered by freight order. Read it with `$filter=freightOrderId eq '…'`, `FreightOrders('…')/freightUnits`, or `$expand` on a single order.
- [x] `Carriers`: read-only, with `where active = true`.
- [x] Actions, bound to active instances and calling `award-rules` before any write. Rule violations go through `req.error(400, …)`, with the rule's `code`.
  - Each action locks the dispatch row (`forUpdate`). It is refused (409) while someone has the dispatch open in a draft, because saving that draft would drop the notes and exceptions the action adds.
  - Unknown modes, event types and delay reasons, and inactive or unknown carriers, return 400.
  - `startTender(mode, deadline, carriers: many String)` on Dispatch: creates round n+1 plus one INVITED offer per carrier, with a `carrierName` snapshot from Carriers, and sets status to TENDERING.
  - `award()` bound to the **offer** (this is how §5's `award(offerId)` appears as a button on the offer row): the offer becomes WON, the other QUOTED offers in the round become LOST, still-INVITED offers become EXPIRED (as in `closeRound`), DECLINED offers stay as they are, and the round is closed. The dispatch becomes AWARDED with price, currency, carrier, `req.user.id` and a timestamp. All of this happens in one transaction.
  - `closeRound()` on Dispatch: closes the open round and sets its INVITED offers to EXPIRED.
  - `cancelTender(reason)`: sets status to FAILED, closes an open round (INVITED offers become EXPIRED) so carriers can no longer quote, and adds a `DispatchNotes` entry.
  - `reportException(type, reason, minutes)`: adds an `ExecutionEvents` row. A `DELAY` needs a reason, and the minutes cannot be negative.
- [x] `test/http/dispatch.http` (REST Client, as nag): list, open one order, start tender, award, close round, cancel tender. The quote step before the award waits for phase 3's `submitQuote`.

**Exit criteria:** under `cds watch`, the list excludes orders that already have a carrier and shows the enrichment values, and the full tender → (quote entered via `.http`) → award flow works.
