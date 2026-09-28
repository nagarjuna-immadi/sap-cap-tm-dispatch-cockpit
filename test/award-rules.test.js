import {
  canStartTender, canAward, canSubmitQuote, canDecline, canCloseRound, canCancel,
  isExpired, effectiveOfferStatus, nextRoundNumber,
} from '../srv/lib/award-rules.js'

const NOW = '2026-10-01T12:00:00Z'
const BEFORE = '2026-10-01T11:00:00Z'
const AFTER = '2026-10-01T13:00:00Z'

const expectFail = (result, code) => expect(result).toMatchObject({ ok: false, code, message: expect.any(String) })

describe('isExpired', () => {
  test('deadline in the future is not expired', () => expect(isExpired(AFTER, NOW)).toBe(false))
  test('deadline in the past is expired', () => expect(isExpired(BEFORE, NOW)).toBe(true))
  test('now equal to the deadline is expired', () => expect(isExpired(NOW, NOW)).toBe(true))
  test('no deadline never expires', () => {
    expect(isExpired(null, NOW)).toBe(false)
    expect(isExpired(undefined, NOW)).toBe(false)
  })
  test('accepts Date, ISO string and millis', () => {
    expect(isExpired(new Date(BEFORE), new Date(NOW))).toBe(true)
    expect(isExpired(Date.parse(AFTER), Date.parse(NOW))).toBe(false)
  })
})

describe('effectiveOfferStatus', () => {
  const round = { deadline: NOW }
  test('INVITED before the deadline stays INVITED', () =>
    expect(effectiveOfferStatus({ status_code: 'INVITED' }, round, BEFORE)).toBe('INVITED'))
  test('INVITED at the deadline reads as EXPIRED', () =>
    expect(effectiveOfferStatus({ status_code: 'INVITED' }, round, NOW)).toBe('EXPIRED'))
  test('INVITED after the deadline reads as EXPIRED', () =>
    expect(effectiveOfferStatus({ status_code: 'INVITED' }, round, AFTER)).toBe('EXPIRED'))
  test('other statuses are unchanged after the deadline', () => {
    for (const s of ['QUOTED', 'DECLINED', 'EXPIRED', 'WON', 'LOST'])
      expect(effectiveOfferStatus({ status_code: s }, round, AFTER)).toBe(s)
  })
  test('reads an expanded status association', () =>
    expect(effectiveOfferStatus({ status: { code: 'INVITED' } }, round, AFTER)).toBe('EXPIRED'))
  test('INVITED without a round deadline stays INVITED', () =>
    expect(effectiveOfferStatus({ status_code: 'INVITED' }, {}, AFTER)).toBe('INVITED'))
})

describe('nextRoundNumber', () => {
  test('first round is 1', () => {
    expect(nextRoundNumber([])).toBe(1)
    expect(nextRoundNumber(undefined)).toBe(1)
  })
  test('is the highest number + 1, regardless of order', () =>
    expect(nextRoundNumber([{ roundNumber: 2 }, { roundNumber: 3 }, { roundNumber: 1 }])).toBe(4))
  test('ignores rounds without a number', () =>
    expect(nextRoundNumber([{ roundNumber: null }, { roundNumber: 2 }])).toBe(3))
})

