# Phase 2: Fiori app 1, Dispatch Cockpit

[← Development plan](README.md) · Previous: [Phase 1](phase-1-core-model.md) · Next: [Phase 3](phase-3-tender-desk.md)

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

**Exit criteria:** locally, as nag, you can start a tender, see quotes (entered through the `.http` file), award one, and see the status, price and carrier in the header.
