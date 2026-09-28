# Phase 5: Extras (optional, real tenant)

[← Development plan](README.md) · Previous: [Phase 4](phase-4-deployment.md)

- [ ] **`AnalyticsService`** (`@requires: 'TransportManager'`), with aggregated views for:
  - awards per carrier
  - average quotes per round
  - savings (first quote vs. awarded price)
  - on-time ratio from `ExecutionEvents`
  - average award lead time
- [ ] **App 3, Carrier Scorecard** (ALP or OVP): KPI cards and charts as in §7.
- [ ] **Work Zone** launchpad with the three apps.
- [ ] **Writeback** of the awarded carrier to `CE_FREIGHTORDER_0001`, behind the profile flag `cds.requires.tm-writeback` (off by default). Refuse writeback when the URL matches `sandbox.api.sap.com`. Only use it on a real tenant.
- [ ] **Remote Business Partner** for carrier value help, behind a profile flag. `CarrierOffers` stays unchanged.
