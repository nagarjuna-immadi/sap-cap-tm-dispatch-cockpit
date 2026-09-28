# Development Plan: Freight Tendering & Carrier Performance Cockpit

This is the step-by-step build plan for `sap-cap-tm-dispatch-cockpit`. The **what** and **why** are in [`blueprint.md`](blueprint.md). This file is the **how** and **in which order**. Section references (§n) point to the blueprint.

## Ground rules

- **One branch per phase** (`phase-0-setup`, `phase-1-core`, …), merged into `main` when the phase's exit criteria pass.
- **Tests before merge.** `npx jest` must pass. Business rules get unit tests. Service behaviour gets `cds.test` tests.
- **The mock profile always works.** `cds watch` with no credentials must keep serving the full app after every phase.
- **TM stays read-only** until phase 5, and phase 5 writeback never targets the sandbox (§1, §6).
- **Field names:** the blueprint uses placeholder names (§2, §12). After `cds import`, use the real EDMX names everywhere.
- **Timestamps** are stored in UTC. "Expired" is always decided on the server by comparing with an injected `now`.

---

## Phase 0: Setup and API verification

**Goal:** a CAP project that starts with mocked TM services and returns freight orders.

### 0.1 Verify the Hub APIs (manual)
For each of `API_FREIGHTORDER`, `API_FREIGHTUNIT` and `API_FREIGHTBOOKING`:
- [ ] Confirm the state is ACTIVE on api.sap.com.
- [ ] Download the EDMX to `srv/external/<API>.edmx`.
- [ ] Note the exact service path (`/sap/opu/odata4/sap/.../0001/`).
- [ ] Run **Try Out** and record whether it returns rows.
- [ ] Update the "Hub sandbox" column in blueprint §2 with the result (Yes / Empty / No).

### 0.2 Scaffold the project
- [x] Run `cds init` in place, then add `@sap/cds`, `@cap-js/sqlite`, and (dev) `@cap-js/cds-test` and `jest`.
- [x] `package.json` scripts: `start`, `watch` (`cds watch`), `test` (`jest`).
- [x] Add `jest.config.js` (testEnvironment `node`, `testTimeout` about 20s).

### 0.3 Import the TM services
- [ ] Run `cds import srv/external/API_FREIGHTORDER.edmx --as cds`, and the same for FREIGHTUNIT and FREIGHTBOOKING.
- [ ] In `package.json` → `cds.requires`, add `TM_FREIGHT_ORDER`, `TM_FREIGHT_UNIT` and `TM_FREIGHT_BOOKING` (`kind: odata-v4`, `model: srv/external/<API>`). There are no credentials yet; the `[hybrid]` and `[production]` entries come in phase 4.
- [ ] Write down the real entity set and key names for freight order, items, stages, freight unit and freight booking. Keep them in a short table in this file (below) for later phases.

### 0.4 Mock data (`srv/external/data/`)
- [ ] At least **30 freight orders** across 4–6 lanes, with pick-up dates spread over the past week and the next 3 weeks.
- [ ] About 20% of them already have a carrier. These must not appear in the "to tender" list.
- [ ] Freight units for most orders, but **3 or more orders with none** (to cover the empty facet).
- [ ] A few freight bookings linked to pick-up and delivery orders.
- [ ] CSV file names must match the imported namespace and entity (`<namespace>-<Entity>.csv`).

### 0.5 Local users
- [ ] In `.cdsrc.json`, use `auth: mocked` with users `alice` (Dispatcher), `bob` (CarrierDesk) and `carol` (TransportManager).

### 0.6 Smoke test
- [ ] Add `test/smoke.test.js`: it runs `cds.test` and reads the mocked freight orders through a temporary service, then checks that there are more than 30 rows.

**Exit criteria:** `cds watch` serves mocked freight orders, `npx jest` passes, and blueprint §2 records sandbox availability.

| Real TM names (fill in during 0.3) | Entity set | Key | Notes |
|---|---|---|---|
| Freight order | | | |
| Freight order items / stages | | | |
| Freight unit | | | |
| Freight booking | | | |

---

## Phase 1: Core model and Dispatch service

**Goal:** the local domain model, a Dispatch service with remote read plus enrichment, and every tender and award rule covered by tests.

### 1.1 Domain model: `db/schema.cds`
- [ ] Entities as in §4, namespace `tm.dispatch`: `FreightOrderDispatch`, `TenderRounds`, `CarrierOffers`, `ExecutionEvents`, `DispatchNotes`, `Carriers`, and the code lists.
- [ ] Seed data in `db/data/`:
  - `tm.dispatch-Carriers.csv` with 12 carriers, BP-style IDs, and 1–2 set to `active=false`.
  - Code lists with criticality (1 = red, 2 = yellow, 3 = green):
    - `DispatchStatus`: NEW 0, TENDERING 2, AWARDED 3, FAILED 1, CLOSED 0
    - `OfferStatus`: INVITED 2, QUOTED 3, DECLINED 1, EXPIRED 1, WON 3, LOST 0
    - `TenderModes`, `EventTypes` and `DelayReasons` as listed in §4
