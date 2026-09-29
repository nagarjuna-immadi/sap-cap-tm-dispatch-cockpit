using DispatchService as service from '../../srv/dispatch-service';

/*
 * Dispatch Cockpit (blueprint §7, development plan phase 2).
 *
 * Pages: FreightOrders list → FreightOrders object page (TM data, read-only)
 *        → "Open Tender" → Dispatch object page (draft: rounds, exceptions, notes)
 *        → TenderRounds object page (offers with the inline Award action).
 * Dispatch is its own top-level route: FreightOrders is remote and not draft-enabled,
 * so the local compositions cannot be read or edited through FreightOrders('…')/dispatch.
 * Value helps and code list texts live in srv/common-annotations.cds.
 */

// === FreightOrders (TM, enriched) ===================================================

annotate service.FreightOrders with {
  TransportationOrder       @title: 'Freight Order';
  TransportationOrderUUID   @UI.Hidden;
  sourceLocation            @title: 'Source';
  destinationLocation       @title: 'Destination';
  pickupDateTime            @title: 'Pick-Up';
  deliveryDateTime          @title: 'Delivery';
  dispatchStatus            @title: 'Dispatch Status';
  dispatchStatusCriticality @UI.Hidden;
  bestQuote                 @title: 'Best Quote'  @Measures.ISOCurrency: bestQuoteCurrency;
  bestQuoteCurrency         @title: 'Quote Currency';
  quoteCount                @title: 'Quotes';
  quoteDeadline             @title: 'Quote Deadline';
  deadlineExpired           @title: 'Deadline Expired';
};

annotate service.FreightOrders with @(
  // Source, destination and pick-up date are derived from the stops and are not
  // filterable yet (NonFilterableProperties in dispatch-service.cds).
  UI.SelectionFields: [
    TransportationMode,
    dispatchStatus,
    deadlineExpired,
  ],

  UI.LineItem: [
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.startTender', Label: 'Start Tender' },
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.cancelTender', Label: 'Cancel Tender' },
    { Value: TransportationOrder },
    { Value: sourceLocation },
    { Value: destinationLocation },
    { Value: pickupDateTime },
    { Value: deliveryDateTime },
    { Value: dispatchStatus, Criticality: dispatchStatusCriticality },
    { Value: bestQuote },
    { Value: quoteCount },
    { Value: quoteDeadline },
  ],

  UI.HeaderInfo: {
    TypeName      : 'Freight Order',
    TypeNamePlural: 'Freight Orders',
    Title         : { Value: TransportationOrder },
    Description   : { Value: TransportationOrderType },
  },

  // Header actions; "Open Tender" is a custom action in manifest.json
  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.startTender', Label: 'Start Tender' },
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.cancelTender', Label: 'Cancel Tender' },
  ],

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', ID: 'Lane', Label: 'Lane', Target: '@UI.FieldGroup#Lane' },
    { $Type: 'UI.ReferenceFacet', ID: 'DispatchStatus', Target: '@UI.DataPoint#DispatchStatus' },
    { $Type: 'UI.ReferenceFacet', ID: 'Award', Label: 'Award', Target: '@UI.FieldGroup#Award' },
  ],

  UI.DataPoint #DispatchStatus: {
    Value      : dispatchStatus,
    Title      : 'Dispatch Status',
    Criticality: dispatchStatusCriticality,
  },

  UI.FieldGroup #Lane: { Data: [
    { Value: sourceLocation },
    { Value: destinationLocation },
    { Value: pickupDateTime },
    { Value: deliveryDateTime },
  ] },

  UI.FieldGroup #Award: { Data: [
    { Value: dispatch.awardedCarrier },
    { Value: dispatch.awardedPrice },
    { Value: dispatch.awardedAt },
  ] },

  UI.FieldGroup #TMStatus: { Data: [
    { Value: TransportationOrderType },
    { Value: TransportationMode },
    { Value: TranspOrdLifeCycleStatus },
    { Value: TranspOrdExecutionIsBlocked },
    { Value: Shipper },
    { Value: Consignee },
    { Value: TranspPurgOrg },
    { Value: TranspPurgGroup },
    { Value: TranspOrdResponsiblePerson },
    { Value: TranspOrdOrderDateTime },
  ] },

  UI.FieldGroup #Tender: { Data: [
    { Value: dispatchStatus, Criticality: dispatchStatusCriticality },
    { Value: quoteDeadline },
    { Value: deadlineExpired },
    { Value: bestQuote },
    { Value: quoteCount },
  ] },

  UI.Facets: [
    {
      $Type : 'UI.CollectionFacet',
      ID    : 'TMData',
      Label : 'TM Data',
      Facets: [
        { $Type: 'UI.ReferenceFacet', ID: 'TMStatus', Label: 'Status', Target: '@UI.FieldGroup#TMStatus' },
        { $Type: 'UI.ReferenceFacet', ID: 'Stops', Label: 'Stops', Target: '_FreightOrderStop/@UI.LineItem' },
        { $Type: 'UI.ReferenceFacet', ID: 'Items', Label: 'Weight and Volume', Target: '_FreightOrderItem/@UI.LineItem' },
      ],
    },
    { $Type: 'UI.ReferenceFacet', ID: 'FreightUnits', Label: 'Freight Units', Target: 'freightUnits/@UI.LineItem' },
    { $Type: 'UI.ReferenceFacet', ID: 'Tender', Label: 'Tender', Target: '@UI.FieldGroup#Tender' },
  ],
);

