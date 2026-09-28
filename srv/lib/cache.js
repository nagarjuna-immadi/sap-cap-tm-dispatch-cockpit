/**
 * Small in-memory TTL cache for slow-changing reference data (blueprint §6, development
 * plan 1.3): carriers and code lists. Transactional data (dispatches, rounds, offers) is
 * never cached.
 *
 * - `cached(key, loader, ttlMs)` returns the stored value while it is fresh; otherwise it
 *   calls `loader()` once, stores the result and returns it.
 * - Concurrent misses on the same key share one in-flight load, so a burst of list
 *   requests after expiry runs the query only once. A failed load is not stored; the
 *   next call tries again.
 * - The cache lives per process, which is fine for a single app instance on trial.
 * - `clear(key?)` drops one key or everything (for tests, or after a local write).
 */

export const DEFAULT_TTL_MS = 5 * 60_000

const store = new Map() // key -> { promise, expires }

export function cached(key, loader, ttlMs = DEFAULT_TTL_MS, now = Date.now) {
  const hit = store.get(key)
  if (hit && hit.expires > now()) return hit.promise

  const promise = Promise.resolve().then(loader)
  const entry = { promise, expires: now() + ttlMs }
  store.set(key, entry)
  promise.catch(() => {
    if (store.get(key) === entry) store.delete(key)
  })
  return promise
}

export function clear(key) {
  if (key === undefined) store.clear()
  else store.delete(key)
}
