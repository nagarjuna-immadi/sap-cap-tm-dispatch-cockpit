# Phase 4: Hybrid mode and BTP deployment

[← Development plan](README.md) · Previous: [Phase 3](phase-3-tender-desk.md) · Next: [Phase 5](phase-5-extras.md)

**Goal:** the apps run on BTP trial against the real sandbox for every TM API that has one.

## 4.1 Hybrid

- [x] Put `[hybrid]` credentials in `package.json` for each TM API that phase 0 marked "Yes": the sandbox base URL plus the path. The `APIKey` header comes from a git-ignored `.env`, one line per service and scoped to the profile (`cds.requires.CE_FREIGHTORDER_0001.[hybrid].credentials.headers.APIKey=…`) so that `cds watch` without a profile keeps mocking. `cds bind` to the destination is the alternative.
- [x] Run `cds watch --profile hybrid`. Compare real payloads with the mocks, then fix field mappings, `$select` lists and date and time zone handling.
- [x] Check the payload size and speed with `$top=50`. Stages and items are only expanded on the object page.

## 4.2 Production configuration

- [x] Run `cds add hana`, then `cds add mta xsuaa destination html5-repo approuter`.
- [x] Add `[production]` credentials for each available TM API: `destination: S4_SANDBOX` plus the path (§9). APIs without a working sandbox are **not** remote dependencies in production; handle them as §12 describes. (All three TM APIs have a working sandbox, so the §12 fallback is not needed.)
- [x] In `mta.yaml`, set about 256M memory per module. The `sap-cap-tm-dispatch-cockpit-destination` resource only binds the destination service and does **not** define `S4_SANDBOX`.
- [x] Set up `app/router/xs-app.json` routes for the two OData services and the HTML5 repo.

## 4.3 Deploy

- [x] In the BTP cockpit, create `S4_SANDBOX` manually and start HANA Cloud.
- [x] Run `mbt build`, `cf login`, then `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`.

## 4.4 Work Zone preparation (tiles)

- [x] Run `cds add workzone-standard`. It adds `sap.cloud.service` (`sapcaptmdispatchcockpit.service`) to both manifests, the `srv-api` destination to the app deployer, and the destinations module (HTML5 repo host and XSUAA `OAuth2UserTokenExchange`). Change its `content.instance` to `content.subaccount`, because Work Zone's HTML5 Apps provider only reads subaccount destinations; `existing_destinations_policy: update` only touches these two. `S4_SANDBOX` is not touched.
- [x] Give each app its own `crossNavigation` inbound with a title, a subtitle (`flpSubtitle` in i18n) and an icon: `FreightOrder-dispatch` (Dispatch Cockpit) and `FreightTender-quote` (Tender Desk). The generator gave both apps the same `tender-desk-display` intent, which would have clashed.
- [x] Make the `dataSources` URIs relative (`odata/v4/...`) so that they resolve under the managed approuter. The root `server.js` strips the `/tm.dispatch.<app>` prefix so local `cds watch` still works.
- [x] Redeploy (`mbt build`, `cf deploy …`), then check that both apps are listed under **HTML5 → Application Repository** in the BTP cockpit.
- [x] In Work Zone, open **Channel Manager** and refresh the **HTML5 Apps** provider.
- [x] In **Content Manager → Content Explorer → HTML5 Apps**, add both apps.
- [x] In **My Content**, create the group `TM Dispatch` with both apps, and assign both apps to the **Everyone** role. That role only controls whether the tiles are visible. Data access is still enforced by `@restrict` and the role collections.
- [x] In the **Site Directory**, create the site `TM Dispatch Cockpit` and open it. Check that both tiles launch, as `nag` (`TM_Dispatcher`) and as `satish` (`TM_Carrier_Desk`). Log out and back in after changing roles.
- [x] Assign the role collections, then smoke-test both apps with two different users.

**Exit criteria:** both apps run through the approuter on BTP, freight orders come from the sandbox (or from seed data if §12's fallback applies), and a complete tender → quote → award flow works in the cloud.
