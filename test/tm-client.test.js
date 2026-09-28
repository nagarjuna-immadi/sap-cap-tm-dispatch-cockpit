import cds from '@sap/cds'
import {
  FREIGHT_ORDER, FREIGHT_UNIT, and, passThrough,
  buildFreightOrderListQuery, buildFreightOrderQuery, buildFreightUnitsQuery,
  readFreightOrders, readFreightOrder, readFreightUnits, connect,
} from '../srv/lib/tm-client.js'

const { SELECT } = cds.ql

// Serves the TM services as in-process mocks from srv/external/data/*.csv (as cds watch does).
cds.test('serve', 'all', '--with-mocks', '--in-memory')

/** An incoming query as the Dispatch service would receive it for GET /FreightOrders?… */
const incoming = () => SELECT.from('DispatchService.FreightOrders')
  .where({ TransportationMode: '01' })
  .orderBy('TransportationOrder desc')
  .limit(5, 10)

const columnNames = q => q.SELECT.columns.map(c => c.ref[0])

describe('and', () => {
  test('drops empty parts', () => expect(and(undefined, false, [], ['x'])).toEqual(['x']))
  test('brackets every part so an or cannot leak', () =>
    expect(and(['a', 'or', 'b'], ['c'])).toEqual([{ xpr: ['a', 'or', 'b'] }, 'and', { xpr: ['c'] }]))
  test('nothing to combine gives undefined', () => expect(and()).toBeUndefined())
})

describe('passThrough', () => {
  test('takes where, orderBy, limit and count from the incoming query', () => {
    const q = incoming()
    q.SELECT.count = true
    const pt = passThrough(q)
    expect(pt.where).toBe(q.SELECT.where)
    expect(pt.orderBy).toBe(q.SELECT.orderBy)
    expect(pt.limit).toBe(q.SELECT.limit)
    expect(pt.count).toBe(true)
  })
  test('tolerates a missing query', () => expect(passThrough(undefined)).toEqual({}))
})

describe('buildFreightOrderListQuery', () => {
  test('targets the remote entity with an explicit $select and the stops expanded', () => {
    const q = buildFreightOrderListQuery(incoming())
    expect(q.SELECT.from.ref).toEqual([FREIGHT_ORDER])
    expect(columnNames(q)).toEqual(expect.arrayContaining(['TransportationOrder', 'Carrier', '_FreightOrderStop']))
    expect(columnNames(q)).not.toContain('_FreightOrderItem')
    expect(q.SELECT.columns.find(c => c.ref[0] === '_FreightOrderStop').expand.length).toBeGreaterThan(0)
  })

  test('passes $orderby, $top and $skip through', () => {
    const src = incoming()
    const q = buildFreightOrderListQuery(src)
    expect(q.SELECT.orderBy).toEqual(src.SELECT.orderBy)
    expect(q.SELECT.limit).toEqual(src.SELECT.limit)
  })

  test('ANDs the incoming $filter with Carrier eq \'\'', () => {
    const src = incoming()
    expect(buildFreightOrderListQuery(src).SELECT.where).toEqual([
      { xpr: src.SELECT.where }, 'and', { xpr: [{ ref: ['Carrier'] }, '=', { val: '' }] },
    ])
  })

  test('unassignedOnly: false leaves orders with a carrier in', () =>
    expect(buildFreightOrderListQuery(undefined, { unassignedOnly: false }).SELECT.where).toBeUndefined())

  test('onlyIds becomes an in filter', () => {
    const where = buildFreightOrderListQuery(undefined, { onlyIds: ['1', '2'] }).SELECT.where
    expect(where).toContainEqual({ xpr: [{ ref: ['TransportationOrder'] }, 'in', { list: [{ val: '1' }, { val: '2' }] }] })
  })

  test('empty onlyIds means nothing can match', () =>
    expect(buildFreightOrderListQuery(incoming(), { onlyIds: [] })).toBeNull())

  test('excludeIds becomes a not-in filter', () => {
    const where = buildFreightOrderListQuery(undefined, { excludeIds: ['1'] }).SELECT.where
    expect(where).toContainEqual({ xpr: ['not', { xpr: [{ ref: ['TransportationOrder'] }, 'in', { list: [{ val: '1' }] }] }] })
  })

  test('empty excludeIds adds nothing', () =>
    expect(buildFreightOrderListQuery(undefined, { unassignedOnly: false, excludeIds: [] }).SELECT.where).toBeUndefined())
})

