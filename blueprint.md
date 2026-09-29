# Blueprint: Freight Tendering & Carrier Performance Cockpit

**Project name:** `sap-cap-tm-dispatch-cockpit`

A full-stack SAP CAP application with SAP Fiori elements UIs, deployed to an SAP BTP **trial** account. It uses the **Transportation Management (TM)** OData V4 APIs of SAP S/4HANA Cloud Public Edition from the SAP Business Accelerator Hub. Where possible, the calls go to the Hub **sandbox**.

---

## 1. Business use case

**Scenario:** A shipper plans transports in SAP S/4HANA TM. Freight orders come out of planning **without a carrier and without a price** — they are subcontracted on the spot market. Today that step happens in mail and phone calls:

1. The dispatcher picks carriers for a freight order and asks for quotes.
2. Carriers answer with a price and a transit time, at different moments, sometimes not at all.
3. The dispatcher awards one of them, notes the agreed price, and only then maintains the carrier in TM.
4. If the transport later runs late, nobody links the delay back to the carrier who was awarded.

TM has a full tendering engine in the on-premise and private editions, but in public-cloud scope it is limited — and **spot quotes, award reasoning and carrier scoring have no home at all**. This cockpit adds exactly that layer: tender rounds, carrier offers, an award decision with an audit trail, execution exceptions, and a carrier scorecard built from the app's own history.

**Value:**
- One screen shows *"Which freight orders still have no carrier, and when does the quote deadline expire?"*
- Every award is recorded: who awarded it, at which price, against which competing quotes.
- Delays are attributed to the awarded carrier, so the next award is an informed one.

### Personas

| Persona | Needs | Fiori app |
|---|---|---|
| Dispatcher | See unassigned freight orders, launch tender rounds, compare quotes, award | App 1 – Dispatch Cockpit |
| Carrier Desk (internal agent acting for carriers) | Enter or decline the quotes that arrive by mail and phone | App 2 – Tender Desk |
| Transport Manager | KPIs: award lead time, savings vs. first quote, on-time %, carrier ranking | App 3 – Carrier Scorecard (ALP/OVP, optional) |

> **Design principle:** everything the cockpit *writes* lives in the CAP app. TM is read-only for phases 0–4. Writing the awarded carrier back into the freight order is phase 5, and never against the sandbox — see section 6.

---

## 2. APIs used

All of these are **A2X** services of SAP S/4HANA Cloud Public Edition, published on the SAP Business Accelerator Hub.

| # | API (Business Accelerator Hub) | Technical name | Protocol | Hub sandbox | Use in the app |
|---|---|---|---|---|---|
| 1 | **Freight Order (A2X)** | `CE_FREIGHTORDER_0001` | OData V4 | Yes | Main list: freight order, stages, source/destination, dates, carrier (usually empty), status |
| 2 | **Freight Unit (A2X)** | `CE_FREIGHTUNIT_0001` | OData V4 | Yes | What is actually on the truck — items, weight, volume; object-page facet and the basis for a quote |
| 3 | **Freight Booking (A2X)** | `CE_FREIGHTBOOKING_0001` | OData V4 | Yes | Ocean/air legs that a pick-up or delivery freight order belongs to; shown as context |

**Verified service paths** (sandbox base `https://sandbox.api.sap.com/s4hanacloud`, all returned rows in *Try Out*):

| Technical name | Service path |
|---|---|
| `CE_FREIGHTORDER_0001` | `/sap/opu/odata4/sap/api_freightorder/srvd_a2x/sap/freightorder/0001` |
| `CE_FREIGHTUNIT_0001` | `/sap/opu/odata4/sap/api_freightunit/srvd_a2x/sap/freightunit/0001` |
| `CE_FREIGHTBOOKING_0001` | `/sap/opu/odata4/sap/api_freightbooking/srvd_a2x/sap/freightbooking/0001` |

**Carrier master data:** `API_BUSINESS_PARTNER` has no Hub sandbox, so carriers are a **local `Carriers` entity** (section 4), seeded from CSV. It drives the carrier value help and the name/address snapshot on offers. A remote Business Partner read can be added later behind a profile flag for a real tenant.