describe('canStartTender', () => {
  const args = { carriers: ['10300001', '10300002'], deadline: AFTER, now: NOW }

  test('NEW dispatch with valid input is ok', () =>
    expect(canStartTender({ dispatchStatus_code: 'NEW' }, args)).toEqual({ ok: true }))
  test('TENDERING dispatch with only closed rounds is ok', () =>
    expect(canStartTender({ dispatchStatus_code: 'TENDERING', rounds: [{ closed: true }] }, args)).toEqual({ ok: true }))
  test('dispatch without a status reads as NEW', () =>
    expect(canStartTender({}, args)).toEqual({ ok: true }))
  test('reads an expanded status association', () =>
    expectFail(canStartTender({ dispatchStatus: { code: 'AWARDED' } }, args), 'INVALID_DISPATCH_STATUS'))
  test.each(['AWARDED', 'FAILED', 'CLOSED'])('%s dispatch is rejected', status =>
    expectFail(canStartTender({ dispatchStatus_code: status }, args), 'INVALID_DISPATCH_STATUS'))
  test('an open round is rejected', () =>
    expectFail(canStartTender({ dispatchStatus_code: 'TENDERING', rounds: [{ closed: true }, { closed: false }] }, args), 'ROUND_ALREADY_OPEN'))
  test('missing deadline is rejected', () =>
    expectFail(canStartTender({}, { ...args, deadline: null }), 'DEADLINE_MISSING'))
  test('unparsable deadline is rejected', () =>
    expectFail(canStartTender({}, { ...args, deadline: 'tomorrow' }), 'DEADLINE_MISSING'))
  test('deadline in the past is rejected', () =>
    expectFail(canStartTender({}, { ...args, deadline: BEFORE }), 'DEADLINE_NOT_IN_FUTURE'))
  test('deadline equal to now is rejected', () =>
    expectFail(canStartTender({}, { ...args, deadline: NOW }), 'DEADLINE_NOT_IN_FUTURE'))
  test('no carriers is rejected', () => {
    expectFail(canStartTender({}, { ...args, carriers: [] }), 'NO_CARRIERS')
    expectFail(canStartTender({}, { ...args, carriers: undefined }), 'NO_CARRIERS')
  })
  test('blank carrier ID is rejected', () =>
    expectFail(canStartTender({}, { ...args, carriers: ['10300001', ' '] }), 'INVALID_CARRIER'))
  test('duplicate carriers are rejected', () => {
    const r = canStartTender({}, { ...args, carriers: ['10300001', '10300002', '10300001'] })
    expectFail(r, 'DUPLICATE_CARRIERS')
    expect(r.message).toContain('10300001')
  })
})

describe('canAward', () => {
  const dispatch = { dispatchStatus_code: 'TENDERING' }
  const peerRound = { mode_code: 'PEER', closed: false, deadline: AFTER }
  const broadcastRound = { mode_code: 'BROADCAST', closed: false, deadline: NOW }
  const offer = { status_code: 'QUOTED', price: 900 }

  test('QUOTED offer in an open PEER round is ok before the deadline', () =>
    expect(canAward({ dispatch, round: peerRound, offer, now: NOW })).toEqual({ ok: true }))
  test('missing offer is rejected', () =>
    expectFail(canAward({ dispatch, round: peerRound, now: NOW }), 'OFFER_NOT_FOUND'))
  test('missing round is rejected', () =>
    expectFail(canAward({ dispatch, offer, now: NOW }), 'ROUND_NOT_FOUND'))
  test.each(['INVITED', 'DECLINED', 'EXPIRED', 'WON', 'LOST'])('%s offer is rejected', status =>
    expectFail(canAward({ dispatch, round: peerRound, offer: { status_code: status }, now: NOW }), 'OFFER_NOT_QUOTED'))
  test('closed round is rejected', () =>
    expectFail(canAward({ dispatch, round: { ...peerRound, closed: true }, offer, now: NOW }), 'ROUND_CLOSED'))
  test('already AWARDED dispatch is rejected', () =>
    expectFail(canAward({ dispatch: { dispatchStatus_code: 'AWARDED' }, round: peerRound, offer, now: NOW }), 'ALREADY_AWARDED'))
  test('BROADCAST before the deadline is rejected', () =>
    expectFail(canAward({ dispatch, round: broadcastRound, offer, now: BEFORE }), 'DEADLINE_NOT_PASSED'))
  test('BROADCAST at the deadline is ok', () =>
    expect(canAward({ dispatch, round: broadcastRound, offer, now: NOW })).toEqual({ ok: true }))
  test('BROADCAST after the deadline is ok', () =>
    expect(canAward({ dispatch, round: broadcastRound, offer, now: AFTER })).toEqual({ ok: true }))
  test('BROADCAST read from an expanded mode association', () =>
    expectFail(canAward({ dispatch, round: { mode: { code: 'BROADCAST' }, deadline: NOW }, offer, now: BEFORE }), 'DEADLINE_NOT_PASSED'))
})