- [ ] Add a `_texts` / `name` column to the code lists so value helps show readable text.

### 1.2 Business rules: `srv/lib/award-rules.js` (pure, no CDS imports)
Each function takes plain objects and a `now` value, and returns `{ ok: true }` or `{ ok: false, code, message }`:
- [ ] `canStartTender(dispatch, { carriers, deadline, now })`: status is NEW or TENDERING, no other round is open, the deadline is in the future, and there is at least one carrier with no duplicates.
- [ ] `canAward({ dispatch, round, offer, now })`: the offer is QUOTED, the round is not closed, the dispatch is not already AWARDED, and in BROADCAST mode `now >= round.deadline`.
- [ ] `canSubmitQuote({ offer, round, now })`: the offer is INVITED, the round is open, `now < deadline`, the price is greater than 0, and transit hours are greater than 0.
- [ ] `canDecline({ offer, round, now })`: the offer is INVITED and the round is open.
- [ ] `canCloseRound(round)` and `canCancel(dispatch, reason)` (the reason is mandatory).
- [ ] `isExpired(deadline, now)` and `effectiveOfferStatus(offer, round, now)`: an INVITED offer after the deadline reads as EXPIRED.
- [ ] `nextRoundNumber(rounds)`.
- [ ] `test/award-rules.test.js`: one `describe` block per function, covering every branch, including the boundary where `now` equals the deadline.

### 1.3 Remote access helpers: `srv/lib/`
- [ ] `tm-client.js`: connects once to `TM_FREIGHT_ORDER` and `TM_FREIGHT_UNIT`, builds queries with an explicit `$select`, and passes `$filter`, `$top`, `$skip` and `$orderby` through from `req.query`.
- [ ] `enrich.js`: for one page of freight orders, runs **one** `SELECT … WHERE freightOrderId IN (…)` for dispatches, plus one aggregate query over rounds and offers for best quote, quote count and current deadline. It merges the results in memory. A missing dispatch reads as NEW.
- [ ] `cache.js`: a small TTL cache (about 5 minutes) for carriers and code lists.

### 1.4 `srv/dispatch-service.cds` + `.js`: `@requires: 'Dispatcher'`
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
- [ ] `test/dispatch-service.test.js` (`cds.test`, logged in as alice):
  - the list excludes orders that already have a carrier
  - enrichment values are correct, and enrichment runs in a single local query (spy on `cds.db.run`)
  - lazy creation of the dispatch record
  - every rule in 1.2 through the HTTP layer
  - the full award transaction
  - `closeRound` expiry
  - `cancelTender` with no reason is rejected

**Exit criteria:** every award rule is covered by `cds.test`, and the full tender → (quote inserted in test) → award flow passes.

---

## Phase 2: Fiori app 1, Dispatch Cockpit

**Goal:** the full tender → quote → award flow works in the UI locally.

- [ ] Generate a Fiori elements V4 **List Report + Object Page** on `DispatchService.FreightOrders` in `app/dispatch-cockpit/` (Fiori tools generator).
- [ ] `app/dispatch-cockpit/annotations.cds`:
  - `SelectionFields`: source, destination, pick-up date, dispatch status, mode of transport, `deadlineExpired`.
  - `LineItem`: order, lane, dates, status with criticality, best quote, quote count, deadline. Toolbar buttons *Start Tender* and *Cancel Tender* use `DataFieldForAction`.
  - `HeaderInfo` / `HeaderFacets`: ID, lane, dates, status, awarded carrier and price.
  - Facets: TM Data (stages, weight/volume, status), Freight Units, Tender Rounds (offers table with the *Award* inline action), Exceptions, Notes.
  - `Common.SideEffects` on actions, so status, rounds and offers refresh.
- [ ] `srv/common-annotations.cds`: value helps for Carriers (`active` only), code lists (`Common.Text`, `TextArrangement`), and currency.
- [ ] `startTender` dialog: a multi-carrier value help for the `carriers` collection parameter. **Fallback** if Fiori elements does not render collection parameters well: start the round empty, then add invited carriers as draft rows on the round and confirm with an `inviteCarriers` action.
- [ ] Until phase 3 exists, enter quotes through `test/http/tender-flow.http` (REST Client) calls.

**Exit criteria:** locally, as alice, you can start a tender, see quotes (entered through the `.http` file), award one, and see the status, price and carrier in the header.

---

## Phase 3: Tender Desk service and app 2

**Goal:** a quote entered by bob shows up for alice and can be awarded.

- [ ] `srv/tender-service.cds` + `.js`: `@requires: 'CarrierDesk'`.
  - `OpenInvitations`: projection on `CarrierOffers` where status is INVITED, the round is open and the deadline is in the future. It exposes the read-only freight order context (ID, lane, dates) and **none of the award fields**.
  - `submitQuote(price, currency, transitHours, comment)` and `decline(comment)` use `award-rules`, and `submitQuote` stamps `respondedAt`.
