// CAP loads only the .cds files directly in srv/, so the agent services in srv/agents/<name>/
// are pulled in from here (as app/services.cds does for the UI annotations).
using from './agents/dispatch/dispatch-agent-service';
using from './agents/tender/tender-agent-service';
