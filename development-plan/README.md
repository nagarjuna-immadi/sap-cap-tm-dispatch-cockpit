# Development Plan: Freight Tendering & Carrier Performance Cockpit

This is the step-by-step build plan for `sap-cap-tm-dispatch-cockpit`. The **what** and **why** are in [`blueprint.md`](../blueprint.md). This plan is the **how** and **in which order**. Section references (§n) point to the blueprint.

## Phases

| Phase | Document | Goal |
| --- | --- | --- |
| 0 | [Setup and API verification](phase-0-setup.md) | A CAP project that starts with mocked TM services and returns freight orders. Also holds the **real TM names** table. |
| 1 | [Core model and Dispatch service](phase-1-core-model.md) | The local domain model, a Dispatch service with remote read plus enrichment, and the tender and award rules enforced on every action. |
| 2 | [Fiori app 1, Dispatch Cockpit](phase-2-dispatch-cockpit.md) | The full tender → quote → award flow works in the UI locally. |
| 3 | [Tender Desk service and app 2](phase-3-tender-desk.md) | A quote entered by satish shows up for nag and can be awarded. |
| 4 | [Hybrid mode and BTP deployment](phase-4-deployment.md) | The apps run on BTP trial against the real sandbox for every TM API that has one. |
| 5 | [Extras (optional, real tenant)](phase-5-extras.md) | Analytics, scorecard, launchpad, writeback, remote Business Partner. |

## Ground rules

- **Work on `main`.** Phase 0 used a `phase-0-setup` branch; from phase 1 on, development happens directly on `main`. A phase counts as done when its exit criteria pass and `npm test` is green.
- **Tests stay light (user's choice, to speed up development).** Existing tests must keep passing, but new tests are not written by default. Verify new work manually with `cds watch` and `test/http/*.http` files. Add a test only for tricky logic or when asked.
- **The mock profile always works.** `cds watch` with no credentials must keep serving the full app after every phase.
- **TM stays read-only** until phase 5, and phase 5 writeback never targets the sandbox (§1, §6).
- **Field names:** the blueprint uses placeholder names (§2, §12). After `cds import`, use the real EDMX names everywhere (see the table in [phase 0](phase-0-setup.md#real-tm-names)).
- **Timestamps** are stored in UTC. "Expired" is always decided on the server by comparing with an injected `now`.

## Test strategy summary

| Layer | Tool | Location | Covers |
| --- | --- | --- | --- |
| Rules | jest | `test/award-rules.test.js` | Every branch of `srv/lib/award-rules.js`, with an injected `now` |
| Services | jest + `cds.test` | `test/*-service.test.js` | Optional: only for tricky behaviour, or when asked |
| Manual | REST Client | `test/http/*.http` | Main check for new service work and ad-hoc flows during UI work |
| UI | Manual, per phase exit | – | The flows listed in each exit criterion |

Run all tests with `npx jest`. Run a single test with `npx jest test/<file>.test.js -t "<name>"`.

## Open decisions

| # | Decision | Decide in |
| --- | --- | --- |
| 1 | Behaviour if `CE_FREIGHTORDER_0001` has no usable sandbox data (keep mocks on BTP, or use seed data) | Phase 0.1 |
| 2 | Collection parameter vs. `inviteCarriers` fallback for `startTender` | Phase 2 |
| 3 | Whether `closeRound` should also run automatically when a BROADCAST deadline passes and all offers have responded | Phase 1 |
