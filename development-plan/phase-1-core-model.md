# Phase 1: Core model and Dispatch service

[← Development plan](README.md) · Previous: [Phase 0](phase-0-setup.md) · Next: [Phase 2](phase-2-dispatch-cockpit.md)

**Goal:** the local domain model, a Dispatch service with remote read plus enrichment, and every tender and award rule covered by tests.

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

- [ ] `tm-client.js`: connects once to `CE_FREIGHTORDER_0001` and `CE_FREIGHTUNIT_0001`, builds queries with an explicit `$select`, and passes `$filter`, `$top`, `$skip` and `$orderby` through from `req.query`.
- [ ] `enrich.js`: for one page of freight orders, runs **one** `SELECT … WHERE freightOrderId IN (…)` for dispatches, plus one aggregate query over rounds and offers for best quote, quote count and current deadline. It merges the results in memory. A missing dispatch reads as NEW.
- [ ] `cache.js`: a small TTL cache (about 5 minutes) for carriers and code lists.

## 1.4 `srv/dispatch-service.cds` + `.js`: `@requires: 'Dispatcher'`

- [ ] `FreightOrders`: read-only projection on the remote freight order, with virtual elements `dispatchStatus`, `bestQuote`, `quoteCount`, `quoteDeadline` and `deadlineExpired`. It excludes orders that already have a carrier. The `READ` handler delegates to `tm-client` and then calls `enrich`.
- [ ] Filters on local fields (`dispatchStatus`, `deadlineExpired`): first pre-select the matching freight order IDs locally, then pass them to TM as an `in` filter, so paging stays correct (§12).
- [ ] Single-entity read of a freight order: **lazily upsert** the `FreightOrderDispatch` record (status NEW).
- [ ] `Dispatch`: `@odata.draft.enabled` projection of `FreightOrderDispatch`, with its compositions, `ExecutionEvents` and `DispatchNotes` editable.
- [ ] `FreightUnits`: read-only projection on the remote freight unit, filtered by freight order.
- [ ] `Carriers`: read-only, with `where active = true`.
- [ ] Actions, bound to active instances and calling `award-rules` before any write. Rule violations go through `req.error(400, …)`.
  - `startTender(mode, deadline, carriers: many String)` on Dispatch: creates round n+1 plus one INVITED offer per carrier, with a `carrierName` snapshot from Carriers, and sets status to TENDERING.
  - `award()` bound to the **offer** (this is how §5's `award(offerId)` appears as a button on the offer row): the offer becomes WON, the other offers in the round LOST, the round is closed, and the dispatch becomes AWARDED with price, currency, carrier, `req.user.id` and a timestamp. All of this happens in one transaction.
  - `closeRound()` on Dispatch: closes the open round and sets its INVITED offers to EXPIRED.
  - `cancelTender(reason)`: sets status to FAILED and adds a `DispatchNotes` entry.
  - `reportException(type, reason, minutes)`: adds an `ExecutionEvents` row.
- [ ] `test/dispatch-service.test.js` (`cds.test`, logged in as nag):
  - the list excludes orders that already have a carrier
  - enrichment values are correct, and enrichment runs in a single local query (spy on `cds.db.run`)
  - lazy creation of the dispatch record
  - every rule in 1.2 through the HTTP layer
  - the full award transaction
  - `closeRound` expiry
  - `cancelTender` with no reason is rejected

**Exit criteria:** every award rule is covered by `cds.test`, and the full tender → (quote inserted in test) → award flow passes.
