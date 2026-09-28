# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

The repo is at **pre-phase-0**: it holds only `blueprint.md` (the design spec) and `.gitignore`. There is no `package.json` or CAP project yet. `blueprint.md` is the source of truth. Read the relevant section before implementing anything, and update it when a decision changes (for example, the "Hub sandbox: To verify" column in section 2 once each API has been checked).

The app is an SAP CAP (Node.js) app with Fiori elements V4 UIs, deployed to an SAP BTP **trial** account (Cloud Foundry, HANA Cloud, XSUAA, approuter). It adds freight tendering, carrier offers, award audit and carrier scoring on top of the S/4HANA Cloud Public Edition **Transportation Management** OData V4 A2X APIs: `CE_FREIGHTORDER_0001`, `CE_FREIGHTUNIT_0001` and `CE_FREIGHTBOOKING_0001`.

## Commands (planned, per blueprint; none exist until phase 0)

- `cds watch`: local dev with the `development` profile. The TM services are auto-mocked from `srv/external/data/*.csv`, and the DB is in-memory SQLite.
- `cds watch --profile hybrid`: real Hub sandbox for any API with credentials bound (`cds bind` or a git-ignored `.env`). Unbound APIs stay mocked.
- `cds import <edmx> --as cds`: imports the TM EDMX into `srv/external/`.
- Tests use jest + `cds.test` in `test/`. To run a single test: `npx jest test/<file>.test.js -t "<test name>"`.
- Deploy: `mbt build`, then `cf login -a https://api.cf.<region>.hana.ondemand.com`, then `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`.
- Generate the MTA with `cds add mta hana xsuaa destination html5-repo approuter`.

## Architecture rules that span files

- **The freight order ID is the only link between TM and the app.** Local `FreightOrderDispatch` (namespace `tm.dispatch`) is keyed by `freightOrderId`. It is created lazily when a freight order is first opened. Nothing is copied from TM except deliberate snapshots such as `CarrierOffers.carrierName`.
- **TM is read-only in phases 0–4.** Every write (tender rounds, offers, awards, exceptions, notes) goes to local entities. Writing the awarded carrier back to `CE_FREIGHTORDER_0001` is phase 5 only. It must never target the Hub sandbox, which is a shared tenant, and it must sit behind a profile flag.
- **Carriers are a local entity** (`Carriers`, seeded from `db/data/tm.dispatch-Carriers.csv` with BP-style IDs) because `API_BUSINESS_PARTNER` has no Hub sandbox. Production does not serve mocks, so no API without a working sandbox may become a production remote dependency.
- **Remote layer isolation:** all TM coupling stays in `srv/external/` and the `cds.requires.CE_FREIGHT*_0001` entries in `package.json`. The TM APIs exist in Public Edition only (KBA 3703361), so this layer may have to be swapped out.
- **Entity and field names in the blueprint are placeholders.** Confirm the real A2X names against the imported EDMX before writing handlers or annotations.
- **`FreightOrders` READ handler (DispatchService):** pass `$filter/$top/$skip/$orderby` through to TM and always use an explicit `$select`. Expand stages and items only on the object page. Then enrich each page with **one** batched `SELECT … WHERE freightOrderId IN (…)` for dispatch status, best quote, quote count and deadline. Local-only filters are applied after enrichment, which breaks paging, so keep them simple. Cache carriers and code lists with a short TTL.
- **Business rules** (award preconditions, deadline and expiry) live in `srv/lib/award-rules.js` as plain, unit-testable functions. Award requires an offer in `QUOTED` status and an open round. In `BROADCAST` mode the deadline must also have passed. Expiry is evaluated server-side on read, not by a job and not in the UI. All timestamps are in UTC. Rule violations are reported with `req.error(…)`.
- **Services and roles:** `DispatchService` (`/odata/v4/dispatch`) is for the `Dispatcher` role. `TenderService` (`/odata/v4/tender`) is for the `CarrierDesk` role and is kept deliberately narrow; `@restrict` must keep it away from the award fields. The optional `AnalyticsService` is for `TransportManager`. Local mock users go in `.cdsrc.json`: `nag` (dispatcher), `satish` (carrier desk), `srini` (transport manager).
- **Destination `S4_SANDBOX`** is created manually at subaccount level. Its URL is the base `https://sandbox.api.sap.com/s4hanacloud` and the API key goes in the `URL.headers.APIKey` header. Each `CE_FREIGHT*_0001` service appends its own `path` under `[production].credentials`. The MTA's `tm-dispatch-destination` resource only binds the app to the destination service and must **not** create or overwrite `S4_SANDBOX`.
- **UI annotations:** put them in `app/<app>/annotations.cds`. Shared value helps go in `srv/common-annotations.cds`.

## Constraints

- Never commit the Hub API key. It belongs only in the BTP destination or in `.env` / `default-env.json`, both git-ignored.
- On trial, use about 256M memory per module. HANA Cloud trial stops every night and must be restarted before testing.
- Mock CSVs should include at least 30 freight orders across several lanes. Some should already have a carrier, and those must be filtered out of the "to tender" list. A few should have no freight units, to cover the empty-facet case.
- Ignore `blueprint-vms-ignore-this.md`. It is staged as deleted and is not part of this project.

## Working with the user

- **The user runs all development, test and deployment commands themselves, to learn.** This covers `npm`/`npx`/`node`, `cds` (init, add, import, watch, bind, deploy), `jest`, `mbt` and `cf`, and these are denied in `.claude/settings.json`. Give the exact command in a code block, say what it does and what output to look for, then wait for the user to paste the result. Other shell commands, such as read-only inspection (`ls`, `git status`, `git diff`), are fine to run.
- **Keep all Claude memory and settings in this repo, never global.** Record durable preferences and project facts in this file (or `CLAUDE.local.md` for private, uncommitted notes), and settings in `.claude/settings.json` (shared) or `.claude/settings.local.json` (private). Do not write to `~/.claude/` or the global auto-memory directory.