> **Before you start — verify on the Hub, do not trust this table blindly:**
> 1. Open each API on api.sap.com and confirm it is **ACTIVE**, not deprecated.
> 2. Download the **EDMX / metadata** (API → *API Specification* → EDMX).
> 3. Note the **sandbox URL** and the exact **service path**, e.g. `/sap/opu/odata4/sap/<service group>/srvd_a2x/sap/<service definition>/0001/`.
> 4. Check whether **Try Out** (sandbox) is offered and whether it returns rows. If an API has no usable sandbox data, keep it on the mock profile (section 6) — the app is designed to work either way.
> 5. Confirm the **entity set and field names** against the EDMX. Sections 4 and 5 use readable placeholders; the real names are longer and more nested (`FreightOrder`, `FreightOrderItem`, `TransportationStage`, …).

**Edition caveat (important):** the TM OData APIs are released for **SAP S/4HANA Cloud Public Edition** only. SAP KBA 3703361 states they are *not* supported for Private Cloud and on-premise editions. If this project is ever pointed at a private-cloud system, these services will not be there and the remote layer has to be swapped for CPI/SOAP or a custom OData service. The CAP side is unaffected — only `srv/external/` and the destination change.

---

## 3. Architecture

```
 ┌──────────────── SAP BTP Trial (Cloud Foundry) ───────────────────────────┐
 │                                                                          │
 │  Browser ──► App Router (standalone, xsuaa login)                        │
 │                 │            └── serves Fiori apps from HTML5 Repo       │
 │                 ▼                                                        │
 │        CAP Service (Node.js)  ── /odata/v4/dispatch, /odata/v4/tender    │
 │          │           │                                                   │
 │          │           └──► SAP HANA Cloud (trial) — own entities          │
 │          ▼                                                               │
 │   Destination "S4_SANDBOX" (URL + APIKey header)                         │
 └──────────┼───────────────────────────────────────────────────────────────┘
            ▼
   https://sandbox.api.sap.com/s4hanacloud/... (TM A2X OData APIs)
```

- **Remote services:** `cds import` each EDMX into `srv/external/*.cds`, then call it with `cds.connect.to('TM_…')`.
- **Own persistence:** tender rounds, offers, awards and exceptions live in HANA Cloud; SQLite locally.
- **Mashup:** CAP projections join remote freight-order data with the local dispatch record, keyed by the freight order ID.

---

## 4. Domain model (CAP – `db/schema.cds`)

Local entities, namespace `tm.dispatch`:

```cds
using { cuid, managed, Currency, sap.common.CodeList } from '@sap/cds/common';

@assert.unique: { freightOrderId: [freightOrderId] }
entity FreightOrderDispatch : cuid, managed {
  freightOrderId  : String(20) not null;            // key from TM
  dispatchStatus  : Association to DispatchStatus;  // NEW | TENDERING | AWARDED | FAILED | CLOSED
  awardedCarrier  : String(10);                     // BP number of the winner
  awardedPrice    : Decimal(15,2);
  currency        : Currency;
  awardedAt       : Timestamp;
  awardedBy       : String(120);
  quoteDeadline   : Timestamp;                      // deadline of the current round
  rounds          : Composition of many TenderRounds    on rounds.parent     = $self;
  exceptions      : Composition of many ExecutionEvents on exceptions.parent = $self;
  notes           : Composition of many DispatchNotes   on notes.parent      = $self;
}

entity TenderRounds : cuid, managed {
  parent      : Association to FreightOrderDispatch;
  roundNumber : Integer;
  mode        : Association to TenderModes;     // BROADCAST | PEER | SPOT
  deadline    : Timestamp;
  closed      : Boolean default false;
  offers      : Composition of many CarrierOffers on offers.parent = $self;
}

entity CarrierOffers : cuid, managed {
  parent       : Association to TenderRounds;
  carrierId    : String(10);                    // BP number
  carrierName  : String(120);                   // snapshot from BP at invite time
  status       : Association to OfferStatus;    // INVITED | QUOTED | DECLINED | EXPIRED | WON | LOST
  price        : Decimal(15,2);
  currency     : Currency;
  transitHours : Integer;
  respondedAt  : Timestamp;
  comment      : String(255);
}

entity ExecutionEvents : cuid, managed {
  parent      : Association to FreightOrderDispatch;
  eventType   : Association to EventTypes;      // PICKED_UP | DELIVERED | DELAY | DAMAGE
  eventTime   : Timestamp;
  delayReason : Association to DelayReasons;    // TRAFFIC | WEATHER | CARRIER | SHIPPER | CUSTOMS
  delayMins   : Integer;
  comment     : String(255);
}

entity DispatchNotes : cuid, managed {
  parent : Association to FreightOrderDispatch;
  text   : String(1000);
}

// Local carrier master — stands in for API_BUSINESS_PARTNER (no Hub sandbox)
entity Carriers : managed {
  key carrierId : String(10);                   // BP-style number, matches CarrierOffers.carrierId
  name          : String(120);
  street        : String(120);
  postalCode    : String(10);
  city          : String(60);
  country       : String(3);
  email         : String(241);
  active        : Boolean default true;
}

entity DispatchStatus : CodeList { key code : String(10); criticality : Integer; }
entity TenderModes    : CodeList { key code : String(10); }
entity OfferStatus    : CodeList { key code : String(10); criticality : Integer; }
entity EventTypes     : CodeList { key code : String(12); }
entity DelayReasons   : CodeList { key code : String(10); }
```

