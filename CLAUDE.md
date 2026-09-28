# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

**Phase 1 (core model and Dispatch service) is in progress**: 1.1 `db/schema.cds` (with seed data) and 1.2 `srv/lib/award-rules.js` (with `test/award-rules.test.js`) are done, and 1.3 remote access helpers are next. The three TM services are imported into `srv/external/` with generated mock CSVs, and the mocked users are in `.cdsrc.json`. There is no `srv` service or `app/` yet.

- `blueprint.md` is the design spec (the **what** and **why**) and the source of truth. Read the relevant section before implementing anything, and update it when a decision changes.
- `development-plan.md` is the build plan (the **how** and **in which order**), with a checkbox per step. Tick items off as they are done. It also holds the **real TM entity and field names** table (under phase 0), which replaces the blueprint's placeholders.
- `README.md` is the public overview. Keep its status line in step with the plan.

The app is an SAP CAP (Node.js) app with Fiori elements V4 UIs, deployed to an SAP BTP **trial** account (Cloud Foundry, HANA Cloud, XSUAA, approuter). It adds freight tendering, carrier offers, award audit and carrier scoring on top of the S/4HANA Cloud Public Edition **Transportation Management** OData V4 A2X APIs: `CE_FREIGHTORDER_0001`, `CE_FREIGHTUNIT_0001` and `CE_FREIGHTBOOKING_0001`.

## Commands

The project is an ES module (`"type": "module"` in `package.json`), so use `import`/`export` in `.js` files and tests.

- `cds watch` (or `npm run watch`): local dev with the `development` profile. The TM services are auto-mocked from `srv/external/data/*.csv`, and the DB is in-memory SQLite.
- `node scripts/gen-mock-data.js [--base YYYY-MM-DD]`: regenerates the TM mock CSVs. Dates are relative to the base date (default: today, UTC), so re-run it when the dates get stale. UUIDs are deterministic.
- `npm test`: runs jest through `node --experimental-vm-modules` (needed for ESM). To run a single test: `npm test -- test/<file>.test.js -t "<test name>"`. Tests use jest + `cds.test` in `test/`.
- `cds import srv/external/<API>.edmx --as cds`: re-imports a TM service. **After every re-import** of `CE_FREIGHTORDER_0001` or `CE_FREIGHTBOOKING_0001`, remove `default null` from the `TransportationOrder` parameter of `CreateFreightOrder` / `CreateFreightBooking`, because the compiler rejects `not null default null`.
- Planned (phase 4): `cds watch --profile hybrid` uses the real Hub sandbox for any API with credentials bound (`cds bind` or a git-ignored `.env`); unbound APIs stay mocked. Generate the MTA with `cds add hana`, then `cds add mta xsuaa destination html5-repo approuter`. Deploy with `mbt build`, then `cf login -a https://api.cf.<region>.hana.ondemand.com`, then `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`.

## Architecture rules that span files

- **The freight order ID is the only link between TM and the app.** Local `FreightOrderDispatch` (namespace `tm.dispatch`) is keyed by `freightOrderId`. It is created lazily when a freight order is first opened. Nothing is copied from TM except deliberate snapshots such as `CarrierOffers.carrierName`.
- **TM is read-only in phases 0–4.** Every write (tender rounds, offers, awards, exceptions, notes) goes to local entities. Writing the awarded carrier back to `CE_FREIGHTORDER_0001` is phase 5 only. It must never target the Hub sandbox, which is a shared tenant, and it must sit behind a profile flag.
- **Carriers are a local entity** (`Carriers`, seeded from `db/data/tm.dispatch-Carriers.csv` with BP-style IDs) because `API_BUSINESS_PARTNER` has no Hub sandbox. Production does not serve mocks, so no API without a working sandbox may become a production remote dependency.
- **Remote layer isolation:** all TM coupling stays in `srv/external/` and the `cds.requires.CE_FREIGHT*_0001` entries in `package.json`. The TM APIs exist in Public Edition only (KBA 3703361), so this layer may have to be swapped out.
- **Entity and field names in the blueprint are placeholders.** Use the real names from the table in `development-plan.md` (phase 0), and check the imported `srv/external/*.cds` for anything not listed there. Key facts:
  - Every TM object keys on a UUID (`TransportationOrderUUID`). `FreightOrderDispatch.freightOrderId` stores the readable `TransportationOrder` number, and TM is looked up by it with `$filter`.
  - "No carrier yet" is `Carrier eq ''`, not `null` (the field is `not null`).
  - Locations and dates are on `_FreightOrderStop` (lane = first and last stop), so the list read needs `$expand=_FreightOrderStop($select=…)`. Stages are nested under stops, not under the header.
  - A freight unit has no freight order reference. Find a freight order's units through `FreightOrderItem.FreightUnitUUID`, then read `FreightUnit` with an `in` filter.