describe('buildFreightOrderQuery', () => {
  test('expands stops with stages, and items, for the object page', () => {
    const q = buildFreightOrderQuery('6100000002')
    expect(q.SELECT.one).toBe(true)
    const stops = q.SELECT.columns.find(c => c.ref[0] === '_FreightOrderStop')
    expect(stops.expand.map(c => c.ref[0])).toContain('_FreightOrderStage')
    expect(columnNames(q)).toContain('_FreightOrderItem')
  })
})

describe('buildFreightUnitsQuery', () => {
  test('no UUIDs means no call', () => expect(buildFreightUnitsQuery([])).toBeNull())
  test('filters the remote freight units by UUID', () => {
    const q = buildFreightUnitsQuery(['u1'])
    expect(q.SELECT.from.ref).toEqual([FREIGHT_UNIT])
    expect(q.SELECT.where).toEqual([{ ref: ['TransportationOrderUUID'] }, 'in', { list: [{ val: 'u1' }] }])
  })
})

describe('against the mocked TM services', () => {
  test('connects once', async () => {
    const [a, b] = await Promise.all([connect(), connect()])
    expect(a).toBe(b)
    expect(await connect()).toBe(a)
  })

  test('lists only orders without a carrier (25 of 32), with their stops', async () => {
    const rows = await readFreightOrders(undefined)
    expect(rows).toHaveLength(25)
    expect(rows.every(r => r.Carrier === '')).toBe(true)
    expect(rows.find(r => r.TransportationOrder === '6100000001')).toBeUndefined()   // has a carrier
    expect(rows[0]._FreightOrderStop.length).toBeGreaterThanOrEqual(2)
  })

  test('pages and counts through $top, $skip, $orderby and $count', async () => {
    const q = SELECT.from('DispatchService.FreightOrders').orderBy('TransportationOrder asc').limit(3, 2)
    q.SELECT.count = true
    const rows = await readFreightOrders(q)
    expect(rows.map(r => r.TransportationOrder)).toEqual(['6100000004', '6100000005', '6100000007'])
    expect(rows.$count).toBe(25)
  })

  test('onlyIds and excludeIds narrow the list', async () => {
    const only = await readFreightOrders(undefined, { onlyIds: ['6100000002', '6100000001'] })
    expect(only.map(r => r.TransportationOrder)).toEqual(['6100000002'])   // 1 has a carrier
    const rest = await readFreightOrders(undefined, { excludeIds: ['6100000002'] })
    expect(rest).toHaveLength(24)
  })

  test('empty onlyIds answers without calling TM, $count included', async () => {
    const q = SELECT.from('DispatchService.FreightOrders')
    q.SELECT.count = true
    const rows = await readFreightOrders(q, { onlyIds: [] })
    expect(rows).toHaveLength(0)
    expect(rows.$count).toBe(0)
  })

  test('reads one order by its number with stops and items', async () => {
    const fo = await readFreightOrder('6100000002')
    expect(fo.TransportationOrder).toBe('6100000002')
    expect(fo._FreightOrderStop.length).toBeGreaterThanOrEqual(2)
    expect(fo._FreightOrderItem).toHaveLength(2)
  })

  test('an unknown order reads as nothing', async () =>
    expect(await readFreightOrder('0000000000')).toBeFalsy())

  test('finds an order\'s freight units through its items', async () => {
    const units = await readFreightUnits('6100000002')
    expect(units.map(u => u.TransportationOrder).sort()).toEqual(['4100000002', '4100000003'])
  })

  test('an order without items has no freight units', async () =>
    expect(await readFreightUnits('6100000004')).toEqual([]))
})
