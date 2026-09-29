# Phase 6: Agents and MCP servers

[← Development plan](README.md) · Previous: [Phase 5](phase-5-extras.md)

**Goal:** a dispatcher and a carrier desk user can run the tender flow by chatting with an agent. Each agent runs on top of the existing services, under the user's own roles, and every write needs the user's explicit approval. The same capabilities are also offered as MCP servers. Everything runs on BTP trial **without AI Core or Joule** (blueprint §13).

This phase does not depend on phase 5. It can be built before or after it.

## Approach in short

| Concern | Choice | Why |
| --- | --- | --- |
| MCP server | [`@cap-js/mcp`](https://cap.cloud.sap/docs/guides/protocols/mcp) (official CAP plugin, protocol `mcp` at `/mcp/<service>`) | A service becomes an MCP server by adding a protocol annotation. `@requires` and `@restrict` are enforced per user, and the tools are `describe`, `query`, `call` and optionally one tool per action. |
| Agent | [`@cap-js/agents`](https://cap.cloud.sap/docs/guides/ai/cap-agents) (official CAP plugin, `@agent`, A2A at `/a2a/<service>`) | LangGraph-based, uses the service's own MCP tools, has human-in-the-loop via `@agent.hitl`, persists conversations in the app DB, and has quotas. Node.js only, which fits this project. |
| LLM without AI Core | `cds.requires.llm.kind: "anthropic"`, which calls the Anthropic API directly with an API key | The plugin ships an `anthropic` model adapter next to `aicore` and `mock`. It reads `apiKey`/`anthropicApiUrl` from the credentials or from `ANTHROPIC_API_KEY`. The key is billed per use, so quotas are set. |
| Chat UI (local) | The plugin's chat preview at `/a2a/<service>/preview/`, plus Claude Code (or OpenCode) as the MCP client, registered automatically by the plugin's autowire | Needs no UI code, so the agents can be tuned before the UI exists. |
| Chat UI (cloud) | New UI5 freestyle app **TM Assistant** (`app/assistant/`) in the Work Zone site, which calls A2A through the approuter | The preview is a dev tool. A launchpad app reuses XSUAA login, role collections and the existing Work Zone setup. |

## 6.0 Decisions and prerequisites

- [x] **LLM account:** create an Anthropic API key (console.anthropic.com) and set a monthly spend limit there. Pick the models: `claude-haiku-4-5-20251001` for development (cheap) and `claude-sonnet-5-5` for the cloud.
- [x] **SAP API Policy (open decision 4):** the CAP agents docs say agents are for *custom* CAP services, **not** a path for agentic access to SAP application APIs (SAP API Policy §2.2.2). `DispatchService.FreightOrders` is a projection straight onto `CE_FREIGHTORDER_0001`. So the agent services below expose **no generic TM entity**: they expose local tender data plus a small, fixed freight order context (ID, lane, dates, dispatch status). Confirm this boundary before building. It also matches "TM is read-only" (§1). §2.2.2 does not say how far removed from the API an agent must be, and an agent tool that triggers a TM read is still a gray area. So also pick the source of the freight order context: (a) a live TM read in our code with a fixed `$select`, where LLM input never reaches `$filter`/`$expand`, or (b) the strictest reading, a local snapshot of those few fields on `FreightOrderDispatch` (written when a tender starts), so agent tool calls trigger no TM call at all.
- [x] **Trial quota:** the plugin docs suggest 1024M for the CAP module (LangGraph and the MCP SDK). Checked with `cf org-quota` and `cf apps`: the org quota is 4G, and only `-srv` (256M) and the approuter (256M) run; stopped apps (`-db-deployer`, `incident-management-*`) do not count. **Decision: raise `-srv` to 1024M** in 6.6. That gives 1280M running plus staging headroom during `cf deploy`, and still over 2G free.

## 6.1 Plugins and LLM configuration

- [x] `npm add @cap-js/mcp @cap-js/agents`. Check that `cds watch` still serves both OData services and that `npm test` stays green.
- [x] In `package.json` → `cds.requires.llm`:
  - `[development]`: `{ "kind": "anthropic", "model": "claude-haiku-4-5-20251001" }`. The key comes from `ANTHROPIC_API_KEY` in the git-ignored `.env`. Do **not** rely on the `auto` kind reading `~/.claude/settings.json`, because it would hide config outside the repo.
  - `[hybrid]`: same as `[development]`, because the plugin defaults `[hybrid]` to `aicore`, which trial does not have.
  - `[test]`: `{ "kind": "llm-mock" }`, so that `npm test` never calls the API and needs no key. (The plugin registers the mock kind as `llm-mock`; a bare `"mock"` does not resolve.)
  - The profiles sit at the `cds.requires` level (`"[development]": { "llm": … }`), not inside `llm`. Profile blocks inside an `llm` entry without a top-level `kind` are not resolved, and a top-level `kind` would pin `impl` to that kind in every profile.
  - Even with `kind: "anthropic"`, the plugin reads `~/.claude/settings.json` and the OpenCode config unless `ANTHROPIC_BASE_URL` is set. So `.env.example` sets `ANTHROPIC_BASE_URL=https://api.anthropic.com` next to the key.
  - `[production]`: `{ "kind": "anthropic", "model": "claude-sonnet-5-5", "vcap": { "name": "sap-cap-tm-dispatch-cockpit-llm" } }`. The credentials (`apiKey`) come from a user-provided service instance (6.6), so the key never goes into the repo or the MTA.
- [x] In `package.json` → `cds.mcp`: leave `autowire` at its default (on). On `cds watch` in the development profile it registers the MCP servers in `~/.claude.json` and `~/.config/opencode/opencode.json`; the user accepted this exception to the repo-only rule. Set `"prefix": true` (tool names like `DispatchAgentService-call` do not collide) and `"per_action_tool": true` (one tool per action gives the LLM clearer schemas).
- [x] In `cds.agents.quotas`: `maxTasksPerHour: 30`, `maxConcurrentTasksPerUser: 2`, `maxIncomingMessageLength: 4000`, `maxLLMCallTimeout: 60s`. This caps the API cost on a demo tenant.
- [x] The agents plugin depends on `@cap-js/attachments` and adds its own `cap.agent.*` tables (tasks, checkpoints). Make sure attachments use **DB storage** in production (`cds.requires.attachments.kind: "db"`), because trial has no Object Store. Then check that `cds build --production` includes the new tables in `gen/db`.
  - `@cap-js/attachments` is only a transitive dependency (of `@cap-js/agents`), and CAP loads plugins only from the app's own `dependencies`/`devDependencies`. So its runtime (upload handlers, malware scanner) and its config defaults are **not active**: the agents plugin only uses the `Attachments` aspect for `cap.agent.Tasks.inputFiles` / `outputFiles` and writes the content with a plain `INSERT`, so files land in the DB in every profile. Development needs no config.
  - Safety net anyway: `[production]` and `[hybrid]` set `"attachments": { "kind": "db", "scan": false }` at the `cds.requires` level. If `@cap-js/attachments` ever becomes a direct dependency, its defaults would switch those profiles to `kind: "standard"` (needs an `objectstore` binding) and `scan: true` with `malwareScanner-btp` (needs a bound SAP Malware Scanning Service), neither of which trial has. On a paid landscape, bind both services and drop the override.
  - Checked with `cds compile '*' --profile production -2 hana` (same model as `gen/db`): `cap.agent.Tasks`, `Tasks_inputFiles`, `Tasks_outputFiles`, `Checkpoints`, `CheckpointWrites`, `PushNotificationConfigs`, `sap.attachments.ScanStates` and `cds.outbox.Messages` are included.

## 6.2 `DispatchAgentService` (Dispatcher)

The existing services are shaped for Fiori (drafts, virtual columns, TM projections, a READ handler that maps OData query options). So the agents get **their own narrow services** that delegate to the existing ones. Rules stay in `award-rules.js` and `DispatchService`, and nothing is implemented twice.

- [ ] `srv/agents/dispatch-agent-service.cds` / `.js`: `@path: '/dispatch-agent'`, `@requires: 'Dispatcher'`, `@protocol: ['mcp']`, `@agent`, plus `@mcp.instructions`. Every element and action gets a `/** doc comment */`, because it becomes the tool description the LLM reads.
- [ ] Read-only projections for the `query` tool, local DB only: `Dispatches`, `TenderRounds`, `CarrierOffers` (with carrier name, price, transit, status), `Carriers`, `ExecutionEvents`.
- [ ] Functions that bring in the TM context through `DispatchService` (`cds.connect.to('DispatchService')`, run in the caller's `cds.context`, so the user and roles carry over):
  - `openFreightOrders(lane: String, status: String, top: Integer)`: compact rows (ID, lane, pickup and delivery, dispatch status, best quote, quote count, deadline).
  - `freightOrderSummary(freightOrderId)`: header, lane, dates, freight unit count, rounds and offers.
  - `compareOffers(freightOrderId)`: offers of the open round ranked by price and transit time, with `canAward` and the rule message from `award-rules.js`, so the agent can explain *why* an offer cannot be awarded yet.
- [ ] Actions with `@agent.hitl` (the task pauses in `input-required` until the user approves) that delegate to the existing bound actions: `startTender(freightOrderId, mode, deadline, carriers)`, `cancelTender(freightOrderId, reason)`, `closeRound(freightOrderId)`, `award(offerId)`, `reportException(freightOrderId, type, reason, minutes)`.
- [ ] Verify that `DispatchService`'s `FreightOrders` READ handler also works when called with a CQN `SELECT` from code, not only from OData. If it only reads OData query options, give `tm-client` a small CQN entry point instead of copying the logic.
- [ ] Persona: `srv/agents/dispatch/AGENTS.md` (role, tone, "always name the freight order ID", "never guess prices; read them", "state the deadline in UTC and the user's time") plus skills `skills/tendering/SKILL.md` and `skills/award/SKILL.md` (BROADCAST vs. DIRECT, award preconditions, when to close a round).

## 6.3 `TenderAgentService` (Carrier desk)

- [ ] `srv/agents/tender-agent-service.cds` / `.js`: `@path: '/tender-agent'`, `@requires: 'CarrierDesk'`, `@protocol: ['mcp']`, `@agent`. Keep it as narrow as `TenderService`: no award fields, no other carriers' prices.
- [ ] `openInvitations(carrierId: String)` delegates to `TenderService.OpenInvitations` (lane, dates, time left). `invitationDetails(offerId)` returns one invitation with its freight order context.
- [ ] `submitQuote(offerId, price, currency, transitHours, comment)` and `decline(offerId, comment)` with `@agent.hitl`, delegating to the `TenderService` actions.
- [ ] Persona `srv/agents/tender/AGENTS.md` plus skill `skills/quoting/SKILL.md` (confirm the price and currency back to the user before submitting, and warn when less than 24 h is left).

## 6.4 Local verification

- [ ] Run `cds watch`. The log lists `/mcp/dispatch-agent`, `/a2a/dispatch-agent`, `/mcp/tender-agent` and `/a2a/tender-agent`.
- [ ] `test/http/agents.http`: MCP `initialize` plus `tools/list` as `nag` and as `satish` (each only sees their own service, and the other gets 403). Also A2A `message/send` with a simple question.
- [ ] Chat preview at `/a2a/dispatch-agent/preview/` (as `nag`) and `/a2a/tender-agent/preview/` (as `satish`).
- [ ] After `cds watch`, check that autowire registered both MCP servers in Claude Code (`claude mcp list`) and that a tool call runs as a mocked user. If the entries lack auth for the mocked users, add the basic-auth header (`nag`/`satish`, no password) to the autowired entry.
- [ ] Keep `npm test` green with `llm: mock`. Add no new tests except, if needed, one for the delegation from agent actions to `DispatchService` (tricky because of the user context).

**Scenario (exit check for 6.2–6.4):**
1. `nag`: "Which freight orders from lane X still need a carrier? Start a broadcast tender on the first one to all carriers, deadline in 2 minutes." → the agent pauses for approval → approve → the round appears in the Dispatch Cockpit.
2. `satish` (tender agent): "Show my open invitations and quote 1200 EUR, 36 h on the first one." → approve → the quote appears in the Tender Desk.
3. `nag`, after the deadline: "Compare the offers and award the cheapest." → the agent explains the ranking, pauses, then awards on approval. The award audit fields show `nag`.

## 6.5 Chat UI: TM Assistant (`app/assistant/`)

- [ ] UI5 freestyle app (not Fiori elements), `sap.f.DynamicPage` with a message list, an input and a send button. Answers are rendered as Markdown. The agent is picked by the user's role: Dispatch assistant, Tender assistant, or both if the user has both roles. The app reads each agent's card and hides agents that return 403.
- [ ] A2A client in `webapp/model/a2a.js`: JSON-RPC `message/stream` (SSE) with a fallback to `message/send`. Keep the `contextId` per conversation. For `input-required`, render an **approval card** (action name, parameters, *Approve*/*Reject*) and resume the task with the decision.
- [ ] Relative data source URIs (`a2a/...`), as in the other apps. Add the `/tm.dispatch.assistant` prefix to the root `server.js` for local `cds watch`, and add a `watch-assistant` npm script.
- [ ] `manifest.json`: `sap.cloud.service: sapcaptmdispatchcockpit.service` and the inbound `Assistant-chat` (title "TM Assistant").
- [ ] `app/router/xs-app.json`: route `^/a2a/(.*)$` → `srv-api`, `authenticationType: xsuaa`, `csrfProtection: true` (the app fetches the token first). The `/mcp` routes are **not** added to the approuter (see 6.7).

## 6.6 Deployment (commands run by the user)

- [ ] `mta.yaml`: add the `assistant` html5 module and its zip to the app deployer. Raise the `-srv` memory to 1024M (see 6.0). Add the resource `sap-cap-tm-dispatch-cockpit-llm` (`org.cloudfoundry.existing-service`) and require it in `-srv`.
- [ ] Commands for the user, in order:
  1. `cf create-user-provided-service sap-cap-tm-dispatch-cockpit-llm -p '{"apiKey":"<anthropic key>"}'`: creates the key holder once. It survives redeploys and is never in git.
  2. `mbt build`
  3. `cf deploy mta_archives/sap-cap-tm-dispatch-cockpit_1.0.0.mtar`
- [ ] Work Zone: refresh the HTML5 Apps provider, add **TM Assistant** to the `TM Dispatch` group and the Everyone role, then check it in the site.
- [ ] Check that the approuter passes SSE through without buffering (the answer should appear gradually). If it does not, the app falls back to `message/send`.

**Exit criteria:** the three-step scenario from 6.4 works in the Work Zone site through **TM Assistant**. It runs as a user with `TM_Dispatcher` and, after removing that role collection and logging in again, as `TM_Carrier_Desk`. The SS user has all three collections (see `CLAUDE.local.md`). No write happens without approval, and `npm test` is green.

## 6.7 Optional: external MCP clients against BTP

- [ ] Clients such as Claude Desktop/claude.ai connectors or VS Code need the MCP OAuth flow (protected-resource metadata, and usually dynamic client registration). XSUAA offers no dynamic client registration, so either register a fixed XSUAA client for one named client, or put SAP Cloud Identity Services (IAS) in front. Decide only if this is needed; locally (6.4) the MCP servers already work.
- [ ] Never expose `/mcp` in the cloud with a technical (client-credentials) user, because that would bypass the per-user roles.
