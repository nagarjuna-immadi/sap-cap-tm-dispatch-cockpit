# Phase 2: Fiori app 1, Dispatch Cockpit

[← Development plan](README.md) · Previous: [Phase 1](phase-1-core-model.md) · Next: [Phase 3](phase-3-tender-desk.md)

**Goal:** the full tender → quote → award flow works in the UI locally.

- [x] Generate a Fiori elements V4 **List Report + Object Page** on `DispatchService.FreightOrders` in `app/dispatch-cockpit/` (Fiori tools generator).
- [x] `app/dispatch-cockpit/annotations.cds` (object page split into freight order → Dispatch → tender round pages, and `startTender`/`cancelTender` moved to `FreightOrders`; see blueprint §5 and §7):
  - `SelectionFields`: source, destination, pick-up date, dispatch status, mode of transport, `deadlineExpired`. **Open:** source, destination and pick-up date are derived from the stops and not filterable yet; they need a stop filter in the `FreightOrders` READ handler.
  - `LineItem`: order, lane, dates, status with criticality, best quote, quote count, deadline. Toolbar buttons *Start Tender* and *Cancel Tender* use `DataFieldForAction`.
  - `HeaderInfo` / `HeaderFacets`: ID, lane, dates, status, awarded carrier and price.
  - Facets: TM Data (stages, weight/volume, status), Freight Units, Tender Rounds (offers table with the *Award* inline action), Exceptions, Notes.
  - `Common.SideEffects` on actions, so status, rounds and offers refresh.
- [x] `srv/common-annotations.cds`: value helps for Carriers (`active` only), code lists (`Common.Text`, `TextArrangement`), and currency.
- [x] `startTender` dialog: a multi-carrier value help for the `carriers` collection parameter (`Collection(Edm.String)` with `Common.ValueList` on `Carriers`, in `srv/common-annotations.cds`; UI5 1.152 renders it as a multi-value field, so the fallback is not needed). **Fallback** if Fiori elements does not render collection parameters well: start the round empty, then add invited carriers as draft rows on the round and confirm with an `inviteCarriers` action.
- [x] Until phase 3 exists, enter quotes through `test/http/tender-flow.http` (REST Client) calls. They go to the core of `TenderService` (`OpenInvitations`, `submitQuote`, `decline`), pulled forward from phase 3 step 1.

**Exit criteria:** locally, as nag, you can start a tender, see quotes (entered through the `.http` file), award one, and see the status, price and carrier in the header.
