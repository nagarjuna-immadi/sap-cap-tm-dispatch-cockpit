/**
 * Filters on local-only elements of a remote entity (blueprint §12, development plan 1.4).
 *
 * TM cannot filter on dispatchStatus or deadlineExpired, and filtering after the remote
 * read would break paging. So the incoming `$filter` is split into its top-level `and`
 * parts: parts on TM elements go to TM unchanged; parts on local elements are evaluated
 * here against the local dispatch records, and come back as a list of freight order
 * numbers that TM then filters on (`in` / `not in`). A part that mixes both kinds (for
 * example `dispatchStatus eq 'NEW' or TransportationMode eq '01'`) is rejected.
 *
 * Pure: CQN token lists in, plain values out; no CDS imports.
 */

export class FilterError extends Error {}

// --- split --------------------------------------------------------------------------

/** Top-level tokens split on `and`; a top-level `or` keeps the expression whole. */
const conjuncts = tokens => {
  if (tokens.includes('or')) return [tokens]
  const parts = [[]]
  for (const t of tokens) t === 'and' ? parts.push([]) : parts.at(-1).push(t)
  // `(a and b)` is the same as `a and b`: unwrap and-only brackets
  return parts.flatMap(p => (p.length === 1 && p[0].xpr ? conjuncts(p[0].xpr) : [p]))
}

/** Every element name referenced in a token list. */
export const refsOf = tokens => {
  const names = new Set()
  const walk = t => {
    if (Array.isArray(t)) return t.forEach(walk)
    if (!t || typeof t !== 'object') return
    if (t.ref) names.add(t.ref[0]?.id ?? t.ref[0])
    ;[t.xpr, t.args, t.list].forEach(x => x && walk(x))
  }
  walk(tokens)
  return names
}

const join = parts => parts.length
  ? parts.flatMap((p, i) => (i ? ['and', { xpr: p }] : [{ xpr: p }]))
  : undefined

/**
 * Splits a where clause into `{ remote, local }` token lists (either may be undefined).
 * @param {Array} where        CQN where tokens of the incoming query
 * @param {string[]} localNames  elements that exist only locally
 * @throws {FilterError} when a part combines local and remote elements
 */
export const splitWhere = (where, localNames) => {
  if (!where?.length) return {}
  const local = [], remote = []
  for (const part of conjuncts(where)) {
    const refs = [...refsOf(part)]
    const isLocal = refs.map(r => localNames.includes(r))
    if (isLocal.length && isLocal.every(Boolean)) local.push(part)
    else if (isLocal.some(Boolean))
      throw new FilterError(`A filter on ${refs.filter(r => localNames.includes(r)).join(', ')} cannot be combined with other fields through 'or' or 'not'`)
    else remote.push(part)
  }
  return { remote: join(remote), local: join(local) }
}

// --- evaluate -----------------------------------------------------------------------

const COMPARE = {
  '=': (a, b) => a === b,
  '==': (a, b) => a === b,
  '!=': (a, b) => a !== b,
  '<>': (a, b) => a !== b,
  '<': (a, b) => a < b,
  '>': (a, b) => a > b,
  '<=': (a, b) => a <= b,
  '>=': (a, b) => a >= b,
}

/**
 * Evaluates a where token list against one plain record. Supports and / or / not,
 * brackets, comparisons, `in (…)` and a bare boolean element; anything else throws.
 */
export const matches = (tokens, row) => {
  let i = 0
  const peek = () => tokens[i]
  const operand = t => {
    if (t?.ref) return row[t.ref[0]] ?? null
    if (t && 'val' in t) return t.val
    if (t?.list) return t.list.map(operand)
    throw new FilterError(`Unsupported filter expression on a local field: ${JSON.stringify(t)}`)
  }
  const primary = () => {
    const t = tokens[i++]
    if (t?.xpr) return matches(t.xpr, row)
    const op = peek()
    if (op === 'in' || (op === 'not' && tokens[i + 1] === 'in')) {
      i += op === 'in' ? 1 : 2
      const hit = operand(tokens[i++]).includes(operand(t))
      return op === 'in' ? hit : !hit
    }
    if (op in COMPARE) {
      i++
      return COMPARE[op](operand(t), operand(tokens[i++]))
    }
    return operand(t) === true   // bare boolean element
  }
  const not = () => (peek() === 'not' ? (i++, !not()) : primary())
  const and = () => { let v = not(); while (peek() === 'and') { i++; v = not() && v } return v }
  const or = () => { let v = and(); while (peek() === 'or') { i++; v = and() || v } return v }
  const result = or()
  if (i < tokens.length) throw new FilterError(`Unsupported filter expression on a local field near '${tokens[i]}'`)
  return result
}

// --- resolve ------------------------------------------------------------------------

/**
 * Turns a local condition into an id restriction for the remote read.
 *
 * Only freight orders with a local record can be listed by id; all others share one
 * default value set (`fallback`, e.g. dispatchStatus NEW). If the fallback matches, the
 * result is everything except the records that do not match (`excludeIds`); otherwise
 * it is only the records that match (`onlyIds`).
 *
 * @param {Array} local       where tokens on local elements (from splitWhere)
 * @param {object[]} records  local values per freight order, each with `id`
 * @param {object} fallback   the values of a freight order without a local record
 * @returns {{ onlyIds?: string[], excludeIds?: string[] }}
 */
export const resolveIds = (local, records, fallback) => {
  if (!local) return {}
  if (matches(local, fallback))
    return { excludeIds: records.filter(r => !matches(local, r)).map(r => r.id) }
  return { onlyIds: records.filter(r => matches(local, r)).map(r => r.id) }
}