Remote entities, imported from EDMX (exact names come from the metadata): `FreightOrder` (plus items and stages), `FreightUnit`, `FreightBooking`.

**Key rule:** the freight order ID is the only link between TM and the app. Nothing else is copied, apart from deliberate snapshots (`carrierName`) that must survive master-data changes.

**Carriers:** `Carriers` is local master data, seeded from `db/data/tm.dispatch-Carriers.csv` (10–15 carriers). Use BP-style numbers for `carrierId`, so a later switch to the remote Business Partner API on a real tenant changes only the source of the value help, not the offers or awards.

---

## 5. Services (`srv/`)

### `DispatchService` (`/odata/v4/dispatch`) – role `Dispatcher`

| Entity / Action | Source | Notes |
|---|---|---|
| `FreightOrders` (read-only) | Remote Freight Order | Custom `READ` handler delegates to TM, then enriches each row with dispatch status, best quote, quote count and deadline |
| `Dispatch` (draft-enabled) | Local `FreightOrderDispatch` | Created lazily on first open of a freight order |
| `FreightUnits` | Remote Freight Unit | Read-only facet: what is being moved |
| `Carriers` (read-only) | Local `Carriers` | Value help, filtered to `active = true`. Remote Business Partner only on a real tenant (see section 2) |
| action `startTender(mode, deadline, carriers[])` | Local | NEW → TENDERING; creates round *n+1* with one `INVITED` offer per carrier. Bound to `FreightOrders` (not `Dispatch`) so the list report toolbar can offer it; creates the dispatch if the order was never opened |
| action `award(offerId)` | Local | **Rules:** the offer must be `QUOTED`; its round must be open; in `BROADCAST` mode the deadline must have passed. Sets the offer `WON`, quoted siblings `LOST`, unanswered (`INVITED`) siblings `EXPIRED`, closes the round, and sets the dispatch `AWARDED` with price, carrier, user and timestamp. Bound to the offer, so it appears on the offer row |
| action `closeRound()` | Local | Closes the round and expires every offer still `INVITED` |
| action `cancelTender(reason)` | Local | Any status → `FAILED`, with a mandatory note. Closes an open round, so carriers can no longer quote. Bound to `FreightOrders`, like `startTender` |
| action `reportException(type, reason, minutes)` | Local | Appends an `ExecutionEvents` row |

### `TenderService` (`/odata/v4/tender`) – role `CarrierDesk`

| Entity / Action | Source | Notes |
|---|---|---|
| `OpenInvitations` | Local `CarrierOffers` + remote Freight Order | Only `INVITED` offers whose round is open and whose deadline has not passed. Adds the freight order context (lane, pick-up and delivery dates) with one TM read per page, and the countdown (deadline criticality, time left) evaluated on read. A read by key also returns an invitation that has been answered, so the object page shows its new status |
| action `submitQuote(price, currency, transitHours, comment)` | Local | `INVITED` → `QUOTED`, stamps `respondedAt`. Refused after the deadline |
| action `decline(comment)` | Local | `INVITED` → `DECLINED` |

