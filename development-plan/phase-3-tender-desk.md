# Phase 3: Tender Desk service and app 2

[← Development plan](README.md) · Previous: [Phase 2](phase-2-dispatch-cockpit.md) · Next: [Phase 4](phase-4-deployment.md)

**Goal:** a quote entered by satish shows up for nag and can be awarded.

- [ ] `srv/tender-service.cds` + `.js`: `@requires: 'CarrierDesk'`.
  - `OpenInvitations`: projection on `CarrierOffers` where status is INVITED, the round is open and the deadline is in the future. It exposes the read-only freight order context (ID, lane, dates) and **none of the award fields**.
  - `submitQuote(price, currency, transitHours, comment)` and `decline(comment)` use `award-rules`, and `submitQuote` stamps `respondedAt`.
- [ ] `@restrict` rules: `award`, `startTender`, `closeRound` and `cancelTender` are for Dispatcher only; `submitQuote` and `decline` are for CarrierDesk only. Check that nag is refused on TenderService and satish on DispatchService.
- [ ] Generate `xs-security.json` (`cds add xsuaa`) with the three scopes and role templates, and the role collections `TM_Dispatcher`, `TM_Carrier_Desk` and `TM_Transport_Manager` (§8).
- [ ] `app/tender-desk/`: List Report + Object Page on `OpenInvitations`, sorted by deadline, with criticality on the deadline (yellow under 24 h, red when expired). The Object Page shows the order context plus *Submit Quote* and *Decline*.
- [ ] `test/tender-service.test.js`:
  - authorization matrix (nag, satish, srini × each action → 200 or 403)
  - a quote after the deadline is refused
  - expired invitations disappear from the list
  - end to end: satish submits a quote, nag awards it

**Exit criteria:** the cross-user flow passes both in the tests and manually in both apps.