- [ ] `@restrict` rules: `award`, `startTender`, `closeRound` and `cancelTender` are for Dispatcher only; `submitQuote` and `decline` are for CarrierDesk only. Check that alice is refused on TenderService and bob on DispatchService.
- [ ] Generate `xs-security.json` (`cds add xsuaa`) with the three scopes and role templates, and the role collections `TM_Dispatcher`, `TM_Carrier_Desk` and `TM_Transport_Manager` (§8).
- [ ] `app/tender-desk/`: List Report + Object Page on `OpenInvitations`, sorted by deadline, with criticality on the deadline (yellow under 24 h, red when expired). The Object Page shows the order context plus *Submit Quote* and *Decline*.
- [ ] `test/tender-service.test.js`:
  - authorization matrix (alice, bob, carol × each action → 200 or 403)
  - a quote after the deadline is refused
  - expired invitations disappear from the list
  - end to end: bob submits a quote, alice awards it

**Exit criteria:** the cross-user flow passes both in the tests and manually in both apps.

---

## Phase 4: Hybrid mode and BTP deployment

**Goal:** the apps run on BTP trial against the real sandbox for every TM API that has one.

### 4.1 Hybrid
- [ ] Put `[hybrid]` credentials in `package.json` for each TM API that phase 0 marked "Yes": the sandbox base URL plus the path. The `APIKey` header comes from a git-ignored `.env` (`cds.requires.TM_FREIGHT_ORDER.credentials.headers.APIKey=…`), or from `cds bind` to the destination.
- [ ] Run `cds watch --profile hybrid`. Compare real payloads with the mocks, then fix field mappings, `$select` lists and date and time zone handling.
- [ ] Check the payload size and speed with `$top=50`. Stages and items are only expanded on the object page.

### 4.2 Production configuration
- [ ] Run `cds add hana`, then `cds add mta xsuaa destination html5-repo approuter`.
- [ ] Add `[production]` credentials for each available TM API: `destination: S4_SANDBOX` plus the path (§9). APIs without a working sandbox are **not** remote dependencies in production; handle them as §12 describes.
- [ ] In `mta.yaml`, set about 256M memory per module. The `tm-dispatch-destination` resource only binds the destination service and does **not** define `S4_SANDBOX`.
- [ ] Set up `app/router/xs-app.json` routes for the two OData services and the HTML5 repo.

### 4.3 Deploy
- [ ] In the BTP cockpit, create `S4_SANDBOX` manually and start HANA Cloud.
- [ ] Run `mbt build`, `cf login`, then `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`.
- [ ] Assign the role collections, then smoke-test both apps with two different users.

**Exit criteria:** both apps run through the approuter on BTP, freight orders come from the sandbox (or from seed data if §12's fallback applies), and a complete tender → quote → award flow works in the cloud.

---

## Phase 5: Extras (optional, real tenant)

- [ ] **`AnalyticsService`** (`@requires: 'TransportManager'`), with aggregated views for:
  - awards per carrier
  - average quotes per round
  - savings (first quote vs. awarded price)
  - on-time ratio from `ExecutionEvents`
  - average award lead time
- [ ] **App 3, Carrier Scorecard** (ALP or OVP): KPI cards and charts as in §7.
- [ ] **Work Zone** launchpad with the three apps.
- [ ] **Writeback** of the awarded carrier to `API_FREIGHTORDER`, behind the profile flag `cds.requires.tm-writeback` (off by default). Refuse writeback when the URL matches `sandbox.api.sap.com`. Only use it on a real tenant.
- [ ] **Remote Business Partner** for carrier value help, behind a profile flag. `CarrierOffers` stays unchanged.

---

## Test strategy summary

| Layer | Tool | Location | Covers |
|---|---|---|---|
| Rules | jest | `test/award-rules.test.js` | Every branch of `srv/lib/award-rules.js`, with an injected `now` |
| Services | jest + `cds.test` | `test/*-service.test.js` | HTTP-level behaviour, enrichment, transactions, authorization |
| Manual | REST Client | `test/http/*.http` | Ad-hoc flows during UI work |
| UI | Manual, per phase exit | – | The flows listed in each exit criterion |

Run all tests with `npx jest`. Run a single test with `npx jest test/<file>.test.js -t "<name>"`.

## Open decisions

| # | Decision | Decide in |
|---|---|---|
| 1 | Behaviour if `API_FREIGHTORDER` has no usable sandbox data (keep mocks on BTP, or use seed data) | Phase 0.1 |
| 2 | Collection parameter vs. `inviteCarriers` fallback for `startTender` | Phase 2 |
| 3 | Whether `closeRound` should also run automatically when a BROADCAST deadline passes and all offers have responded | Phase 1 |
