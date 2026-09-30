/**
 * Error texts for the agent services (development plan 6.2 / 6.3).
 *
 * CAP's input validation errors (@mandatory, wrong type) carry only a code; the text is
 * added in the OData error response. MCP and A2A report err.message, so without this the
 * LLM gets "undefined" and cannot correct the call. Register it with
 * `this.on('error', resolveMessages)` in the agent service.
 */
import cds from '@sap/cds'

/** Resolves the text of every error without one, with the parameter name appended. */
export function resolveMessages (err) {
  for (const e of [err, ...(err.details ?? [])]) {
    if (e.message || !e.code) continue
    const locale = cds.context?.locale || cds.i18n.default_language
    const text = cds.i18n.messages.at(e.code, locale, e.args) ?? e.code
    e.message = e.target ? `${text} (${e.target})` : text
  }
}
