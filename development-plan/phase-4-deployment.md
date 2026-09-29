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

- [ ] In the BTP cockpit, create `S4_SANDBOX` manually and start HANA Cloud.
- [ ] Run `mbt build`, `cf login`, then `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`.
- [ ] Assign the role collections, then smoke-test both apps with two different users.

**Exit criteria:** both apps run through the approuter on BTP, freight orders come from the sandbox (or from seed data if §12's fallback applies), and a complete tender → quote → award flow works in the cloud.