// Refresh the enrichment of the row / page the action ran on
annotate service.FreightOrders with actions {
  startTender @(Common.SideEffects: {
    TargetProperties: [
      'in/dispatchStatus', 'in/dispatchStatusCriticality', 'in/quoteDeadline', 'in/deadlineExpired',
      'in/bestQuote', 'in/bestQuoteCurrency', 'in/quoteCount',
    ],
    TargetEntities: ['in/dispatch'],
  })(
    mode     @title: 'Tender Mode',
    deadline @title: 'Quote Deadline',
    carriers @title: 'Carriers'
  );
  cancelTender @(Common.SideEffects: {
    TargetProperties: [
      'in/dispatchStatus', 'in/dispatchStatusCriticality', 'in/quoteDeadline', 'in/deadlineExpired',
      'in/bestQuote', 'in/bestQuoteCurrency', 'in/quoteCount',
    ],
    TargetEntities: ['in/dispatch'],
  })(
    reason @title: 'Reason' @UI.MultiLineText
  );
};

// --- TM tables on the freight order page ---------------------------------------------

annotate service.FreightOrderStops with @(UI.LineItem: [
  { Value: TransportationOrderStop },
  { Value: TranspOrdStopSequencePosition },
  { Value: TranspOrdStopRole },
  { Value: LocationId },
  { Value: TranspOrdStopPlanTranspDteTme },
]);

annotate service.FreightOrderItems with @(UI.LineItem: [
  { Value: TranspOrdItem },
  { Value: TranspOrdItemDesc },
  { Value: TranspOrdItemType },
  { Value: ProductID },
  { Value: TranspOrdItemQuantity },
  { Value: TranspOrdItemGrossWeight },
  { Value: TranspOrdItemGrossVolume },
]);

annotate service.FreightUnits with {
  TransportationOrder @title: 'Freight Unit';
  freightOrderId      @UI.Hidden;
};

annotate service.FreightUnits with @(UI.LineItem: [
  { Value: TransportationOrder },
  { Value: TransportationOrderType },
  { Value: TransportationMode },
  { Value: TranspOrdLifeCycleStatus },
  { Value: TranspOrdPlanningStatus },
  { Value: TranspOrdExecutionIsBlocked },
]);

// === Dispatch (local, draft) ========================================================

annotate service.Dispatch with {
  freightOrderId @title: 'Freight Order';
  dispatchStatus @title: 'Dispatch Status';
  awardedCarrier @title: 'Awarded Carrier';
  awardedPrice   @title: 'Awarded Price'  @Measures.ISOCurrency: currency_code;
  awardedAt      @title: 'Awarded At';
  awardedBy      @title: 'Awarded By';
  quoteDeadline  @title: 'Quote Deadline';
};

annotate service.Dispatch with @(
  UI.HeaderInfo: {
    TypeName      : 'Dispatch',
    TypeNamePlural: 'Dispatches',
    Title         : { Value: freightOrderId },
  },

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.closeRound', Label: 'Close Round' },
    { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.reportException', Label: 'Report Exception' },
  ],

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DispatchStatus', Target: '@UI.DataPoint#DispatchStatus' },
    { $Type: 'UI.ReferenceFacet', ID: 'QuoteDeadline', Target: '@UI.DataPoint#QuoteDeadline' },
    { $Type: 'UI.ReferenceFacet', ID: 'Award', Label: 'Award', Target: '@UI.FieldGroup#Award' },
  ],

  UI.DataPoint #DispatchStatus: {
    Value      : dispatchStatus_code,
    Title      : 'Dispatch Status',
    Criticality: dispatchStatus.criticality,
  },

  UI.DataPoint #QuoteDeadline: {
    Value: quoteDeadline,
    Title: 'Quote Deadline',
  },

  UI.FieldGroup #Award: { Data: [
    { Value: awardedCarrier },
    { Value: awardedPrice },
    { Value: awardedAt },
    { Value: awardedBy },
  ] },

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'Rounds', Label: 'Tender Rounds', Target: 'rounds/@UI.PresentationVariant' },
    { $Type: 'UI.ReferenceFacet', ID: 'Exceptions', Label: 'Exceptions', Target: 'exceptions/@UI.LineItem' },
    { $Type: 'UI.ReferenceFacet', ID: 'Notes', Label: 'Notes', Target: 'notes/@UI.LineItem' },
  ],
);