Keep this service deliberately narrow: it is the one place a non-dispatcher writes, and `@restrict` must keep it away from the award fields.

### `AnalyticsService` (optional) – role `TransportManager`

Aggregated views: awards per carrier, average quotes per round, savings (first quote vs. awarded price), on-time ratio from `ExecutionEvents`, average award lead time.

### Handler notes

- Map OData query options (`$filter`, `$top`, `$skip`, `$orderby`) through to the remote service. Filters on local fields (`dispatchStatus`, `deadlineExpired`) are resolved locally first, into an `in` / `not in` filter on the freight order number, so paging stays correct (§12). Local fields cannot be sorted on.
- Actions run on the saved (active) dispatch only, and are refused while the dispatch is open in a draft. Saving a draft never overwrites the status, award fields or rounds, which only actions change.
- Read freight orders with an explicit `$select`. A full freight order with items, stages and locations is a heavy deep structure — expand stages only on the object page.
- Batch the local enrichment: one `SELECT … WHERE freightOrderId IN (…)` per page, never one query per row.
- Cache carriers and code lists in memory with a short TTL.
- The deadline is business logic, not a job: evaluate "expired" on read. A background expiry job is optional and out of scope on trial.
- Keep the award and deadline rules in a plain module (`srv/lib/award-rules.js`) so they can be unit-tested without a service.
- Surface every rule violation with `req.error(…)` so it lands in the Fiori message popover.

---

## 6. Local development & mocking

| Profile | Remote TM | DB |
|---|---|---|
| `development` (default `cds watch`) | **Mocked**: CAP auto-mocks the imported services from `srv/external/data/*.csv` | SQLite in memory |
| `hybrid` | **Real sandbox** for every TM API that has one: `cds bind` to the BTP destination, or a `.env` holding the API key | SQLite, or HANA via `cds bind` |
| `production` | Real sandbox via destination | HANA Cloud |

- **Mixed mode:** `cds watch` mocks every required service that has no credentials bound. In `hybrid`, bind only the APIs whose sandbox works, and the rest stay mocked automatically. **Production does not serve mocks**, so any API without a working sandbox must not be a remote dependency in production. That is why carriers are a local entity.

- Sandbox API key: log in to the Business Accelerator Hub and click *Show API Key*. Store it **only** in the BTP destination or in a git-ignored `.env`, never in the repo.
- **Treat the sandbox as read-only.** It is a shared tenant: anything written there is visible to others and gets reset. The design fits, because every write in phases 0–4 touches local entities only. Do not point phase-5 writeback at it.
- Write realistic mock CSVs: at least 30 freight orders across several lanes, some already carrying a carrier (those must be filtered out of the "to tender" list), and a few with no freight units, to prove the empty-facet case.

---

## 7. Fiori apps (`app/`)

### App 1 – Dispatch Cockpit (List Report + Object Page, Fiori elements V4)

- **List Report:** filters for source and destination location, pick-up date, dispatch status, mode of transport and "Deadline expired". Columns: freight order, lane, dates, dispatch status (criticality), best quote, number of quotes, deadline. Toolbar: *Start Tender*, *Cancel Tender*.
- **Freight order Object Page** (read-only, TM data):
  - Header: freight order ID, lane, pick-up and delivery dates, dispatch status, awarded carrier and price. Actions: *Start Tender*, *Cancel Tender*, *Open Tender*.
  - "TM Data": status, stops, weight and volume (items) from the Freight Order API.
  - "Freight Units": table from the Freight Unit API.
  - "Tender": dispatch status, deadline, best quote, number of quotes.
- **Dispatch Object Page** (draft), opened with *Open Tender*. It is a top-level route on `Dispatch`, not a sub-page of the freight order: `FreightOrders` is remote and not draft-enabled, so the local compositions cannot be read or edited through `FreightOrders('…')/dispatch`. *Open Tender* is a small TypeScript custom action (`webapp/ext/controller/OpenTender.ts`).
  - Header: dispatch status, deadline, award. Actions: *Close Round*, *Report Exception*.
  - "Tender Rounds": latest first; a row opens the round page, whose offers table has *Award* on each row.
  - "Exceptions": execution events, editable (draft).
  - "Notes": editable (draft).

