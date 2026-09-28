import { jest } from '@jest/globals'
import cds from '@sap/cds'
import { enrich, DISPATCH } from '../srv/lib/enrich.js'

const { INSERT } = cds.ql

cds.test('serve', 'all', '--with-mocks', '--in-memory')

const NOW = new Date('2026-06-01T12:00:00Z')
const PAST = '2026-06-01T10:00:00Z'
const FUTURE = '2026-06-02T10:00:00Z'

const offer = (carrierId, status_code, price, currency_code = 'EUR') => ({ carrierId, status_code, price, currency_code })

beforeAll(async () => {
  await INSERT.into(DISPATCH).entries(
    // TENDERING: round 1 closed with cheap quotes, round 2 open, deadline passed
    { freightOrderId: 'FO-A', dispatchStatus_code: 'TENDERING', quoteDeadline: PAST, rounds: [
      { roundNumber: 1, mode_code: 'BROADCAST', deadline: PAST, closed: true,
        offers: [offer('10300001', 'LOST', 100), offer('10300002', 'LOST', 90)] },
      { roundNumber: 2, mode_code: 'BROADCAST', deadline: PAST, closed: false,
        offers: [offer('10300001', 'QUOTED', 500), offer('10300002', 'QUOTED', 450),
          offer('10300003', 'DECLINED', null, null), offer('10300004', 'INVITED', null, null)] },
    ] },
    // TENDERING: open round, nothing quoted yet, deadline ahead
    { freightOrderId: 'FO-B', dispatchStatus_code: 'TENDERING', rounds: [
      { roundNumber: 1, mode_code: 'PEER', deadline: FUTURE, closed: false,
        offers: [offer('10300001', 'INVITED', null, null)] },
    ] },
    // quotes in two currencies
    { freightOrderId: 'FO-C', dispatchStatus_code: 'TENDERING', rounds: [
      { roundNumber: 1, mode_code: 'SPOT', deadline: FUTURE, closed: false,
        offers: [offer('10300001', 'QUOTED', 300, 'EUR'), offer('10300002', 'QUOTED', 280, 'USD')] },
    ] },
    // opened, never tendered
    { freightOrderId: 'FO-D', dispatchStatus_code: 'NEW' },
  )
})

describe('enrich', () => {
  let rows
  const row = id => rows.find(r => r.TransportationOrder === id)

  beforeAll(async () => {
    rows = ['FO-A', 'FO-B', 'FO-C', 'FO-D', 'FO-X'].map(TransportationOrder => ({ TransportationOrder }))
    rows.$count = 42
    await enrich(rows, { now: NOW })
  })

  test('uses only the latest round: best quote, quote count, deadline, expiry', () =>
    expect(row('FO-A')).toMatchObject({
      dispatchStatus: 'TENDERING', bestQuote: 450, bestQuoteCurrency: 'EUR',
      quoteCount: 2, quoteDeadline: expect.stringMatching(/^2026-06-01T10:00:00/), deadlineExpired: true,
    }))

  test('an open round without quotes counts 0 and is not expired before its deadline', () =>
    expect(row('FO-B')).toMatchObject({ quoteCount: 0, bestQuote: null, deadlineExpired: false }))

  test('mixed currencies give no best quote but still count', () =>
    expect(row('FO-C')).toMatchObject({ quoteCount: 2, bestQuote: null, bestQuoteCurrency: null }))

  test('a dispatch without rounds', () =>
    expect(row('FO-D')).toMatchObject({ dispatchStatus: 'NEW', quoteCount: 0, quoteDeadline: null, deadlineExpired: false }))

  test('a missing dispatch reads as NEW', () =>
    expect(row('FO-X')).toMatchObject({ dispatchStatus: 'NEW', quoteCount: 0, bestQuote: null, deadlineExpired: false }))

  test('keeps $count', () => expect(rows.$count).toBe(42))

  test('runs two local queries per page, not one per row', async () => {
    const spy = jest.spyOn(cds.db, 'run')
    try {
      await enrich(rows.map(r => ({ TransportationOrder: r.TransportationOrder })), { now: NOW })
      // cds.run wraps each query in db.run(tx => tx.run(query)), so count only the query calls
      expect(spy.mock.calls.filter(([q]) => typeof q !== 'function')).toHaveLength(2)
    } finally { spy.mockRestore() }
  })
})
