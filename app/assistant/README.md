## assistant

TM Assistant (blueprint §13, development plan phase 6.5): a UI5 freestyle chat on the A2A
agents `DispatchAgentService` (`/a2a/dispatch-agent`, `Dispatcher` role) and
`TenderAgentService` (`/a2a/tender-agent`, `CarrierDesk` role).

- **Agents:** the app reads each agent's card and shows only the agents the user may use.
  With both roles, a switch in the title changes between them; each keeps its own conversation.
- **Chat:** answers stream in and are rendered as Markdown (vendored `marked`, sanitized by
  `sap.ui.core.HTML`). Intermediate steps before a tool call are shown muted.
- **Approval:** every write action of an agent pauses the task. The app shows an approval card
  with the action and its parameters; *Approve* or *Reject* resumes the task.

The A2A client is `webapp/model/a2a.ts` (`message/stream` with a `message/send` fallback,
CSRF token, `contextId` per conversation).

### Starting the app

Start the CAP project from the repository root (`npm run watch-assistant`, or `cds watch`) and
open, as `nag` (dispatch agent) or `satish` (tender agent):

http://localhost:4004/tm.dispatch.assistant/index.html

The LLM is configured in `package.json` (`cds.requires.llm`); locally it needs
`ANTHROPIC_API_KEY` in `.env`.