### App 2 – Tender Desk (List Report + Object Page)

- **List:** open invitations sorted by deadline, with a countdown (criticality on the deadline field).
- **Object Page:** freight order context read-only, then *Submit Quote* and *Decline*. Price, currency (default EUR), transit time and comment are entered in the action's parameter dialog; no draft, because the offer's quote fields are only written by `submitQuote`.

### App 3 – Carrier Scorecard (optional: Analytical List Page or Overview Page)

- KPI cards: awarded this week, average savings %, on-time %.
- Chart: awards and win rate by carrier.
- Chart: delays by reason.

Annotations go in `app/<app>/annotations.cds`, shared value helps in `srv/common-annotations.cds`.

---

## 8. Security (`xs-security.json`)

| Role collection | Role template | Scope |
|---|---|---|
| `TM_Dispatcher` | Dispatcher | `$XSAPPNAME.Dispatcher` |
| `TM_Carrier_Desk` | CarrierDesk | `$XSAPPNAME.CarrierDesk` |
| `TM_Transport_Manager` | TransportManager | `$XSAPPNAME.TransportManager` |

Use `@requires` / `@restrict` on the services and actions — `award` is `Dispatcher` only, `submitQuote` is `CarrierDesk` only. Locally, add mock users in `.cdsrc.json` (`nag` = dispatcher, `satish` = carrier desk, `srini` = transport manager).

---

## 9. BTP trial deployment

**Prerequisites in the trial subaccount:**
- Cloud Foundry is enabled and a space exists.
- An **SAP HANA Cloud** trial instance is created and mapped to the CF space. It stops every night, so restart it before testing.
- The *Destination*, *XSUAA* and *HTML5 Application Repository* entitlements are available (they are by default on trial).
- Optional: SAP Build Work Zone, standard edition (trial) for a launchpad.

**Destination `S4_SANDBOX` (shared, subaccount level):**

Create this destination **once** in the BTP cockpit, under *Subaccount → Connectivity → Destinations*. Do not define it in this app's MTA. Any CAP app in the subaccount that is bound to a destination service instance can then use it. The URL points only at the generic `/s4hanacloud` base and each app appends its own API path, so the same destination serves any S/4HANA Cloud sandbox API. Rotating the API key then means editing a single place.

```
Name: S4_SANDBOX
Type: HTTP
URL: https://sandbox.api.sap.com/s4hanacloud
Proxy Type: Internet
Authentication: NoAuthentication
Additional properties:
  URL.headers.APIKey = <your hub API key>
  HTML5.DynamicDestination = true   (only if the UI needs direct access)
```

In `package.json` → `cds.requires`, point each `CE_FREIGHT*_0001` service at `destination: S4_SANDBOX` and its API-specific `path`:

```json
"cds": { "requires": {
  "CE_FREIGHTORDER_0001": {
    "kind": "odata",
    "model": "srv/external/CE_FREIGHTORDER_0001",
    "[production]": {
      "credentials": {
        "destination": "S4_SANDBOX",
        "path": "/sap/opu/odata4/sap/api_freightorder/srvd_a2x/sap/freightorder/0001"
      }
    }
  }
}}
```

The `sap-cap-tm-dispatch-cockpit-destination` resource in the MTA only binds the app to the Destination service. It must **not** create or overwrite `S4_SANDBOX`.

**MTA modules (`mta.yaml`, generated with `cds add mta hana xsuaa destination html5-repo approuter`):**

| Module / Resource | Type |
|---|---|
| `tm-dispatch-srv` | nodejs (CAP) |
| `tm-dispatch-db-deployer` | hdb |
| `tm-dispatch-app-content` | html5 content deployer (3 apps) |
| `tm-dispatch-approuter` | standalone approuter |
| `tm-dispatch-db` | `hana` / `hdi-shared` |
| `tm-dispatch-auth` | `xsuaa` / `application` |
| `sap-cap-tm-dispatch-cockpit-destination` | `destination` / `lite` |
| `tm-dispatch-html5-repo-host` | `html5-apps-repo` / `app-host` |

