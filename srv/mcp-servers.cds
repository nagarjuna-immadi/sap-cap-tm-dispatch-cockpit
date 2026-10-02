// CAP loads only the .cds files directly in srv/, so the MCP server services in
// srv/mcp-servers/ are pulled in from here (as srv/agents.cds does for the agents).
using from './mcp-servers/dispatch-mcp-server';
using from './mcp-servers/tender-mcp-server';