describe('canSubmitQuote', () => {
  const round = { closed: false, deadline: NOW }
  const offer = { status_code: 'INVITED', price: 1200.5, transitHours: 10 }

  test('valid quote before the deadline is ok', () =>
    expect(canSubmitQuote({ offer, round, now: BEFORE })).toEqual({ ok: true }))
  test('decimal price as a string (as read from the DB) is ok', () =>
    expect(canSubmitQuote({ offer: { ...offer, price: '1200.50' }, round, now: BEFORE })).toEqual({ ok: true }))
  test('missing offer is rejected', () =>
    expectFail(canSubmitQuote({ round, now: BEFORE }), 'OFFER_NOT_FOUND'))
  test('missing round is rejected', () =>
    expectFail(canSubmitQuote({ offer, now: BEFORE }), 'ROUND_NOT_FOUND'))
  test.each(['QUOTED', 'DECLINED', 'EXPIRED', 'WON', 'LOST'])('%s offer is rejected', status =>
    expectFail(canSubmitQuote({ offer: { ...offer, status_code: status }, round, now: BEFORE }), 'OFFER_NOT_INVITED'))
  test('closed round is rejected', () =>
    expectFail(canSubmitQuote({ offer, round: { ...round, closed: true }, now: BEFORE }), 'ROUND_CLOSED'))
  test('at the deadline is rejected', () =>
    expectFail(canSubmitQuote({ offer, round, now: NOW }), 'DEADLINE_PASSED'))
  test('after the deadline is rejected', () =>
    expectFail(canSubmitQuote({ offer, round, now: AFTER }), 'DEADLINE_PASSED'))
  test.each([0, -1, null, undefined, 'abc'])('price %p is rejected', price =>
    expectFail(canSubmitQuote({ offer: { ...offer, price }, round, now: BEFORE }), 'INVALID_PRICE'))
  test.each([0, -5, null, undefined])('transit hours %p are rejected', transitHours =>
    expectFail(canSubmitQuote({ offer: { ...offer, transitHours }, round, now: BEFORE }), 'INVALID_TRANSIT_HOURS'))
})

describe('canDecline', () => {
  const round = { closed: false, deadline: NOW }
  const offer = { status_code: 'INVITED' }

  test('INVITED offer in an open round is ok', () =>
    expect(canDecline({ offer, round, now: BEFORE })).toEqual({ ok: true }))
  test('is still ok after the deadline while the round is open', () =>
    expect(canDecline({ offer, round, now: AFTER })).toEqual({ ok: true }))
  test('missing offer is rejected', () =>
    expectFail(canDecline({ round, now: BEFORE }), 'OFFER_NOT_FOUND'))
  test('missing round is rejected', () =>
    expectFail(canDecline({ offer, now: BEFORE }), 'ROUND_NOT_FOUND'))
  test.each(['QUOTED', 'DECLINED', 'EXPIRED', 'WON', 'LOST'])('%s offer is rejected', status =>
    expectFail(canDecline({ offer: { status_code: status }, round, now: BEFORE }), 'OFFER_NOT_INVITED'))
  test('closed round is rejected', () =>
    expectFail(canDecline({ offer, round: { ...round, closed: true }, now: BEFORE }), 'ROUND_CLOSED'))
})

describe('canCloseRound', () => {
  test('open round is ok', () => expect(canCloseRound({ closed: false })).toEqual({ ok: true }))
  test('round without a closed flag counts as open', () => expect(canCloseRound({})).toEqual({ ok: true }))
  test('missing round is rejected', () => expectFail(canCloseRound(undefined), 'ROUND_NOT_FOUND'))
  test('closed round is rejected', () => expectFail(canCloseRound({ closed: true }), 'ROUND_CLOSED'))
})

describe('canCancel', () => {
  test.each(['NEW', 'TENDERING', 'AWARDED', 'FAILED', 'CLOSED'])('%s dispatch with a reason is ok', status =>
    expect(canCancel({ dispatchStatus_code: status }, 'No capacity on this lane')).toEqual({ ok: true }))
  test('missing dispatch is rejected', () =>
    expectFail(canCancel(undefined, 'reason'), 'DISPATCH_NOT_FOUND'))
  test.each([undefined, null, '', '   ', 42])('reason %p is rejected', reason =>
    expectFail(canCancel({ dispatchStatus_code: 'TENDERING' }, reason), 'REASON_REQUIRED'))
})
