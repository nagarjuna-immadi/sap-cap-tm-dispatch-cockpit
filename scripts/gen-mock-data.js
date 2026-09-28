#!/usr/bin/env node
/**
 * Generates linked mock CSVs for the imported TM services into srv/external/data/.
 *
 *   node scripts/gen-mock-data.js [--base YYYY-MM-DD]
 *
 * - Pick-up dates are spread from base-7d to base+21d (base defaults to today, UTC).
 * - Every `not null` column gets a type default, because SQLite enforces NOT NULL on
 *   the mock tables. Nullable columns are only written when we set them.
 * - UUIDs are deterministic, so re-running only shifts the dates.
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import cds from '@sap/cds'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

const OUT = path.join(__dirname, '..', 'srv', 'external', 'data')

const baseArg = process.argv.indexOf('--base')
const BASE = baseArg > 0 ? new Date(process.argv[baseArg + 1] + 'T00:00:00Z') : new Date(new Date().toISOString().slice(0, 10) + 'T00:00:00Z')

const uuid = (prefix, n) => `${prefix}0000000-0000-4000-8000-${String(n).padStart(12, '0')}`
const iso = d => d.toISOString().replace(/\.\d{3}Z$/, 'Z')
const addHours = (d, h) => new Date(d.getTime() + h * 3600e3)

// --- master data ------------------------------------------------------------

// Carrier IDs match the local Carriers seed (db/data/tm.dispatch-Carriers.csv, phase 1.1)
const CARRIERS = Array.from({ length: 12 }, (_, i) => String(10300001 + i))

const LANES = [
  { from: 'HAM_DC',    to: 'MUC_PLANT', transitH: 10 },
  { from: 'FRA_HUB',   to: 'BER_DC',    transitH: 8 },
  { from: 'DUS_PLANT', to: 'STR_DC',    transitH: 6 },
  { from: 'HAM_PORT',  to: 'LEI_DC',    transitH: 5 },  // on-carriage from sea
  { from: 'MUC_PLANT', to: 'VIE_CUST',  transitH: 7 },
  { from: 'CGN_DC',    to: 'RTM_PORT',  transitH: 4 },  // pre-carriage to sea
]

const ORDER_COUNT = 32
const WITH_CARRIER = i => i % 5 === 0            // 7 of 32 ≈ 22 %
const WITHOUT_FREIGHT_UNITS = new Set([3, 17, 29]) // empty "Freight Units" facet

// --- build rows ---------------------------------------------------------------

const rows = { FreightOrder: [], FreightOrderStop: [], FreightOrderItem: [], FreightUnit: [], FreightUnitItem: [], FreightBooking: [] }
let stopNo = 0, itemNo = 0, fuNo = 0

for (let i = 0; i < ORDER_COUNT; i++) {
  const lane = LANES[i % LANES.length]
  const foUUID = uuid('a', i + 1)
  const pickup = addHours(BASE, (-7 + Math.floor((i * 28) / ORDER_COUNT)) * 24 + 6 + (i % 8))
  const delivery = addHours(pickup, lane.transitH)

  rows.FreightOrder.push({
    TransportationOrderUUID: foUUID,
    TransportationOrder: String(6100000001 + i),
    TransportationOrderType: 'FO01',
    TransportationOrderCategory: 'TO',
    TransportationMode: '01',            // road
    TransportationModeCategory: '1',
    Carrier: WITH_CARRIER(i) ? CARRIERS[i % CARRIERS.length] : '',
    TranspOrdLifeCycleStatus: '01',
  })

  for (const [seq, loc, when, role, cat] of [['F', lane.from, pickup, 'TF', 'O'], ['L', lane.to, delivery, 'TL', 'I']]) {
    stopNo++
    rows.FreightOrderStop.push({
      TransportationOrderStopUUID: uuid('b', stopNo),
      TransportationOrderUUID: foUUID,
      TransportationOrderStop: String(seq === 'F' ? 10 : 20).padStart(10, '0'),
      TranspOrdStopCategory: cat,
      TranspOrdStopRole: role,
      TranspOrdStopSequencePosition: seq,
      LocationId: loc,
      TranspOrdStopPlanTranspDteTme: iso(when),
    })
  }

  if (WITHOUT_FREIGHT_UNITS.has(i)) continue

  const itemCount = 1 + (i % 2)
  for (let k = 0; k < itemCount; k++) {
    itemNo++; fuNo++
    const weight = 800 + ((i * 37 + k * 211) % 9000)   // kg
    const volume = Math.round(weight / 250 * 10) / 10  // m3
    const fuUUID = uuid('d', fuNo)

    rows.FreightOrderItem.push({
      TransportationOrderItemUUID: uuid('c', itemNo),
      TransportationOrderUUID: foUUID,
      TranspOrdItemCategory: 'PRD',
      FreightUnitUUID: fuUUID,
      TranspOrdItemGrossWeight: weight, TranspOrdItemGrossWeightUnit: 'KG',
      TranspOrdItemGrossVolume: volume, TranspOrdItemGrossVolumeUnit: 'M3',
    })
    rows.FreightUnit.push({
      TransportationOrderUUID: fuUUID,
      TransportationOrder: String(4100000001 + fuNo - 1),
      TransportationOrderType: 'FU01',
      TransportationOrderCategory: 'FU',
      TransportationModeCategory: '1',
      TranspOrdLifeCycleStatus: '02',
    })
    rows.FreightUnitItem.push({
      TransportationOrderItemUUID: uuid('e', fuNo),
      TransportationOrderUUID: fuUUID,
      TranspOrdItemCategory: 'PRD',
      TranspOrdItemQuantity: 1 + (fuNo % 20),
      TranspOrdItemGrossWeight: weight, TranspOrdItemGrossWeightUnit: 'KG',
      TranspOrdItemGrossVolume: volume, TranspOrdItemGrossVolumeUnit: 'M3',
    })
  }
}

// Sea legs belonging to the HAM_PORT (on-carriage) and RTM_PORT (pre-carriage) road orders
for (let b = 0; b < 4; b++) {
  rows.FreightBooking.push({
    TransportationOrderUUID: uuid('f', b + 1),
    TransportationOrder: String(7100000001 + b),
    TransportationOrderType: 'FB01',
    TransportationOrderCategory: 'BO',
    TransportationMode: '03',            // sea
    TransportationModeCategory: '3',
    MovementType: 'P2P',
    Carrier: CARRIERS[(b * 3) % CARRIERS.length],
  })
}

// --- write CSVs ----------------------------------------------------------------

function builtinType(el, defs) {
  let t = el
  while (t && t.type && !t.type.startsWith('cds.')) t = defs[t.type]
  return t && t.type
}

function defaultFor(type) {
  switch (type) {
    case 'cds.String': case 'cds.LargeString': return ''
    case 'cds.UUID': return '00000000-0000-0000-0000-000000000000'
    case 'cds.Boolean': return 'false'
    case 'cds.Integer': case 'cds.Int16': case 'cds.Int32': case 'cds.Int64': case 'cds.UInt8':
    case 'cds.Decimal': case 'cds.Double': return 0
    case 'cds.Date': return iso(BASE).slice(0, 10)
    case 'cds.Time': return '00:00:00'
    case 'cds.DateTime': case 'cds.Timestamp': return iso(BASE)
    default: return undefined // binaries, structs: leave out
  }
}

// CAP's CSV loader reads an empty cell as NULL, so '' must be written as a quoted "".
const csvValue = v => {
  const s = String(v)
  return s === '' || /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
}

const FILES = {
  FreightOrder: 'CE_FREIGHTORDER_0001', FreightOrderStop: 'CE_FREIGHTORDER_0001', FreightOrderItem: 'CE_FREIGHTORDER_0001',
  FreightUnit: 'CE_FREIGHTUNIT_0001', FreightUnitItem: 'CE_FREIGHTUNIT_0001',
  FreightBooking: 'CE_FREIGHTBOOKING_0001',
}

try {
  const csn = await cds.load(Object.values(FILES).map(s => path.join(__dirname, '..', 'srv', 'external', s)))
  const defs = csn.definitions
  fs.mkdirSync(OUT, { recursive: true })

  for (const [entity, service] of Object.entries(FILES)) {
    const def = defs[`${service}.${entity}`]
    if (!def) throw new Error(`Entity ${service}.${entity} not found in model`)

    const columns = []
    for (const [name, el] of Object.entries(def.elements)) {
      if (el.type === 'cds.Association' || el.type === 'cds.Composition' || el.virtual || el.items || el.elements) continue
      const used = rows[entity].some(r => name in r)
      if (used || ((el.notNull || el.key) && defaultFor(builtinType(el, defs)) !== undefined)) columns.push([name, el])
    }

    const unknown = Object.keys(rows[entity][0]).filter(k => !columns.some(([n]) => n === k))
    if (unknown.length) throw new Error(`${entity}: fields not in model: ${unknown.join(', ')}`)

    const lines = [columns.map(([n]) => n).join(',')]
    for (const r of rows[entity]) {
      lines.push(columns.map(([n, el]) => csvValue(n in r ? r[n] : defaultFor(builtinType(el, defs)))).join(','))
    }
    const file = path.join(OUT, `${service}-${entity}.csv`)
    fs.writeFileSync(file, lines.join('\n') + '\n')
    console.log(`${path.relative(process.cwd(), file)}: ${rows[entity].length} rows, ${columns.length} columns`)
  }
} catch (e) { console.error(e.message); process.exit(1) }
