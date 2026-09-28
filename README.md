# Freight Tendering & Carrier Performance Cockpit

A full-stack **SAP CAP** (Node.js) application with **SAP Fiori elements V4** UIs, deployed to an **SAP BTP trial** account. It adds a spot-tendering and carrier-scoring layer on top of the **Transportation Management (TM)** OData V4 APIs of SAP S/4HANA Cloud Public Edition, which it reads through the SAP Business Accelerator Hub sandbox.

> **Status:** phase 1 in progress. Phase 0 (setup and mocked TM services) is done, and in phase 1 the domain model and the tender and award rules are done. The full specification is in [`blueprint.md`](blueprint.md). Implementation follows the phases listed below.

## Why

Freight orders come out of TM planning with no carrier and no price. Quotes are then collected by mail and phone, awards leave no audit trail, and delays are never linked back to the carrier that was awarded. This cockpit handles that work:

- **Tender rounds**: invite carriers to quote on a freight order, with a deadline.
- **Carrier offers**: record quotes and declines as they come in.
- **Award decision**: record who awarded, at what price, and against which competing quotes.
- **Execution exceptions**: link delays and damage to the awarded carrier.
- **Carrier scorecard**: KPIs built from the app's own history.

## Apps

| App | Persona | Purpose |
|---|---|---|
| Dispatch Cockpit | Dispatcher | Unassigned freight orders, starting tenders, comparing quotes, awarding |
| Tender Desk | Carrier Desk | Entering or declining quotes received by mail and phone |
| Carrier Scorecard *(optional)* | Transport Manager | Award lead time, savings, on-time %, carrier ranking |

## APIs used

| API | Technical name | Use |
|---|---|---|
| Freight Order (A2X) | `CE_FREIGHTORDER_0001` | Main list and object page |
| Freight Unit (A2X) | `CE_FREIGHTUNIT_0001` | What is on the truck |
| Freight Booking (A2X) | `CE_FREIGHTBOOKING_0001` | Ocean and air leg context |

TM is **read-only** for this app. Everything the cockpit writes is stored in its own database (HANA Cloud on BTP, SQLite locally). Carrier master data is a local entity because `API_BUSINESS_PARTNER` has no Hub sandbox.

> These TM APIs are released for **S/4HANA Cloud Public Edition only** (SAP KBA 3703361).

## Architecture

```
Browser ─► App Router (XSUAA) ─► CAP service (/odata/v4/dispatch, /odata/v4/tender)
                                    ├─► HANA Cloud / SQLite  (own entities)
                                    └─► Destination S4_SANDBOX ─► sandbox.api.sap.com (TM APIs)
```

## Getting started

Prerequisites: Node.js LTS and `@sap/cds-dk` (`npm i -g @sap/cds-dk`). You also need `mbt` and the `cf` CLI with the MultiApps plugin to deploy.

```bash
npm install
cds watch                    # TM APIs mocked from srv/external/data/*.csv, in-memory SQLite
```

Local mock users (defined in `.cdsrc.json`):

| User | Role |
|---|---|
| `nag` | Dispatcher |
| `satish` | CarrierDesk |
| `srini` | TransportManager |

### Against the real Hub sandbox (hybrid)

1. Log in to [api.sap.com](https://api.sap.com) and copy your API key with **Show API Key**.
2. Store the key in a git-ignored `.env`, or bind it with `cds bind`. **Never commit it.**
3. Run `cds watch --profile hybrid`. APIs with credentials call the sandbox, and the rest stay mocked.

The sandbox is a shared tenant, so treat it as **read-only**.

### Tests

```bash
npx jest                                   # all tests
npx jest test/<file>.test.js -t "<name>"   # single test
```

## Deploy to BTP trial

Prerequisites: Cloud Foundry is enabled, a HANA Cloud trial instance is mapped to the space (it stops every night, so restart it before testing), and the destination `S4_SANDBOX` has been created at subaccount level:

```
Name: S4_SANDBOX    Type: HTTP    Proxy Type: Internet    Authentication: NoAuthentication
URL:  https://sandbox.api.sap.com/s4hanacloud
Additional property: URL.headers.APIKey = <your hub API key>
```

```bash
mbt build
cf login -a https://api.cf.<region>.hana.ondemand.com
cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar
```

Then assign the role collections `TM_Dispatcher`, `TM_Carrier_Desk` and `TM_Transport_Manager` to your user in the BTP cockpit, and open the approuter URL.

## Project structure

```
app/          Fiori apps (dispatch-cockpit, tender-desk, carrier-scorecard) + approuter
db/           schema.cds + seed/code-list CSVs
srv/          services, handlers, external/ (imported TM models + mocks), lib/award-rules.js
test/         jest + cds.test
mta.yaml, xs-security.json, package.json
```

## Roadmap

| Phase | Deliverable |
|---|---|
| 0 | Project setup, EDMX import, mocked TM services |
| 1 | Domain model, Dispatch service, tender and award rules |
| 2 | Dispatch Cockpit app |
| 3 | Tender Desk service and app, roles |
| 4 | Hybrid mode and BTP deployment |
| 5 | Scorecard analytics, Work Zone, carrier writeback to TM (real tenant only) |

See [`blueprint.md`](blueprint.md) for the domain model, service contracts, business rules and risks.