// Actions work on the saved dispatch only (lockDispatch rejects drafts)
annotate service.Dispatch with actions {
  closeRound @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/IsActiveEntity' } },
    Common.SideEffects     : {
      TargetProperties: ['in/dispatchStatus_code', 'in/quoteDeadline'],
      TargetEntities  : ['in/rounds'],
    }
  );
  reportException @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/IsActiveEntity' } },
    Common.SideEffects     : { TargetEntities: ['in/exceptions'] }
  )(
    type    @title: 'Event Type',
    reason  @title: 'Delay Reason',
    minutes @title: 'Delay (Minutes)'
  );
};

// --- tender rounds and offers ---------------------------------------------------------

annotate service.TenderRounds with {
  roundNumber @title: 'Round';
  mode        @title: 'Tender Mode';
  deadline    @title: 'Quote Deadline';
  closed      @title: 'Closed';
};

annotate service.TenderRounds with @(
  UI.HeaderInfo: {
    TypeName      : 'Tender Round',
    TypeNamePlural: 'Tender Rounds',
    Title         : { Value: roundNumber },
  },

  UI.LineItem: [
    { Value: roundNumber },
    { Value: mode_code },
    { Value: deadline },
    { Value: closed },
  ],

  // Latest round first
  UI.PresentationVariant: {
    SortOrder     : [{ Property: roundNumber, Descending: true }],
    Visualizations: ['@UI.LineItem'],
  },

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', ID: 'Round', Target: '@UI.FieldGroup#Round' },
  ],

  UI.FieldGroup #Round: { Data: [
    { Value: mode_code },
    { Value: deadline },
    { Value: closed },
  ] },

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'Offers', Label: 'Offers', Target: 'offers/@UI.LineItem' },
  ],
);

annotate service.CarrierOffers with {
  carrierId    @title: 'Carrier';
  carrierName  @title: 'Carrier Name';
  status       @title: 'Status';
  price        @title: 'Price'  @Measures.ISOCurrency: currency_code;
  transitHours @title: 'Transit (Hours)';
  respondedAt  @title: 'Responded At';
  comment      @title: 'Comment';
};

annotate service.CarrierOffers with @(UI.LineItem: [
  { Value: carrierId },   // shown as "name (ID)", see srv/common-annotations.cds
  { Value: status_code, Criticality: status.criticality },
  { Value: price },
  { Value: transitHours },
  { Value: respondedAt },
  { Value: comment },
  { $Type: 'UI.DataFieldForAction', Action: 'DispatchService.award', Label: 'Award', Inline: true },
]);

// Award: only a quoted offer of the saved dispatch; the rest of the round changes too
// (other quotes LOST, unanswered EXPIRED, round closed) and the dispatch gets the award,
// so there is no need to close the round by hand.
annotate service.CarrierOffers with actions {
  award @(
    Core.OperationAvailable: { $edmJson: { $And: [
      { $Path: 'in/IsActiveEntity' },
      { $Eq: [{ $Path: 'in/status_code' }, 'QUOTED'] },
    ] } },
    // the absolute path re-reads every page under Dispatch, including the round page the
    // action runs on (a path through in/parent does not reach that page's own context)
    Common.SideEffects     : { TargetEntities: [
      'in/parent', 'in/parent/offers', 'in/parent/parent', '/DispatchService.EntityContainer/Dispatch',
    ] }
  );
};

// --- exceptions and notes (edited in the dispatch draft) -------------------------------

annotate service.ExecutionEvents with {
  eventType   @title: 'Event Type';
  eventTime   @title: 'Event Time';
  delayReason @title: 'Delay Reason';
  delayMins   @title: 'Delay (Minutes)';
  comment     @title: 'Comment';
};

annotate service.ExecutionEvents with @(UI.LineItem: [
  { Value: eventType_code },
  { Value: eventTime },
  { Value: delayReason_code },
  { Value: delayMins },
  { Value: comment },
]);

annotate service.DispatchNotes with {
  text @title: 'Note'  @UI.MultiLineText;
};

annotate service.DispatchNotes with @(UI.LineItem: [
  { Value: text },
  { Value: createdBy },
  { Value: createdAt },
]);