**Steps:**
1. `mbt build`
2. `cf login -a https://api.cf.<region>.hana.ondemand.com`
3. `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`
4. In the BTP cockpit, assign the role collections to your user.
5. Open the approuter URL. Optionally add the apps to Work Zone.

**Trial limits to keep in mind:** the trial memory quota is small, so use about 256M per module. Trial apps stop after inactivity, and HANA Cloud stops nightly.

---

## 10. Project structure

```
sap-cap-tm-dispatch-cockpit/
├─ app/
│  ├─ dispatch-cockpit/       # App 1 (FE V4 LROP)
│  ├─ tender-desk/            # App 2 (FE V4 LROP)
│  ├─ carrier-scorecard/      # App 3 (optional ALP/OVP)
│  └─ router/                 # approuter (xs-app.json)
├─ db/
│  ├─ schema.cds
│  └─ data/                   # code list CSVs
├─ srv/
│  ├─ external/               # imported TM EDMX → CDS + mock CSVs
│  ├─ dispatch-service.cds / .js
│  ├─ tender-service.cds / .js
│  ├─ analytics-service.cds
│  └─ lib/award-rules.js      # award + deadline logic, unit-testable on its own
├─ test/                      # jest + cds.test
├─ xs-security.json
├─ mta.yaml
└─ package.json
```

---

## 11. Implementation phases

| Phase | Deliverable | Done when |
|---|---|---|
| **0 – Setup** | `cds init`, Hub API key, EDMX downloads, `cds import` × 3 (freight order, freight unit, freight booking), carrier seed CSV, Try Out check per API | `cds watch` starts with mocked TM services and returns freight orders; sandbox availability of the three TM APIs is recorded in section 2 |
| **1 – Core model & Dispatch service** | Local schema, `DispatchService` with remote read and enrichment, `startTender` and `award` with their rules | `cds.test` covers every award rule on mock data |
| **2 – Fiori App 1** | Dispatch Cockpit LROP with tender rounds and actions | Full tender → quote → award flow works locally |
| **3 – Tender Desk + App 2** | `TenderService`, restricted roles, quote and decline | A quote entered as `satish` shows up for `nag` and can be awarded |
| **4 – Hybrid & deploy** | Destination, `cds bind`, MTA, xsuaa roles, deploy to trial | Apps run on BTP against the real sandbox for every TM API that has one |
| **5 – Extras (optional, real tenant)** | App 3 analytics, Work Zone launchpad, **writeback of the awarded carrier to `CE_FREIGHTORDER_0001`**, remote Business Partner for carriers | — |

---

## 12. Risks & open points

- **Edition:** the TM OData APIs exist for S/4HANA Cloud **Public Edition** only (KBA 3703361). Keep the remote layer isolated in `srv/external/` so it can be replaced.
- **Sandbox coverage:** `API_BUSINESS_PARTNER` has **no Hub sandbox** and is replaced by local carriers (section 2). The TM APIs may still have thin or empty sandbox data. For local runs, keep such an API on the mock profile. If `CE_FREIGHTORDER_0001` itself has no working sandbox, the phase-4 goal becomes "deployed to BTP against mocks/seed data" until a real tenant is available.
- **Entity and field names:** sections 4 and 5 use readable placeholders. Confirm all of them against each EDMX after `cds import`; the real A2X names are verbose and the freight order is deeply nested (items, stages, locations, party roles).
- **Payload size:** a freight order expanded over stages and items is large. Always `$select`, expand only on the object page, and test with `$top=50`.
- **Remote filtering and paging:** combining remote rows with local filters breaks paging. Keep local-only filters simple, or preload the dispatch keys for the current filter first.
- **Deadlines and time zones:** store every timestamp in UTC and render in user time. Expiry must be evaluated server-side, never in the UI.
- **Sandbox rate limits:** cache carriers and code lists; never call the API once per row.
- **Writeback (phase 5):** `CE_FREIGHTORDER_0001` is a genuine write API. Never point it at the sandbox, and guard it with a profile flag so a misconfigured environment cannot post into a shared tenant.
- **Trial expiry:** trial accounts expire or need extending. Keep the MTA reproducible.
