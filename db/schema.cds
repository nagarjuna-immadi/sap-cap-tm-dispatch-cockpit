namespace tm.dispatch;

using { cuid, managed, Currency, sap.common.CodeList } from '@sap/cds/common';

// One record per TM freight order, created lazily on first open.
// freightOrderId = FreightOrder.TransportationOrder (String(20) in CE_FREIGHTORDER_0001)
@assert.unique: { freightOrderId: [freightOrderId] }
entity FreightOrderDispatch : cuid, managed {
  freightOrderId  : String(20) not null;           // key from TM
  dispatchStatus  : Association to DispatchStatus; // NEW | TENDERING | AWARDED | FAILED | CLOSED
  awardedCarrier  : String(10);                    // BP number of the winner
  awardedPrice    : Decimal(15,2);
  currency        : Currency;
  awardedAt       : Timestamp;
  awardedBy       : String(120);
  quoteDeadline   : Timestamp;                     // deadline of the current round
  rounds          : Composition of many TenderRounds    on rounds.parent     = $self;
  exceptions      : Composition of many ExecutionEvents on exceptions.parent = $self;
  notes           : Composition of many DispatchNotes   on notes.parent      = $self;
}

entity TenderRounds : cuid, managed {
  parent      : Association to FreightOrderDispatch;
  roundNumber : Integer;
  mode        : Association to TenderModes;        // BROADCAST | PEER | SPOT
  deadline    : Timestamp;
  closed      : Boolean default false;
  offers      : Composition of many CarrierOffers on offers.parent = $self;
}

entity CarrierOffers : cuid, managed {
  parent       : Association to TenderRounds;
  carrierId    : String(10);                       // BP number, matches Carriers.carrierId
  carrierName  : String(120);                      // snapshot at invite time
  status       : Association to OfferStatus;       // INVITED | QUOTED | DECLINED | EXPIRED | WON | LOST
  price        : Decimal(15,2);
  currency     : Currency;
  transitHours : Integer;
  respondedAt  : Timestamp;
  comment      : String(255);
}

entity ExecutionEvents : cuid, managed {
  parent      : Association to FreightOrderDispatch;
  eventType   : Association to EventTypes;         // PICKED_UP | DELIVERED | DELAY | DAMAGE
  eventTime   : Timestamp;
  delayReason : Association to DelayReasons;       // TRAFFIC | WEATHER | CARRIER | SHIPPER | CUSTOMS
  delayMins   : Integer;
  comment     : String(255);
}

entity DispatchNotes : cuid, managed {
  parent : Association to FreightOrderDispatch;
  text   : String(1000);
}

// Local carrier master; stands in for API_BUSINESS_PARTNER (no Hub sandbox)
entity Carriers : managed {
  key carrierId  : String(10);                     // BP-style number, same length as FreightOrder.Carrier
      name       : String(120);
      street     : String(120);
      postalCode : String(10);
      city       : String(60);
      country    : String(3);
      email      : String(241);
      active     : Boolean default true;
}

// Code lists: CodeList adds localized name/descr; criticality 1 = red, 2 = yellow, 3 = green
entity DispatchStatus : CodeList { key code : String(10); criticality : Integer; }
entity TenderModes    : CodeList { key code : String(10); }
entity OfferStatus    : CodeList { key code : String(10); criticality : Integer; }
entity EventTypes     : CodeList { key code : String(12); }
entity DelayReasons   : CodeList { key code : String(10); }
