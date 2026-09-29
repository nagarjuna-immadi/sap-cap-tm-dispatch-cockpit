# Phase 3: Tender Desk service and app 2

[← Development plan](README.md) · Previous: [Phase 2](phase-2-dispatch-cockpit.md) · Next: [Phase 4](phase-4-deployment.md)

**Goal:** a quote entered by satish shows up for nag and can be awarded.

- [x] `srv/tender-service.cds` + `.js`: `@requires: 'CarrierDesk'`. Core done in phase 2 (`OpenInvitations` with freight order ID, round, mode and deadline; `submitQuote` and `decline` with award-rules). Phase 3 adds the lane and dates from TM (one `in`-filtered TM read per page, `tm-client.readFreightOrderContexts`; served without them if TM fails), and the countdown `deadlineCriticality` / `timeLeft` from `award-rules.js`. A read by key also returns an invitation that has been answered, so the object page shows the new status instead of a 404.
  - `OpenInvitations`: projection on `CarrierOffers` where status is INVITED, the round is open and the deadline is in the future. It exposes the read-only freight order context (ID, lane, dates) and **none of the award fields**.
  - `submitQuote(price, currency, transitHours, comment)` and `decline(comment)` use `award-rules`, and `submitQuote` stamps `respondedAt`.
- [x] `@restrict` rules: `award`, `startTender`, `closeRound` and `cancelTender` are for Dispatcher only; `submitQuote` and `decline` are for CarrierDesk only. Check that nag is refused on TenderService and satish on DispatchService. (Checked: 403 both ways, also for srini; see `test/http/tender-flow.http`.)
- [x] Generate `xs-security.json` (`cds add xsuaa`) with the three scopes and role templates, and the role collections `TM_Dispatcher`, `TM_Carrier_Desk` and `TM_Transport_Manager` (§8).
- [x] `app/tender-desk/`: List Report + Object Page on `OpenInvitations`, sorted by deadline, with criticality on the deadline (yellow under 24 h, red when expired). The Object Page shows the order context plus *Submit Quote* and *Decline*. Annotation-only (`app/tender-desk/annotations.cds`), no custom code; the actions are offered only while the status is `INVITED`.

**Exit criteria:** the cross-user flow (satish submits a quote, nag awards it) works manually in both apps.