- **`FreightOrders` READ handler (DispatchService):** pass `$filter/$top/$skip/$orderby` through to TM and always use an explicit `$select`. Expand items and stages only on the object page. Then enrich each page with **one** batched `SELECT … WHERE freightOrderId IN (…)` for dispatch status, plus one aggregate over rounds and offers for best quote, quote count and deadline. A missing dispatch reads as `NEW`. For filters on local fields (`dispatchStatus`, `deadlineExpired`), pre-select the matching freight order IDs locally and pass them to TM as an `in` filter, so paging stays correct. Cache carriers and code lists with a short TTL.
- **Business rules** (award preconditions, deadline and expiry) live in `srv/lib/award-rules.js` as plain, unit-testable functions. Award requires an offer in `QUOTED` status and an open round. In `BROADCAST` mode the deadline must also have passed. Expiry is evaluated server-side on read, not by a job and not in the UI. All timestamps are in UTC. Rule violations are reported with `req.error(…)`.
- **Services and roles:** `DispatchService` (`/odata/v4/dispatch`) is for the `Dispatcher` role. `TenderService` (`/odata/v4/tender`) is for the `CarrierDesk` role and is kept deliberately narrow; `@restrict` must keep it away from the award fields. The optional `AnalyticsService` is for `TransportManager`. Local mock users go in `.cdsrc.json`: `nag` (dispatcher), `satish` (carrier desk), `srini` (transport manager).
- **Destination `S4_SANDBOX`** is created manually at subaccount level. Its URL is the base `https://sandbox.api.sap.com/s4hanacloud` and the API key goes in the `URL.headers.APIKey` header. Each `CE_FREIGHT*_0001` service appends its own `path` under `[production].credentials`. The MTA's `tm-dispatch-destination` resource only binds the app to the destination service and must **not** create or overwrite `S4_SANDBOX`.
- **UI annotations:** put them in `app/<app>/annotations.cds`. Shared value helps go in `srv/common-annotations.cds`.

## Constraints

- Never commit the Hub API key. It belongs only in the BTP destination or in `.env` / `default-env.json`, both git-ignored.
- On trial, use about 256M memory per module. HANA Cloud trial stops every night and must be restarted before testing.
- Mock CSVs must keep at least 30 freight orders across several lanes (currently 32 orders on 6 lanes). Some already have a carrier (7, with IDs from `10300001`–`10300012`, which must match the `Carriers` seed), and those must be filtered out of the "to tender" list. A few (3) have no freight units, to cover the empty-facet case. Change the data through `scripts/gen-mock-data.js`, not by hand-editing the CSVs.
- In CSVs, CAP reads an empty cell as `NULL`, so a `not null` string that should be empty (such as an unassigned `Carrier`) is written as a quoted `""`.
- Development happens directly on `main` (the user's choice from phase 1 on); do not create or switch branches. Commit a phase as done only once its exit criteria pass and `npm test` is green.

## Working with the user

- **The user runs all development, test and deployment commands themselves, to learn.** This covers `npm`/`npx`/`node`, `cds` (init, add, import, watch, bind, deploy), `jest`, `mbt` and `cf`, and these are denied in `.claude/settings.json`. Give the exact command in a code block, say what it does and what output to look for, then wait for the user to paste the result. Other shell commands, such as read-only inspection (`ls`, `git status`, `git diff`), are fine to run.
- **Keep all Claude memory and settings in this repo, never global.** Record durable preferences and project facts in this file (or `CLAUDE.local.md` for private, uncommitted notes), and settings in `.claude/settings.json` (shared) or `.claude/settings.local.json` (private). Do not write to `~/.claude/` or the global auto-memory directory.
