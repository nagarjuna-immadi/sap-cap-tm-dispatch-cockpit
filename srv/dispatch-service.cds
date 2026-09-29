using { tm.dispatch as db } from '../db/schema';
using { CE_FREIGHTORDER_0001 as FO } from './external/CE_FREIGHTORDER_0001';
using { CE_FREIGHTUNIT_0001 as FU } from './external/CE_FREIGHTUNIT_0001';

/**
 * Dispatcher's service (blueprint §5, development plan 1.4).
 *
 * Only Dispatcher gets in (@requires); the entities that carry the tender and award
 * actions restrict them to Dispatcher again, so the rule holds even if the service-level
 * requirement is widened later (e.g. read access for TransportManager).
 *
 * TM entities are read through custom READ handlers (dispatch-service.js → tm-client,
 * enrich); they never hit the database. Everything written goes to local entities.
 */
@path: '/odata/v4/dispatch'
@requires: 'Dispatcher'
service DispatchService {

  // --- TM (remote, read-only) ---------------------------------------------------------

  /**
   * Freight orders still to tender (Carrier eq ''), keyed by the readable number that
   * links them to Dispatch. The virtual elements are filled per page by enrich.js;
   * only dispatchStatus and deadlineExpired can be filtered on (resolved locally, §12).
   */
  @readonly
  @restrict: [{ grant: ['READ', 'startTender', 'cancelTender'], to: 'Dispatcher' }]
  @Capabilities.SearchRestrictions.Searchable: false
  @Capabilities.SortRestrictions.NonSortableProperties: [
    dispatchStatus, dispatchStatusCriticality, bestQuote, bestQuoteCurrency, quoteCount,
    quoteDeadline, deadlineExpired, sourceLocation, destinationLocation, pickupDateTime, deliveryDateTime
  ]
  @Capabilities.FilterRestrictions.NonFilterableProperties: [
    dispatchStatusCriticality, bestQuote, bestQuoteCurrency, quoteCount,
    quoteDeadline, sourceLocation, destinationLocation, pickupDateTime, deliveryDateTime
  ]
  entity FreightOrders as projection on FO.FreightOrder {
    key TransportationOrder,
        // not a key here: the readable number is
        TransportationOrderUUID,
        TransportationOrderType,
        TransportationMode,
        Carrier,
        Shipper,
        Consignee,
        TranspPurgOrg,
        TranspPurgGroup,
        TranspOrdResponsiblePerson,
        TranspOrdLifeCycleStatus,
        TranspOrdExecutionIsBlocked,
        TranspOrdOrderDateTime,
        _FreightOrderStop : redirected to FreightOrderStops,
        _FreightOrderItem : redirected to FreightOrderItems,
        // lane and dates: first and last stop
        virtual sourceLocation            : String(20),
        virtual destinationLocation       : String(20),
        virtual pickupDateTime            : Timestamp,
        virtual deliveryDateTime          : Timestamp,
        // enrichment from local dispatch data
        virtual dispatchStatus            : String(10),
        virtual dispatchStatusCriticality : Integer,
        virtual bestQuote                 : Decimal(15, 2),
        virtual bestQuoteCurrency         : String(3),
        virtual quoteCount                : Integer,
        virtual quoteDeadline             : Timestamp,
        virtual deadlineExpired           : Boolean,
        dispatch     : Association to one Dispatch on dispatch.freightOrderId = $self.TransportationOrder,
        freightUnits : Association to many FreightUnits on freightUnits.freightOrderId = $self.TransportationOrder,
  } actions {
    // Bound here, not on Dispatch, so the list report can offer them in its toolbar;
    // they create the dispatch if the order was never opened. Writes stay local.
    action startTender(
      mode     : String(10) @mandatory,
      deadline : Timestamp  @mandatory,
      carriers : many String(10)
    );
    action cancelTender(reason : String(1000) @mandatory);
  };

  @readonly
  entity FreightOrderStops as projection on FO.FreightOrderStop {
    key TransportationOrderStopUUID,
        TransportationOrderUUID,
        TransportationOrderStop,
        TranspOrdStopCategory,
        TranspOrdStopRole,
        TranspOrdStopSequencePosition,
        LocationId,
        TranspOrdStopPlanTranspDteTme,
        _FreightOrder,
        _FreightOrderStage : redirected to FreightOrderStages,
  };

  @readonly
  entity FreightOrderStages as projection on FO.FreightOrderStage {
    key TransportationOrderStageUUID,
        TransportationOrderUUID,
        TransportationOrderStage,
        TranspOrdStageType,
        TransportationMode,
        TranspOrdStageSrceStopUUID,
        TranspOrdStageDestStopUUID,
        TranspOrdStageDistance,
        TranspOrdStageDistanceUnit,
        TranspOrdStageNetDuration,
        _FreightOrder,
        _FreightOrderStop,
  };

  @readonly
  entity FreightOrderItems as projection on FO.FreightOrderItem {
    key TransportationOrderItemUUID,
        TransportationOrderUUID,
        TranspOrdItem,
        TranspOrdItemType,
        TranspOrdItemDesc,
        IsMainCargoItem,
        FreightUnitUUID,
        ProductID,
        TranspOrdItemQuantity,
        TranspOrdItemQuantityUnit,
        TranspOrdItemGrossWeight,
        TranspOrdItemGrossWeightUnit,
        TranspOrdItemGrossVolume,
        TranspOrdItemGrossVolumeUnit,
        _FreightOrder,
  };

  /**
   * Freight units of one freight order: read with $filter=freightOrderId eq '…', via
   * FreightOrders('…')/freightUnits, or expanded on a single freight order. TM has no
   * freight order reference on the unit; freightOrderId is filled by the handler.
   */
  @readonly
  @Capabilities.SearchRestrictions.Searchable: false
  entity FreightUnits as projection on FU.FreightUnit {
    key TransportationOrderUUID,
        TransportationOrder,
        TransportationOrderType,
        TransportationMode,
        Shipper,
        Consignee,
        TranspOrdLifeCycleStatus,
        TranspOrdPlanningStatus,
        TranspOrdExecutionIsBlocked,
        cast('' as String(20)) as freightOrderId,
  };

  // --- local ----------------------------------------------------------------------

  /**
   * One per freight order, created on the first single read of FreightOrders. Only
   * exceptions and notes are edited in the draft; status, award fields and rounds
   * change through the actions, which work on the active instance.
   */
  @odata.draft.enabled
  @restrict: [{ grant: '*', to: 'Dispatcher' }]   // draft events and closeRound, reportException
  @Capabilities.InsertRestrictions.Insertable: false
  @Capabilities.DeleteRestrictions.Deletable: false
  entity Dispatch as projection on db.FreightOrderDispatch actions {
    action closeRound() returns Dispatch;
    action reportException(
      type    : String(12) @mandatory,
      reason  : String(10),
      minutes : Integer
    ) returns Dispatch;
  };

  @readonly entity TenderRounds as projection on db.TenderRounds;

  @readonly
  @restrict: [{ grant: ['READ', 'award'], to: 'Dispatcher' }]
  entity CarrierOffers as projection on db.CarrierOffers actions {
    action award() returns CarrierOffers;
  };

  entity ExecutionEvents as projection on db.ExecutionEvents;
  entity DispatchNotes   as projection on db.DispatchNotes;

  @readonly
  entity Carriers as projection on db.Carriers where active = true;
}

// Owned by the actions: never taken from a draft or a PATCH.
annotate DispatchService.Dispatch with {
  freightOrderId  @readonly;
  dispatchStatus  @readonly;
  awardedCarrier  @readonly;
  awardedPrice    @readonly;
  currency        @readonly;
  awardedAt       @readonly;
  awardedBy       @readonly;
  quoteDeadline   @readonly;
};

// The TM entities carry @Common.Messages: SAP__Messages, but the projections do not
// expose that element. Fiori elements would then put SAP__Messages into $select, and
// UI5 rejects the whole object page binding ("Invalid (navigation) property").
annotate DispatchService.FreightOrders      with @Common.Messages: null;
annotate DispatchService.FreightOrderStops  with @Common.Messages: null;
annotate DispatchService.FreightOrderStages with @Common.Messages: null;
annotate DispatchService.FreightOrderItems  with @Common.Messages: null;
annotate DispatchService.FreightUnits       with @Common.Messages: null;
