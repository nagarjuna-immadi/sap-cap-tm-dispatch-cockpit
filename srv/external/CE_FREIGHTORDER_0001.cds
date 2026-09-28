/* checksum : 12ba818eb391f11ab63f594a19ddf582 */
@cds.external : true
@CodeList.CurrencyCodes.Url : '../../../../default/iwbep/common/0001/$metadata'
@CodeList.CurrencyCodes.CollectionPath : 'Currencies'
@CodeList.UnitsOfMeasure.Url : '../../../../default/iwbep/common/0001/$metadata'
@CodeList.UnitsOfMeasure.CollectionPath : 'UnitsOfMeasure'
@Common.ApplyMultiUnitBehaviorForSortingAndFiltering : true
@Capabilities.FilterFunctions : [
  'eq',
  'ne',
  'gt',
  'ge',
  'lt',
  'le',
  'and',
  'or',
  'contains',
  'startswith',
  'endswith',
  'any',
  'all'
]
@SAP__support.TechnicalInfoLinks.Url : '../../../../default/iwbep/common/0001/$metadata'
@SAP__support.TechnicalInfoLinks.FunctionImport : 'GetTechnicalInfoLinks'
@Capabilities.SupportedFormats : [ 'application/json', 'application/pdf' ]
@PDF.Features.DocumentDescriptionReference : '../../../../default/iwbep/common/0001/$metadata'
@PDF.Features.DocumentDescriptionCollection : 'MyDocumentDescriptions'
@PDF.Features.ArchiveFormat : true
@PDF.Features.Border : true
@PDF.Features.CoverPage : true
@PDF.Features.FitToPage : true
@PDF.Features.FontName : true
@PDF.Features.FontSize : true
@PDF.Features.HeaderFooter : true
@PDF.Features.IANATimezoneFormat : true
@PDF.Features.Margin : true
@PDF.Features.Padding : true
@PDF.Features.ResultSizeDefault : 20000
@PDF.Features.ResultSizeMaximum : 20000
@PDF.Features.Signature : true
@PDF.Features.TextDirectionLayout : true
@PDF.Features.Treeview : true
@PDF.Features.UploadToFileShare : true
@Capabilities.BatchSupport.SupportedFormats : [ 'application/json', 'multipart/mixed' ]
@Capabilities.KeyAsSegmentSupported : true
@Capabilities.AsynchronousRequestsSupported : true
service CE_FREIGHTORDER_0001 {
  @cds.external : true
  type TransportationOrderChangeLocationSequenceResult_Type {
    _LocationSequence : many D_TranspOrdChgLocSqncLocSqncR not null;
  };

  @cds.external : true
  type D_FreightOrderCrteForPkupItmP {
    @Common.FieldControl : #Mandatory
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Freight Booking Item UUID'
    FreightBookingItemUUID : UUID;
  };

  @cds.external : true
  type D_FreightOrdCrteForDelivItmP {
    @Common.FieldControl : #Mandatory
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Freight Booking Item UUID'
    FreightBookingItemUUID : UUID;
  };

  @cds.external : true
  type D_FreightUnitAssignParameter {
    @Common.Label : 'Freight Unit UUID'
    FreightUnitUUID : UUID;
  };

  @cds.external : true
  type D_FreightUnitUnassignParameter {
    @Common.Label : 'Freight Unit UUID'
    FreightUnitUUID : UUID;
  };

  @cds.external : true
  type TransportationOrderGetLocationSequenceResult_Type {
    _LocationSequence : many D_TranspOrdGetLocSqncLocSqncR not null;
  };

  @cds.external : true
  type D_TranspOrdChgLocSqncLocSqncR {
    @Common.Label : 'Location Sequence Position'
    @Common.QuickInfo : 'Transportation Order Location Sequence Position'
    TranspOrderLocationPosition : Integer not null;
    @Common.Label : 'Location'
    LocationId : String(20) not null;
    @Common.Label : 'Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stop UUID'
    TransportationOrderStopUUID : UUID;
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Category'
    TranspOrdStopCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Position'
    @Common.Heading : 'Stop Position in Transportation Stop Sequence'
    @Common.QuickInfo : 'Stop Position in Transportation Stop Sequence'
    TranspOrdStopSequencePosition : String(1) not null;
  };

  @cds.external : true
  type D_TranspOrdGetLocSqncLocSqncR {
    @Common.Label : 'Location Sequence Position'
    @Common.QuickInfo : 'Transportation Order Location Sequence Position'
    TranspOrderLocationPosition : Integer not null;
    @Common.Label : 'Location'
    LocationId : String(20) not null;
    @Common.Label : 'Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stop UUID'
    TransportationOrderStopUUID : UUID;
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Category'
    TranspOrdStopCategory : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Position'
    @Common.Heading : 'Stop Position in Transportation Stop Sequence'
    @Common.QuickInfo : 'Stop Position in Transportation Stop Sequence'
    TranspOrdStopSequencePosition : String(1) not null;
  };

  @cds.external : true
  type D_TranspOrdChgLocSqncLocSqncP {
    @Common.FieldControl : #Mandatory
    @Common.Label : 'Location Sequence Position'
    @Common.QuickInfo : 'Transportation Order Location Sequence Position'
    TranspOrderLocationPosition : Integer not null;
    @Common.FieldControl : #Mandatory
    @Common.Label : 'Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stop UUID'
    TransportationOrderStopUUID : UUID;
  };

  @cds.external : true
  type D_TranspOrdReportEventItemP {
    @Common.Label : 'UUID of TO Item'
    @Common.Heading : 'UUID of Transportation Order Item with Conversion Exit'
    @Common.QuickInfo : 'UUID of Transportation Order Item with Conversion Exit'
    TransportationOrderItemUUID : UUID;
  };

  @cds.external : true
  type SAP__Message {
    code : String not null;
    message : String not null;
    target : String;
    additionalTargets : many String not null;
    transition : Boolean not null;
    @odata.Type : 'Edm.Byte'
    numericSeverity : Integer not null;
    longtextUrl : String;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrderBusinessPartner,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _FreightOrderDocumentReference,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _FreightOrderItem,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_CarrierAddrDfltRprstn',
    '_ConsigneeAddrDfltRprstn',
    '_ExectgCarrierAddrDfltRprstn',
    '_FreightOrderBusinessPartner',
    '_FreightOrderCharge',
    '_FreightOrderDocumentReference',
    '_FreightOrderEvent',
    '_FreightOrderItem',
    '_FreightOrderStop',
    '_FrtOrdMainBPAddrDfltRprstn',
    '_ShipperAddrDfltRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ 'ChangedDateTime' ]
  entity FreightOrder {
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    key TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Order'
    TransportationOrder : String(20) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderType'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Order Type'
    TransportationOrderType : String(4) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Order Category'
    TransportationOrderCategory : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderShippingType'
    @Common.IsUpperCase : true
    @Common.Label : 'Shipping Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FSHIPPING_TYPE'
    TransportationShippingType : String(3) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationMode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Mode'
    TransportationMode : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationModeCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Mode Category'
    TransportationModeCategory : String(1) not null;
    @Common.Label : 'Carrier UUID'
    CarrierUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Carrier'
    Carrier : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'StandardCarrierAlphaCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'SCAC'
    @Common.Heading : 'Standard Carrier Alpha Code'
    @Common.QuickInfo : 'Standard Carrier Alpha Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FSCACD'
    StandardCarrierAlphaCode : String(4) not null;
    @Common.Label : 'Executing Carrier UUID'
    TranspOrdExecutingCarrierUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Executing Carrier'
    TranspOrdExecutingCarrier : String(10) not null;
    @Common.Label : 'Shipper UUID'
    @Common.QuickInfo : 'Shipper Universally Unique Identifier'
    ShipperUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Shipper'
    Shipper : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'Shipper Address ID'
    ShipperAddressID : String(40) not null;
    @Common.Label : 'Ship-to Party UUID'
    ConsigneeUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Ship-to Party'
    Consignee : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'Ship-to Party Address ID'
    ConsigneeAddressID : String(40) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Purch. Organization'
    @Common.Heading : 'Purchasing Organization'
    @Common.QuickInfo : 'Purchasing Organization'
    TranspPurgOrg : String(8) not null;
    @Common.Label : 'Purch. Org. Ext. ID'
    @Common.QuickInfo : 'Purchasing Organization External ID'
    TranspPurgOrgExtID : String(20) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Purchasing Group'
    TranspPurgGroup : String(8) not null;
    @Common.Label : 'Purch. Grp Ext. ID'
    @Common.QuickInfo : 'Purchasing Group External ID'
    TranspPurgGroupExtID : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Company Code'
    @Common.Heading : 'CoCd'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BUKRS'
    PurgOrgCompanyCode : String(4) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Acct w/ Carrier'
    @Common.Heading : 'Account Number with Carrier'
    @Common.QuickInfo : 'Account Number with the Executing Carrier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEIKTO_K'
    CarrierAccountNumber : String(14) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationMeansOfTransport'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Means of Transport'
    @Common.Heading : 'MTr'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSAPAPO%2FTR_TRATY'
    TranspMeansOfTransport : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Ref. Number'
    @Common.Heading : 'Partner Reference Number'
    @Common.QuickInfo : 'Partner Reference Number'
    TranspOrdPartnerReference : String(35) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Person Responsible'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FRESP_PERSON'
    TranspOrdResponsiblePerson : String(12) not null;
    @Core.Computed : true
    @Common.Label : 'Mult. Exec. Parties'
    @Common.Heading : 'Multiple Executing Parties'
    @Common.QuickInfo : 'Multiple Executing Parties'
    TranspOrdHasMltplExectgPties : Boolean not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdInvoicingCarrierLevel'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Inv. Carrier Level'
    @Common.Heading : 'Invoicing Carrier Level'
    @Common.QuickInfo : 'Invoicing Carrier Level'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FPYMT_IND'
    TranspOrdInvoicingCarrierLevel : String(2) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Order Date Time'
    @Common.QuickInfo : 'Transportation Order Order Date Time'
    TranspOrdOrderDateTime : DateTime;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderLifecycleStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Lifecycle Status'
    @Common.QuickInfo : 'Transportation Order Lifecycle Status'
    TranspOrdLifeCycleStatus : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdSubcontractingStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Subcontr. Status'
    @Common.Heading : 'Subcontracting Status'
    @Common.QuickInfo : 'Subcontracting Status'
    TranspOrderSubcontrgSts : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderConfirmationStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Confirm. Status'
    @Common.Heading : 'Confirmation Status'
    @Common.QuickInfo : 'Confirmation Status'
    TransportationOrderConfSts : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderExecutionStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Execution Status'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTOR_EXECUTION_STATUS'
    TransportationOrderExecSts : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdGoodsMovementStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Goods Mvmt. Status'
    @Common.Heading : 'GM Status'
    @Common.QuickInfo : 'Delivery Goods Movement Status'
    TranspOrdGoodsMovementStatus : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdWhseProcessingStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Whse Proc. Status'
    @Common.Heading : 'Warehouse Processing Status'
    @Common.QuickInfo : 'Warehouse Processing Status'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FWH_PROCESSING_STATUS'
    TranspOrdWhseProcessingStatus : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdDangerousGoodsStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Dangerous Goods Sts'
    @Common.QuickInfo : 'Transportation Order Dangerous Goods Status'
    TranspOrderDngrsGdsSts : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Execution Block'
    @Common.QuickInfo : 'Transportation Order Execution Block'
    TranspOrdExecutionIsBlocked : Boolean not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderCreationType'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Creation Type'
    TransportationOrderCrtnType : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Created By'
    @Common.QuickInfo : 'Created By User'
    CreatedByUser : String(12) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Creation Date Time'
    @Common.QuickInfo : 'Transportation Order Creation Date Time'
    CreationDateTime : DateTime;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Changed By'
    @Common.QuickInfo : 'Last Changed By User'
    LastChangedByUser : String(12) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Transportation Order Changed Date Time'
    @Common.QuickInfo : 'Transportation Order Changed Date and Time'
    ChangedDateTime : DateTime;
    SAP__Messages : many SAP__Message not null;
    _CarrierAddrDfltRprstn : Association to one FrtOrdMainBPAddrDfltRprstn {  };
    _ConsigneeAddrDfltRprstn : Association to one FrtOrdMainBPAddrDfltRprstn {  };
    _ExectgCarrierAddrDfltRprstn : Association to one FrtOrdMainBPAddrDfltRprstn {  };
    @Common.Composition : true
    _FreightOrderBusinessPartner : Composition of many FreightOrderBusinessPartner on _FreightOrderBusinessPartner._FreightOrder = $self;
    @Common.Composition : true
    _FreightOrderCharge : Composition of one FreightOrderCharge on _FreightOrderCharge._FreightOrder = $self;
    @Common.Composition : true
    _FreightOrderDocumentReference : Composition of many FreightOrderDocumentReference on _FreightOrderDocumentReference._FreightOrder = $self;
    @Common.Composition : true
    _FreightOrderEvent : Composition of many FreightOrderEvent on _FreightOrderEvent._FreightOrder = $self;
    @Common.Composition : true
    _FreightOrderItem : Composition of many FreightOrderItem on _FreightOrderItem._FreightOrder = $self;
    @Common.Composition : true
    _FreightOrderStop : Composition of many FreightOrderStop on _FreightOrderStop._FreightOrder = $self;
    @Common.Composition : true
    _FrtOrdMainBPAddrDfltRprstn : Composition of many FrtOrdMainBPAddrDfltRprstn on _FrtOrdMainBPAddrDfltRprstn._FreightOrder = $self;
    _ShipperAddrDfltRprstn : Association to one FrtOrdMainBPAddrDfltRprstn {  };
  } actions {
    action CreateFreightOrder(
      @Common.FieldControl : #Mandatory
      @Common.IsUpperCase : true
      @Common.Label : 'Document Type'
      @Common.Heading : 'Business Document Type'
      @Common.QuickInfo : 'Business Document Type'
      @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTOR_TYPE'
      TransportationOrderType : String(4) not null,
      @Common.IsUpperCase : true
      @Common.Label : 'Document'
      TransportationOrder : String(20) not null
    ) returns FreightOrder not null;
    action SendToCarrier();
    action ChangeLocationSequence(
      @Common.FieldControl : #Mandatory
      _LocationSequence : many D_TranspOrdChgLocSqncLocSqncP not null
    ) returns TransportationOrderChangeLocationSequenceResult_Type not null;
    action CreateForDelivery(
      @Common.FieldControl : #Mandatory
      @Common.IsUpperCase : true
      @Common.Label : 'Document Type'
      @Common.Heading : 'Business Document Type'
      @Common.QuickInfo : 'Business Document Type'
      @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTOR_TYPE'
      TransportationOrderType : String(4) not null,
      _FreightBookingItems : many D_FreightOrdCrteForDelivItmP not null
    ) returns many FreightOrder not null;
    action UnassignFreightUnit(
      _FreightUnits : many D_FreightUnitUnassignParameter not null
    );
    action CalculateTransportationCharges();
    action SetToNotReadyForTranspExec();
    action CancelFreightOrder();
    action SetConfStatusToConfirmed();
    action SetToReadyForTranspExecution();
    action SetConfStatusToRejected();
    action SendShippingNotification();
    action CreateForPickup(
      @Common.FieldControl : #Mandatory
      @Common.IsUpperCase : true
      @Common.Label : 'Document Type'
      @Common.Heading : 'Business Document Type'
      @Common.QuickInfo : 'Business Document Type'
      @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTOR_TYPE'
      TransportationOrderType : String(4) not null,
      _FreightBookingItems : many D_FreightOrderCrteForPkupItmP not null
    ) returns many FreightOrder not null;
    action AssignFreightUnit(
      @Common.Label : 'UUID of TO Item'
      @Common.Heading : 'UUID of Transportation Order Item with Conversion Exit'
      @Common.QuickInfo : 'UUID of Transportation Order Item with Conversion Exit'
      TransportationOrderItemUUID : UUID default null,
      _FreightUnits : many D_FreightUnitAssignParameter not null
    );
    action SetConfStsToConfdWithChanges();
    action ReportEvent(
      @Common.FieldControl : #Mandatory
      @Common.IsUpperCase : true
      @Common.Label : 'Event'
      @Common.QuickInfo : 'Event Occurring for a Transportation Activity'
      @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTOR_EVENT'
      TranspOrdEventCode : String(20) not null,
      @Common.Label : 'UUID of TO Stop'
      @Common.Heading : 'UUID of Stop of Transport. Order with Conversion Exit'
      @Common.QuickInfo : 'UUID of Stop of Transportation Order with Conversion Exit'
      TransportationOrderStopUUID : UUID default null,
      @odata.Precision : 0
      @odata.Type : 'Edm.DateTimeOffset'
      @Common.Label : 'Event Actual Date Time'
      @Common.QuickInfo : 'Transportation Order Event Actual Date Time'
      TranspOrdEvtActualDateTime : DateTime default null,
      @odata.Precision : 0
      @odata.Type : 'Edm.DateTimeOffset'
      @Common.Label : 'Event Estimated Date Time'
      @Common.QuickInfo : 'Transportation Order Event Estimated Date Time'
      TranspOrdEvtEstimatedDateTime : DateTime default null,
      _TransportationOrderItems : many D_TranspOrdReportEventItemP not null
    );
    function GetLocationSequence() returns TransportationOrderGetLocationSequenceResult_Type not null;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Business Partner'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FreightOrderBusinessPartner {
    @Core.Computed : true
    @Common.Label : 'Transp. Order Business Partner UUID'
    @Common.QuickInfo : 'Transportation Order Business Partner UUID'
    key TransportationOrderBusPartUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.Label : 'BP GUID'
    @Common.Heading : 'Business Partner GUID'
    @Common.QuickInfo : 'Business Partner GUID'
    BusinessPartnerUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Business Partner'
    @Common.QuickInfo : 'Business Partner Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=BU_PARTNER'
    BusinessPartner : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'PartnerFunction'
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.Label : 'Address ID'
    @Common.QuickInfo : 'Unique Identifier for Address (APC_V_ADDRESS_ID)'
    TranspOrdBizPartnerAddressID : String(40) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    _FrtOrdBPAddrDfltRprstn : Composition of one FrtOrdBPAddrDfltRprstn on _FrtOrdBPAddrDfltRprstn._FreightOrderBusinessPartner = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderChargeItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    {
      Property: TranspChrgTotalAmtInDocCrcy,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspChrgTotalAmtInLoclCrcy,
      AllowedExpressions: 'MultiValue'
    }
  ]
  entity FreightOrderCharge {
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Unique ID'
    @Common.QuickInfo : 'Transportation Charge UUID'
    key TransportationChargesObjUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Posting Status'
    TranspChargePostingStatus : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Charge Calc. Status'
    @Common.Heading : 'Charge Calculation Status'
    @Common.QuickInfo : 'Charge Calculation Status'
    TranspChargeCalcStatus : String(2) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FDOC_CURRENCY'
    TranspChargeDocumentCurrency : String(3) not null;
    @Measures.ISOCurrency : TranspChargeDocumentCurrency
    @Common.Label : 'Total Amount in Document Currency'
    TranspChrgTotalAmtInDocCrcy : Decimal(precision: 31) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Local Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FLCL_CURRENCY'
    TranspChargeLocalCurrency : String(3) not null;
    @Measures.ISOCurrency : TranspChargeLocalCurrency
    @Common.Label : 'Total Amount in Local Currency'
    @Common.QuickInfo : 'Total amount in Local Currency'
    TranspChrgTotalAmtInLoclCrcy : Decimal(precision: 31) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Calc. Date Timestamp'
    @Common.Heading : 'Calculation Date Timestamp'
    @Common.QuickInfo : 'Calculation Date Timestamp'
    TranspChargeCalculationDateTme : DateTime;
    @Common.Label : 'Doc. Exch. Rate Date'
    @Common.Heading : 'Exchange Date for Document Currency Conversion'
    @Common.QuickInfo : 'Exchange Rate Date for Document Currency Conversion'
    ExchangeRateDate : Date;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    _FreightOrderChargeItem : Composition of many FreightOrderChargeItem on _FreightOrderChargeItem._FreightOrderCharge = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Item'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FrtOrdChrgElement,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightOrder',
    '_FreightOrderCharge',
    '_FrtOrdChrgElement',
    '_FrtOrdChrgItmExchRate'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    {
      Property: TranspChrgItmTotAmtInDocCrcy,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspChrgItmTotAmtInLoclCrcy,
      AllowedExpressions: 'MultiValue'
    }
  ]
  entity FreightOrderChargeItem {
    @Core.Computed : true
    @Common.Label : 'Charge Item UUID'
    @Common.QuickInfo : 'Transportation Charge Item UUID'
    key TranspChargeItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Unique ID'
    @Common.QuickInfo : 'Transportation Charge UUID'
    TransportationChargesObjUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Charge Calculation Level Reference UUID'
    @Common.QuickInfo : 'Transportation Charge Calculation Level Reference UUID'
    TranspChargeCalcLevelRefUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Transportation Agreement UUID'
    @Common.QuickInfo : 'TTransportation Agreement UUID'
    TransportationAgreementUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'BP GUID'
    @Common.Heading : 'Business Partner GUID'
    @Common.QuickInfo : 'Business Partner GUID'
    BusinessPartnerUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calculation Level'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FCALC_LEVEL'
    TranspChargeCalcLevel : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Invoicing Status'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FINVOICING_STATUS_CODE'
    TranspChargePostingStatus : String(2) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Currency'
    @Common.QuickInfo : 'Transportation Charge Document Currency'
    TranspChrgItemDocCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspChrgItemDocCurrency
    @Common.Label : 'Total Amount in Document Currency'
    TranspChrgItmTotAmtInDocCrcy : Decimal(precision: 31) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Local Currency'
    @Common.QuickInfo : 'Transportation Charge Local Currency'
    TranspChrgItemLoclCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspChrgItemLoclCurrency
    @Common.Label : 'Total Amount in Local Currency'
    @Common.QuickInfo : 'Total amount in Local Currency'
    TranspChrgItmTotAmtInLoclCrcy : Decimal(precision: 31) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Calc. Date Timestamp'
    @Common.Heading : 'Calculation Date Timestamp'
    @Common.QuickInfo : 'Calculation Date Timestamp'
    TranspChargeItemCalcDateTme : DateTime;
    @Core.Computed : true
    @Common.Label : 'Doc. Exch. Rate Date'
    @Common.Heading : 'Exchange Date for Document Currency Conversion'
    @Common.QuickInfo : 'Exchange Rate Date for Document Currency Conversion'
    ExchangeRateDate : Date;
    @Core.Computed : true
    @Common.Label : 'Posting Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FINVDT'
    TranspChargePostingDate : Date;
    @Core.Computed : true
    @Common.Label : 'Man.-Chgd Calc. Date'
    @Common.Heading : 'Manually-Changed Calc. Date'
    @Common.QuickInfo : 'Manually-Changed Calculation Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FCALCDATE_FIXATION'
    TranspChrgCalcDteTmeIsChanged : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Terms of Payment'
    @Common.QuickInfo : 'Key for Terms of Payment'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=DZTERM'
    PaymentTerms : String(4) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderCharge : Association to one FreightOrderCharge on _FreightOrderCharge.TransportationChargesObjUUID = TransportationChargesObjUUID;
    @Common.Composition : true
    _FrtOrdChrgElement : Composition of many FrtOrdChrgElement on _FrtOrdChrgElement._FreightOrderChargeItem = $self;
    @Common.Composition : true
    _FrtOrdChrgItmExchRate : Composition of many FrtOrdChrgItmExchRate on _FrtOrdChrgItmExchRate._FreightOrderChargeItem = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Document Reference'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FreightOrderDocumentReference {
    @Core.Computed : true
    @Common.Label : 'Transp. Order Document Reference UUID'
    key TransportationOrderDocRefUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Business Tr. Doc. ID'
    @Common.Heading : 'Business Transaction Document ID'
    @Common.QuickInfo : 'Bus. Trans. Document ID'
    TranspOrdDocReferenceID : String(35) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocTypeCode'
    @Common.IsUpperCase : true
    @Common.Label : 'Document Type'
    @Common.Heading : 'Document Type for Business Transaction'
    @Common.QuickInfo : 'Document Type for Business Transaction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FBTD_TYPE_CODE'
    TranspOrdDocReferenceType : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'BTD Item ID'
    TranspOrdDocReferenceItmID : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocItmTypeCode'
    @Common.IsUpperCase : true
    @Common.Label : 'Base Doc. Item Type'
    @Common.Heading : 'Base Document Item Type f. Business Transaction'
    @Common.QuickInfo : 'Base Document Item Type Code for Business Transaction'
    TranspOrdDocReferenceItmType : String(5) not null;
    @Common.Label : 'Business Tr. DocDate'
    @Common.Heading : 'Business Transaction Document Date'
    @Common.QuickInfo : 'Business Transaction Document Date'
    TranspOrdDocumentReferenceDate : Date;
    @Common.Label : 'Issuing Party'
    @Common.Heading : 'Issuing Party of Bus. Trans. Document'
    @Common.QuickInfo : 'Issuing Party of Business Transaction Document'
    TranspOrdDocRefIssuerName : String(40) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Event'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightOrderEvent {
    @Core.Computed : true
    @Common.Label : 'Transportation Order Event UUID'
    key TransportationOrderEventUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Event'
    @Common.QuickInfo : 'Transportation Order Event'
    TransportationOrderEvent : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderEventCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Event Code'
    @Common.QuickInfo : 'Transportation Order Event Code'
    TranspOrdEventCode : String(20) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Event Actual Date Time'
    @Common.QuickInfo : 'Transportation Order Event Actual Date Time'
    TranspOrdEvtActualDateTime : DateTime;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Event Actual Time Zone'
    @Common.QuickInfo : 'Transp Order Event Actual Time Zone'
    TranspOrdEvtActualDateTimeZone : String(6) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Event Estimated Date Time'
    @Common.QuickInfo : 'Transportation Order Event Estimated Date Time'
    TranspOrdEvtEstimatedDateTime : DateTime;
    @Core.Computed : true
    @Common.Label : 'Location Additional UUID'
    @Common.QuickInfo : 'Location Additional UUID (RAW 16)'
    LocationAdditionalUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stop UUID'
    TransportationOrderStopUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Created By'
    @Common.QuickInfo : 'Created By User'
    CreatedByUser : String(12) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Creation Date Time'
    @Common.QuickInfo : 'Transportation Order Creation Date Time'
    CreationDateTime : DateTime;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Changed By'
    @Common.QuickInfo : 'Last Changed By User'
    LastChangedByUser : String(12) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Transportation Order Changed Date Time'
    @Common.QuickInfo : 'Transportation Order Changed Date and Time'
    ChangedDateTime : DateTime;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItemDocRef,
      InsertRestrictions: { Insertable: true }
    },
    {
      NavigationProperty: _FreightOrderItemSeal,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.RequiredProperties : [ 'TranspOrdItemType', 'TranspOrdItemParentItemUUID' ]
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableProperties : [
    'TranspOrdItemType',
    'TranspOrdItemParentItemUUID',
    'SourceStopUUID',
    'DestinationStopUUID',
    'TranspBaseDocument',
    'TranspBaseDocumentType',
    'TranspBaseDocumentItem',
    'TranspBaseDocumentItemType'
  ]
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_ConsigneeAddrDfltRprstn',
    '_FreightOrder',
    '_FreightOrderItemBatch',
    '_FreightOrderItemCommodityCode',
    '_FreightOrderItemDocRef',
    '_FreightOrderItemSeal',
    '_FreightOrderItemSerialNumber',
    '_FrtOrdItmMainBPAddrDfltRprstn',
    '_ShipperAddrDfltRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: TranspEquipCapacityLength, AllowedExpressions: 'MultiValue' },
    { Property: TranspEquipCapacityWidth, AllowedExpressions: 'MultiValue' },
    { Property: TranspEquipCapacityHeight, AllowedExpressions: 'MultiValue' },
    { Property: TranspEquipCapacityWeight, AllowedExpressions: 'MultiValue' },
    { Property: TranspEquipCapacityVolume, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItmMinTemp, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItmMaxTemp, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemQuantity, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemGrossWeight, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemGrossVolume, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemNetWeight, AllowedExpressions: 'MultiValue' }
  ]
  entity FreightOrderItem {
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    key TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item'
    TranspOrdItem : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderItemType'
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item Type'
    @Common.Heading : 'Item Type of Transportation Order'
    @Common.QuickInfo : 'Transportation Order Item Type'
    TranspOrdItemType : String(4) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderItemCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item Category'
    TranspOrdItemCategory : String(3) not null;
    @Core.Immutable : true
    @Common.Label : 'Parent Item UUID'
    @Common.QuickInfo : 'Transportation Order Parent Item UUID'
    TranspOrdItemParentItemUUID : UUID;
    @Common.Label : 'Item Description'
    TranspOrdItemDesc : String(40) not null;
    @Core.Computed : true
    @Common.Label : 'Main Cargo Item'
    IsMainCargoItem : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item Sorting'
    @Common.QuickInfo : 'Transportation Order Item Sorting'
    TranspOrdItemSorting : String(6) not null;
    @Core.Immutable : true
    @Common.Label : 'Source Stop UUID'
    SourceStopUUID : UUID;
    @Core.Immutable : true
    @Common.Label : 'Destination Stop UUID'
    DestinationStopUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Shipper UUID'
    @Common.QuickInfo : 'Shipper Universally Unique Identifier'
    ShipperUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Shipper'
    Shipper : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'Shipper Address ID'
    ShipperAddressID : String(40) not null;
    @Core.Computed : true
    @Common.Label : 'Ship-to Party UUID'
    ConsigneeUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Ship-to Party'
    Consignee : String(10) not null;
    @Core.Computed : true
    @Common.Label : 'Ship-to Party Address ID'
    ConsigneeAddressID : String(40) not null;
    @Core.Computed : true
    @Common.Label : 'Freight Unit UUID'
    FreightUnitUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Predecessor Transp Order UUID'
    @Common.QuickInfo : 'Predecessor Transportation Order UUID'
    PredecessorTransportationOrder : UUID;
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Business Tr. Doc. ID'
    @Common.Heading : 'Business Transaction Document ID'
    @Common.QuickInfo : 'Bus. Trans. Document ID'
    TranspBaseDocument : String(35) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocTypeCode'
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Type'
    @Common.Heading : 'Document Type for Business Transaction'
    @Common.QuickInfo : 'Document Type for Business Transaction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FBTD_TYPE_CODE'
    TranspBaseDocumentType : String(5) not null;
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'BTD Item ID'
    TranspBaseDocumentItem : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocItmTypeCode'
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Base Doc. Item Type'
    @Common.Heading : 'Base Document Item Type f. Business Transaction'
    @Common.QuickInfo : 'Base Document Item Type Code for Business Transaction'
    TranspBaseDocumentItemType : String(5) not null;
    @Core.Computed : true
    @Common.Label : 'Ref. to Shipm. Item'
    @Common.Heading : 'Reference to Shipment Item'
    @Common.QuickInfo : 'Reference to Shipment Item'
    TranspOrdShptItemRefUUID : UUID;
    @Common.IsUpperCase : true
    @Common.Label : 'Equipment Group'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEQUIP_GROUP'
    TransportationEquipmentGroup : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Equipment Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEQUIP_TYPE'
    TransportationEquipmentType : String(10) not null;
    @Common.Label : 'Shipper-Owned Cont.'
    @Common.Heading : 'Shipper-Owned Container'
    @Common.QuickInfo : 'Shipper-Owned Container'
    TranspEquipmentIsShipperOwned : Boolean not null;
    @Common.Label : 'Registration No.'
    @Common.Heading : 'Registration Number'
    @Common.QuickInfo : 'Registration Number'
    TranspEquipmentPlateNumber : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    TranspEquipRegistrationCountry : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspEquipCapacityUnit
    @Common.Label : 'Equipment Capacity Length'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Length'
    TranspEquipCapacityLength : Decimal(13, 3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspEquipCapacityUnit
    @Common.Label : 'Equipment Capacity Width'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Width'
    TranspEquipCapacityWidth : Decimal(13, 3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspEquipCapacityUnit
    @Common.Label : 'Equipment Capacity Height'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Height'
    TranspEquipCapacityHeight : Decimal(13, 3) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Equipment Capacity Unit of Measure'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Unit of Measure'
    TranspEquipCapacityUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspEquipCapacityWeightUnit
    @Common.Label : 'Equipment Capacity Weight'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Weight'
    TranspEquipCapacityWeight : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Equipment Capacity Weight UoM'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Weight UoM'
    TranspEquipCapacityWeightUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspEquipCapacityVolumeUnit
    @Common.Label : 'Equipment Capacity Volume'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Volume'
    TranspEquipCapacityVolume : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Equipment Capacity Volume UoM'
    @Common.QuickInfo : 'Transportation Order Item Equipment Capacity Volume UoM'
    TranspEquipCapacityVolumeUnit : String(3) not null;
    @Common.Label : 'Package ID'
    TranspOrdItemPackageID : String(35) not null;
    @Core.Computed : true
    @Common.Label : 'Product GUID'
    @Common.QuickInfo : 'Internal Unique ID of Product'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CRMT_PRODUCT_GUID_DB'
    ProductUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Product'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRODUCTNUMBER'
    ProductID : String(18) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Material Freight Grp'
    @Common.Heading : 'MatFrtGp'
    @Common.QuickInfo : 'Material Freight Group'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=MFRGR'
    MaterialFreightGroup : String(8) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Group'
    @Common.Heading : 'TGroup'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TRAGR'
    TransportationGroup : String(4) not null;
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemTemperatureUnit
    @Common.Label : 'Min. Temperature'
    @Common.Heading : 'Minimum Temperature'
    @Common.QuickInfo : 'Minimum Temperature'
    TranspOrdItmMinTemp : Decimal(7, 2) not null;
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemTemperatureUnit
    @Common.Label : 'Max. Temperature'
    @Common.Heading : 'Maximum Temperature'
    @Common.QuickInfo : 'Maximum Temperature'
    TranspOrdItmMaxTemp : Decimal(7, 2) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Temperature UoM'
    @Common.Heading : 'Unit of Measure of Temperatu'
    @Common.QuickInfo : 'Unit of Measure of Temperature'
    TranspOrdItemTemperatureUnit : String(3) not null;
    @Measures.Unit : TranspOrdItemQuantityUnit
    @Common.Label : 'Quantity'
    @Common.QuickInfo : 'Transportation Order Item Quantity'
    TranspOrdItemQuantity : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Common.Label : 'Quantity UoM'
    @Common.QuickInfo : 'Transportation Order Item Quantity Unit of Measure'
    TranspOrdItemQuantityUnit : String(3) not null;
    @Measures.Unit : TranspOrdItemGrossWeightUnit
    @Common.Label : 'Gross Weight'
    @Common.QuickInfo : 'Transportation Order Item Gross Weight'
    TranspOrdItemGrossWeight : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Common.Label : 'Gross Weight UoM'
    @Common.QuickInfo : 'Transportation Order Item Gross Weight Unit of Measure'
    TranspOrdItemGrossWeightUnit : String(3) not null;
    @Measures.Unit : TranspOrdItemGrossVolumeUnit
    @Common.Label : 'Gross Volume'
    @Common.QuickInfo : 'Transportation Order Item Gross Volume'
    TranspOrdItemGrossVolume : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Common.Label : 'Item Gross Volume Unit'
    @Common.QuickInfo : 'Transportation Order Item Gross Volume Unit'
    TranspOrdItemGrossVolumeUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemNetWeightUnit
    @Common.Label : 'Net Weight'
    @Common.QuickInfo : 'Transportation Order Item Net Weight'
    TranspOrdItemNetWeight : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Net Weight UoM'
    @Common.QuickInfo : 'Transportation Order Item Net Weight Unit of Measure'
    TranspOrdItemNetWeightUnit : String(3) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdDangerousGoodsStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item Dangerous Goods Status'
    @Common.QuickInfo : 'Transportation Order Item Dangerous Goods Status'
    TranspOrdItemDngrsGdsSts : String(1) not null;
    SAP__Messages : many SAP__Message not null;
    _ConsigneeAddrDfltRprstn : Association to one FrtOrdItmMainBPAddrDfltRprstn {  };
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FreightOrderItemBatch : Composition of many FreightOrderItemBatch on _FreightOrderItemBatch._FreightOrderItem = $self;
    @Common.Composition : true
    _FreightOrderItemCommodityCode : Composition of many FreightOrderItemCommodityCode on _FreightOrderItemCommodityCode._FreightOrderItem = $self;
    @Common.Composition : true
    _FreightOrderItemDocRef : Composition of many FreightOrderItemDocRef on _FreightOrderItemDocRef._FreightOrderItem = $self;
    @Common.Composition : true
    _FreightOrderItemSeal : Composition of many FreightOrderItemSeal on _FreightOrderItemSeal._FreightOrderItem = $self;
    @Common.Composition : true
    _FreightOrderItemSerialNumber : Composition of many FreightOrderItemSerialNumber on _FreightOrderItemSerialNumber._FreightOrderItem = $self;
    @Common.Composition : true
    _FrtOrdItmMainBPAddrDfltRprstn : Composition of many FrtOrdItmMainBPAddrDfltRprstn on _FrtOrdItmMainBPAddrDfltRprstn._FreightOrderItem = $self;
    _ShipperAddrDfltRprstn : Association to one FrtOrdItmMainBPAddrDfltRprstn {  };
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item Batch'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightOrderItemBatch {
    @Core.Computed : true
    @Common.Label : 'Item Batch UUID'
    @Common.QuickInfo : 'Transportation Order Item Batch UUID'
    key TranspOrdItemBatchUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Batch'
    @Common.QuickInfo : 'Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CHARG_D'
    Batch : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Product'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=PRODUCTNUMBER'
    ProductID : String(18) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Supplier Batch'
    @Common.QuickInfo : 'Supplier Batch Number'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LICHN'
    BatchBySupplier : String(15) not null;
    @Common.Label : 'Date of Manufacture'
    @Common.Heading : 'Manuf. Dte'
    ManufactureDate : Date;
    @Common.Label : 'SLED/BBD'
    @Common.QuickInfo : 'Shelf Life Expiration or Best-Before Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=VFDAT'
    ShelfLifeExpirationDate : Date;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item Commodity Code'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightOrderItemCommodityCode {
    @Core.Computed : true
    @Common.Label : 'Item Commodity Code UUID'
    @Common.QuickInfo : 'Transportation Order Item Commodity Code UUID'
    key TranspOrdItemCommodityCodeUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Commodity Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FCOMMODITY_CODE'
    TranspOrdItemCommodityCode : String(30) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Numbering Scheme'
    @Common.Heading : 'Numbering Scheme for Commodity Codes for Transportation'
    @Common.QuickInfo : 'Numbering Scheme for Commodity Codes for Transportation'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FSTCTS'
    TrOrdItmCmmdtyCodeNmbrngSchm : String(10) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item Document Reference'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FreightOrderItemDocRef {
    @Core.Computed : true
    @Common.Label : 'Item Document Reference UUID'
    @Common.QuickInfo : 'Transportation Order Item Document Reference UUID'
    key TranspOrdItemDocReferenceUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Business Tr. Doc. ID'
    @Common.Heading : 'Business Transaction Document ID'
    @Common.QuickInfo : 'Bus. Trans. Document ID'
    TranspOrdItemDocReferenceID : String(35) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocTypeCode'
    @Common.IsUpperCase : true
    @Common.Label : 'Document Type'
    @Common.Heading : 'Document Type for Business Transaction'
    @Common.QuickInfo : 'Document Type for Business Transaction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FBTD_TYPE_CODE'
    TranspOrdItemDocReferenceType : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'BTD Item ID'
    TranspOrdItmDocReferenceItemID : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocItmTypeCode'
    @Common.IsUpperCase : true
    @Common.Label : 'BTD Item Type Code'
    @Common.Heading : 'Business Transaction Document Item Type Code'
    @Common.QuickInfo : 'Business Transaction Document Item Type Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FBTD_ITEM_TYPECODE'
    TranspOrdItmDocRefItemType : String(5) not null;
    @Common.Label : 'Business Tr. DocDate'
    @Common.Heading : 'Business Transaction Document Date'
    @Common.QuickInfo : 'Business Transaction Document Date'
    TranspOrdItmDocRefDate : Date;
    @Common.Label : 'Issuing Party'
    @Common.Heading : 'Issuing Party of Bus. Trans. Document'
    @Common.QuickInfo : 'Issuing Party of Business Transaction Document'
    TranspOrdItemDocRefIssuerName : String(40) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item Seal'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FreightOrderItemSeal {
    @Core.Computed : true
    @Common.Label : 'Item Seal UUID'
    @Common.QuickInfo : 'Transportation Order Item Seal UUID'
    key TranspOrdItemSealUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.Label : 'Seal Number'
    TranspOrdItemSealNumber : String(15) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Sealing Date/Time'
    @Common.QuickInfo : 'Transportation Order Item Sealing Date/Time'
    TranspOrdItemSealingDateTime : DateTime;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Item Serial Number'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightOrderItemSerialNumber {
    @Core.Computed : true
    @Common.Label : 'Item Serial Number UUID'
    @Common.QuickInfo : 'Transportation Order Item Serial Number UUID'
    key TranspOrdItemSerialNumberUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Item UUID'
    @Common.QuickInfo : 'Transportation Order Item UUID'
    TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Item Serial Number'
    @Common.QuickInfo : 'Transportation Order Item Serial Number'
    TranspOrdItemSerialNumber : String(30) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stage'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderStop,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_ExectgCarrierAddrDfltRprstn',
    '_FreightOrder',
    '_FreightOrderStop',
    '_FrtOrdStageBPAddrDfltRprstn',
    '_InvcgCarrierAddrDfltRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: TranspOrdStageDistance, AllowedExpressions: 'MultiValue' }
  ]
  entity FreightOrderStage {
    @Core.Computed : true
    @Common.Label : 'Stage UUID'
    @Common.QuickInfo : 'Transportation Order Stage UUID'
    key TransportationOrderStageUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stage'
    @Common.QuickInfo : 'Transportation Order Stage'
    TransportationOrderStage : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderStageType'
    @Common.IsUpperCase : true
    @Common.Label : 'Stage Type'
    @Common.QuickInfo : 'Transportation Order Stage Type'
    TranspOrdStageType : String(3) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderStageCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stage Category'
    @Common.QuickInfo : 'Transportation Order Stage Category'
    TranspOrdStageCategory : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationMode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Mode'
    TransportationMode : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationModeCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Mode Category'
    TransportationModeCategory : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdStgeInvcgCarrLvl'
    @Common.IsUpperCase : true
    @Common.Label : 'Stage Level'
    @Common.Heading : 'Stage Invoicing Carrier Level'
    @Common.QuickInfo : 'Stage Invoicing Carrier Level'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FSTG_PYMT_IND'
    TranspOrdStgeInvcgCarrLvl : String(2) not null;
    @Common.Label : 'Carrier UUID'
    CarrierUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Carrier'
    Carrier : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'StandardCarrierAlphaCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'SCAC'
    @Common.QuickInfo : 'Transportation Order Stage SCAC'
    TranspOrdStageSCACCode : String(4) not null;
    @Core.Computed : true
    @Common.Label : 'Invoicing Carrier UUID'
    @Common.QuickInfo : 'TransportationOrderStageInvoicingCarrier UUID'
    TranspOrdStgeInvcgCarrUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Invoicing Carrier'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FPTY_PYMT_CARRIER'
    TranspOrdStageInvoicingCarrier : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'StandardCarrierAlphaCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Invoicing Carrier SCAC'
    @Common.QuickInfo : 'Transportation Order Stage Invoicing Carrier SCAC'
    TranspOrdStgeInvcgSCACCode : String(4) not null;
    @Measures.Unit : TranspOrdStageDistanceUnit
    @Common.Label : 'Stage Distance'
    @Common.QuickInfo : 'Transportation Order Stage Distance'
    TranspOrdStageDistance : Decimal(28, 6) not null;
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Stage Distance Unit'
    @Common.QuickInfo : 'Transportation Order Stage Distance Unit'
    TranspOrdStageDistanceUnit : String(3) not null;
    @Common.Label : 'Stage Net Duration'
    @Common.QuickInfo : 'Transportation Order Stage Net Duration in hhmmss'
    TranspOrdStageNetDuration : Decimal(precision: 11) not null;
    @Core.Computed : true
    @Common.Label : 'Stage Source Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stage Source Stop UUID'
    TranspOrdStageSrceStopUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Stage Destination Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stage Destination Stop UUID'
    TranspOrdStageDestStopUUID : UUID;
    SAP__Messages : many SAP__Message not null;
    _ExectgCarrierAddrDfltRprstn : Association to one FrtOrdStgeBPAddrDfltRprstn {  };
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderStop : Association to one FreightOrderStop on _FreightOrderStop.TransportationOrderStopUUID = TranspOrdStageSrceStopUUID;
    @Common.Composition : true
    _FrtOrdStageBPAddrDfltRprstn : Composition of many FrtOrdStgeBPAddrDfltRprstn on _FrtOrdStageBPAddrDfltRprstn._FreightOrderStage = $self;
    _InvcgCarrierAddrDfltRprstn : Association to one FrtOrdStgeBPAddrDfltRprstn {  };
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stop'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderStage', '_FrtOrdStopLocAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FreightOrderStop {
    @Core.Computed : true
    @Common.Label : 'Stop UUID'
    @Common.QuickInfo : 'Transportation Order Stop UUID'
    key TransportationOrderStopUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stop'
    @Common.QuickInfo : 'Transportation Order Stop'
    TransportationOrderStop : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderStopCategory'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Category'
    TranspOrdStopCategory : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TransportationOrderStopRole'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Role of the Stop'
    TranspOrdStopRole : String(2) not null;
    @Common.Label : 'Location Additional UUID'
    @Common.QuickInfo : 'Location Additional UUID (RAW 16)'
    LocationAdditionalUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Location'
    LocationId : String(20) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'UN/LOCODE'
    @Common.QuickInfo : 'United Nations Code for Trade and Transport Locations'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FLOC_UNLOCODE'
    LocationUNCode : String(5) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Airport Code'
    LocationIATACode : String(3) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Stop Planned Date/Time'
    @Common.QuickInfo : 'Transportation Order Stop Planned Date/Time'
    TranspOrdStopPlanTranspDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Actual Event Date/Time'
    @Common.QuickInfo : 'Actual Date/Time of Event'
    TranspOrdStopDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Stop Appointment Start Date Time'
    @Common.QuickInfo : 'Transportation Order Stop Appointment Start Date Time'
    TranspOrdStopApptStrtDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Stop Appointment End Date Time'
    @Common.QuickInfo : 'Transportation Order Stop Appointment End Date Time'
    TranspOrdStopApptEndDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Carrier Conf. Start Date Time of Stop'
    @Common.QuickInfo : 'Transportation Order Stop Carrier Conf Start Date Time'
    TranspStopCarrConfStrtDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Carrier Conf. End Date Time of Stop'
    @Common.QuickInfo : 'Transportation Stop Carrier Conf End Date Time'
    TranspStopCarrConfEndDteTme : DateTime;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Position'
    @Common.Heading : 'Stop Position in Transportation Stop Sequence'
    @Common.QuickInfo : 'Stop Position in Transportation Stop Sequence'
    TranspOrdStopSequencePosition : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdStopHndlgExecStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Logistical Execution Status'
    @Common.QuickInfo : 'Transportation Order Stop Handling Execution Status'
    TranspOrdStopHndlgExecStatus : String(2) not null;
    @Core.Computed : true
    @Common.Label : 'Execution Block'
    @Common.QuickInfo : 'Transportation Order Execution Block'
    TranspOrdStopExecIsBlocked : Boolean not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FreightOrderStage : Composition of many FreightOrderStage on _FreightOrderStage._FreightOrderStop = $self;
    @Common.Composition : true
    _FrtOrdStopLocAddrDfltRprstn : Composition of one FrtOrdStopLocAddrDfltRprstn on _FrtOrdStopLocAddrDfltRprstn._FreightOrderStop = $self;
  } actions {
    action SetToReadyForWarehouseProcg();
    action SetToNotReadyForWarehouseProcg();
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order BP Addr Addl Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdBPAddrAddlRprstn {
    @Core.Computed : true
    @Common.Label : 'NodeID'
    key TransportationOrderBusPartUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    key AddressRepresentationCode : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdBPAddrDfltRprstn : Association to one FrtOrdBPAddrDfltRprstn on _FrtOrdBPAddrDfltRprstn.TransportationOrderBusPartUUID = TransportationOrderBusPartUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order BP Addr Dflt Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderBusinessPartner,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightOrder',
    '_FreightOrderBusinessPartner',
    '_FrtOrdBPAddrAddlRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdBPAddrDfltRprstn {
    @Core.Computed : true
    @Common.Label : 'NodeID'
    key TransportationOrderBusPartUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalPhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalMobilePhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Fax Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FXNRLNG'
    InternationalFaxNumber : String(30) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderBusinessPartner : Association to one FreightOrderBusinessPartner on _FreightOrderBusinessPartner.TransportationOrderBusPartUUID = TransportationOrderBusPartUUID;
    @Common.Composition : true
    _FrtOrdBPAddrAddlRprstn : Composition of many FrtOrdBPAddrAddlRprstn on _FrtOrdBPAddrAddlRprstn._FrtOrdBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Calculation Base'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FrtOrdChrgElement,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdChrgElement' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: TranspScaleItemQuantity, AllowedExpressions: 'MultiValue' },
    { Property: TranspScaleItemAmount, AllowedExpressions: 'MultiValue' },
    { Property: TranspDataSourceQuantity, AllowedExpressions: 'MultiValue' },
    { Property: TranspDataSourceAmount, AllowedExpressions: 'MultiValue' }
  ]
  entity FrtOrdChrgCalcBase {
    @Core.Computed : true
    @Common.Label : 'Calculation Base UUID'
    @Common.QuickInfo : 'Transportation Charge Calculation Base UUID'
    key TranspChrgCalcBaseUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Element UUID'
    TranspChargeItemElementUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Base'
    @Common.Heading : 'Calculation Base'
    @Common.QuickInfo : 'Calculation Base'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_CLC_BASE_CD'
    TranspChrgCalculationBase : String(15) not null;
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'UoM'
    @Common.Heading : 'Unit of Measure'
    @Common.QuickInfo : 'Unit of Measure'
    TranspScaleItemQuantityUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspScaleItemQuantityUnit
    @Common.Label : 'Quantity'
    TranspScaleItemQuantity : Decimal(31, 14) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Currency (SAP-Internal)'
    @Common.Heading : 'Curr.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=CURRENCYSAP'
    TranspScaleItemCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspScaleItemCurrency
    @Common.Label : 'Scale Item Amount'
    TranspScaleItemAmount : Decimal(precision: 31) not null;
    @Core.Computed : true
    @Common.Label : 'Transp Charge Scale Quantity (Char)'
    @Common.QuickInfo : 'Transportation Charge Scale Quantity (Character)'
    TranspScaleItemValueChar : String(255) not null;
    @Common.IsUnit : true
    @Common.Label : 'Transportation Charge Data Source UOM'
    TranspDataSourceQtyUnit : String(3) not null;
    @Measures.Unit : TranspDataSourceQtyUnit
    @Common.Label : 'Quantity'
    TranspDataSourceQuantity : Decimal(31, 14) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transp Charge Data Source Currency'
    @Common.QuickInfo : 'Transportation Charge Data Source Currency'
    TranspDataSourceCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspDataSourceCurrency
    @Common.Label : 'Data Source Amount'
    TranspDataSourceAmount : Decimal(precision: 31) not null;
    @Core.Computed : true
    @Common.Label : 'Transp Chrg Data Source Quantity (Char)'
    @Common.QuickInfo : 'Transportation Charge Data Source Quantity (Character)'
    TranspDataSourceValueChar : String(255) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdChrgElement : Association to one FrtOrdChrgElement on _FrtOrdChrgElement.TranspChargeItemElementUUID = TranspChargeItemElementUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Calculation Rule'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FrtOrdChrgElement,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableProperties : [ 'TranspChrgCalculationBase' ]
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdChrgElement' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    {
      Property: TranspRateCalcRuleQuantity,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspChrgDataSourceQuantity,
      AllowedExpressions: 'MultiValue'
    }
  ]
  entity FrtOrdChrgCalcRule {
    @Core.Computed : true
    @Common.Label : 'Calculation Rule UUID'
    @Common.QuickInfo : 'Transportation Charge Calculation Rule UUID'
    key TranspChrgCalcRuleUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Element UUID'
    TranspChargeItemElementUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Base'
    @Common.Heading : 'Calculation Base'
    @Common.QuickInfo : 'Calculation Base'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_CLC_BASE_CD'
    TranspChrgCalculationBase : String(15) not null;
    @Common.IsUnit : true
    @Common.Label : 'UoM'
    @Common.Heading : 'Unit of Measure'
    @Common.QuickInfo : 'Unit of Measure'
    TranspRateCalcRuleQtyUnit : String(3) not null;
    @Measures.Unit : TranspRateCalcRuleQtyUnit
    @Common.Label : 'Quantity'
    TranspRateCalcRuleQuantity : Decimal(31, 14) not null;
    @Measures.Unit : TranspRateCalcRuleQtyUnit
    @Common.Label : 'Quantity'
    TranspChrgDataSourceQuantity : Decimal(31, 14) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdChrgElement : Association to one FrtOrdChrgElement on _FrtOrdChrgElement.TranspChargeItemElementUUID = TranspChargeItemElementUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Element'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderChargeItem,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FrtOrdChrgCalcRule,
      InsertRestrictions: { Insertable: true }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.RequiredProperties : [ 'TranspChargeType' ]
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableProperties : [ 'TranspChargeType' ]
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightOrder',
    '_FreightOrderChargeItem',
    '_FrtOrdChrgCalcBase',
    '_FrtOrdChrgCalcRule',
    '_FrtOrdChrgElmntExchRate'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    {
      Property: TranspChargeCalcAmtInCalcCrcy,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspRateAmountInRateCrcy,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TransportationRateAmountPct,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspChrgAmountInDocCurrency,
      AllowedExpressions: 'MultiValue'
    },
    {
      Property: TranspChrgAmountInLoclCurrency,
      AllowedExpressions: 'MultiValue'
    }
  ]
  entity FrtOrdChrgElement {
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Element UUID'
    key TranspChargeItemElementUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Charge Item UUID'
    @Common.QuickInfo : 'Transportation Charge Item UUID'
    TranspChargeItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Rate UUID Internal'
    @Common.QuickInfo : 'Rate UUID'
    TransportationRateUUID : UUID;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Calc. Sheet Line No.'
    @Common.Heading : 'Calculation Sheet Line Number'
    @Common.QuickInfo : 'Calculation Sheet Line Number'
    TranspCalculationSheetItem : String(6) not null;
    @Core.Immutable : true
    @Common.IsUpperCase : true
    @Common.Label : 'Charge Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_ELMNT_TYPECD'
    TranspChargeType : String(15) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Resol. Base'
    @Common.Heading : 'Calculation Resolution Base'
    @Common.QuickInfo : 'Calculation Resolution Base'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_CLCRES_BASTP'
    TranspCalcResolutionBase : String(20) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Date Ty.'
    @Common.Heading : 'Calculation Date Type'
    @Common.QuickInfo : 'Calculation Date Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTCC_CALC_DATE_TYPE_CHG'
    TranspCalculationDateType : String(10) not null;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Calc. Date Timestamp'
    @Common.Heading : 'Calculation Date Timestamp'
    @Common.QuickInfo : 'Calculation Date Timestamp'
    TranspChargeCalculationDateTme : DateTime;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calculated Amount Currency'
    @Common.QuickInfo : 'Transportation Charge Calculated Amount Currency'
    TranspChargeCalculationCrcy : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspChargeCalculationCrcy
    @Common.Label : 'Transportation Charge Calculated Amount'
    TranspChargeCalcAmtInCalcCrcy : Decimal(precision: 31) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'Rate Amount Currency'
    TransportationRateCurrency : String(3) not null;
    @Measures.ISOCurrency : TransportationRateCurrency
    @Common.Label : 'Rate Amount in Rate Currency'
    TranspRateAmountInRateCrcy : Decimal(precision: 31) not null;
    @Common.IsUnit : true
    @Common.Label : 'UoM'
    @Common.Heading : 'Unit of Measure'
    @Common.QuickInfo : 'Unit of Measure'
    TransportationRatePctUnit : String(3) not null;
    @Measures.Unit : TransportationRatePctUnit
    @Common.Label : 'Percentage Rate Amount'
    TransportationRateAmountPct : Decimal(31, 2) not null;
    @Core.Computed : true
    @Common.Label : 'Man.-Chgd Rate Amt'
    @Common.Heading : 'Manually-Changed Rate Amount'
    @Common.QuickInfo : 'Manually-Changed Rate Amount'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_RDTL_FIX_CD'
    TranspRateAmtIsManuallyChanged : Boolean not null;
    @Core.Computed : true
    @Common.IsDigitSequence : true
    @Common.Label : 'Line Number'
    @Common.Heading : 'Transportation Charge Element Line No.'
    @Common.QuickInfo : 'Transportation Charge Element Line No.'
    TranspChrgLineNumber : String(6) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Transp Charge Elmnt Reference From Item'
    @Common.QuickInfo : 'Transportation Charge Element Reference From Item'
    TranspChrgRefFromLineNumber : String(6) not null;
    @Common.IsDigitSequence : true
    @Common.Label : 'Transp Charge Element Reference To Item'
    @Common.QuickInfo : 'Transportation Charge Element Reference To Item'
    TranspChrgRefToLineNumber : String(6) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Currency'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FDOC_CURRENCY'
    TranspChargeDocumentCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspChargeDocumentCurrency
    @Common.Label : 'Final Amount in Document Currency'
    TranspChrgAmountInDocCurrency : Decimal(precision: 31) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Charge Local Currency'
    @Common.QuickInfo : 'Transportation Charge Local Currency'
    TranspChargeLocalCurrency : String(3) not null;
    @Core.Computed : true
    @Measures.ISOCurrency : TranspChargeLocalCurrency
    @Common.Label : 'Final Amount In Local Currency'
    TranspChrgAmountInLoclCurrency : Decimal(precision: 31) not null;
    @Core.Computed : true
    @Common.Label : 'UUID Internal'
    @Common.QuickInfo : 'Internal Universally Unique Identifier'
    TranspIndexRateTableUUID : UUID;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Rate Table'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTC_RATETABLE_ID'
    TransportationRate : String(20) not null;
    @Core.Computed : true
    @Common.Label : 'Mandatory'
    @Common.QuickInfo : 'Transportation Charge Element is Mandatory'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTRCHARG_MANDATORY'
    TranspChargeIsMandatory : Boolean not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Dim. Wt Prof.'
    @Common.Heading : 'Dimensional Weight Profile'
    @Common.QuickInfo : 'Dimensional Weight Profile'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FDIM_WEIGHT_PROFILE'
    TranspDimnWeightProfile : String(10) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Method Type'
    @Common.Heading : 'Calculation Method Type'
    @Common.QuickInfo : 'Calculation Method Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTCM_CALC_METHOD_CODE'
    TranspCalculationMethodType : String(1) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Calc. Method'
    @Common.Heading : 'Calculation Method'
    @Common.QuickInfo : 'Calculation Method'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FTCM_CALC_METHOD'
    TranspCalculationMethodName : String(20) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Charge Calc. Status'
    @Common.Heading : 'Charge Calculation Status'
    @Common.QuickInfo : 'Charge Calculation Status'
    TranspChargeCalcStatus : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Invoicing Status'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FINVOICING_STATUS_CODE'
    TranspChargePostingStatus : String(2) not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderChargeItem : Association to one FreightOrderChargeItem on _FreightOrderChargeItem.TranspChargeItemUUID = TranspChargeItemUUID;
    @Common.Composition : true
    _FrtOrdChrgCalcBase : Composition of many FrtOrdChrgCalcBase on _FrtOrdChrgCalcBase._FrtOrdChrgElement = $self;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FrtOrdChrgCalcRule : Composition of many FrtOrdChrgCalcRule on _FrtOrdChrgCalcRule._FrtOrdChrgElement = $self;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FrtOrdChrgElmntExchRate : Composition of many FrtOrdChrgElmntExchRate on _FrtOrdChrgElmntExchRate._FrtOrdChrgElement = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Element Exch. Rate'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FrtOrdChrgElement,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdChrgElement' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightOrder/ChangedDateTime' ]
  entity FrtOrdChrgElmntExchRate {
    @Core.Computed : true
    @Common.Label : 'Exchange Rate UUID'
    @Common.QuickInfo : 'Transportation Charge Exchange Rate UUID'
    key TranspChrgExchangeRateUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Element UUID'
    TranspChargeItemElementUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'From-Currency'
    @Common.Heading : 'From'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FCURR_CURR'
    SourceCurrency : String(3) not null;
    @Common.IsCurrency : true
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'To-Currency'
    @Common.Heading : 'To'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TCURR_CURR'
    TargetCurrency : String(3) not null;
    @Common.Label : 'Exchange Rate'
    TranspChrgExchangeRate : Decimal(28, 14) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Exchange Rate Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEXCHANGERATETYPE'
    TranspChrgExchangeRateType : String(4) not null;
    @Common.Label : 'Exch Rate Quote Dte'
    @Common.Heading : 'Exchange Rate Quote Date'
    @Common.QuickInfo : 'Exchange Rate Quote Date'
    ExchangeRateDate : Date;
    @Core.Computed : true
    @Common.Label : 'Man.-Chgd Ex Rt Date'
    @Common.Heading : 'Manually-Changed Exchange Rate Date'
    @Common.QuickInfo : 'Manually-Changed Exchange Rate Date'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEXCHRATE_DATE_FIXATION'
    TranspExchRateDateIsMnllyChgd : Boolean not null;
    @Core.Computed : true
    @Common.Label : 'Exchange Rate Is Manually Changed'
    @Common.QuickInfo : 'Transportation Exchange Rate Is Manually Changed'
    TranspExchRateIsManuallyChgd : Boolean not null;
    SAP__Messages : many SAP__Message not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdChrgElement : Association to one FrtOrdChrgElement on _FrtOrdChrgElement.TranspChargeItemElementUUID = TranspChargeItemElementUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Charge Item Exchange Rate'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderChargeItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderChargeItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdChrgItmExchRate {
    @Core.Computed : true
    @Common.Label : 'Exchange Rate UUID'
    @Common.QuickInfo : 'Transportation Charge Exchange Rate UUID'
    key TranspChrgExchangeRateUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Charge Item UUID'
    @Common.QuickInfo : 'Transportation Charge Item UUID'
    TranspChargeItemUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Charge Host Document UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'From-Currency'
    @Common.Heading : 'From'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=FCURR_CURR'
    SourceCurrency : String(3) not null;
    @Common.IsCurrency : true
    @Common.IsUpperCase : true
    @Common.Label : 'To-Currency'
    @Common.Heading : 'To'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=TCURR_CURR'
    TargetCurrency : String(3) not null;
    @Common.Label : 'Exchange Rate'
    TranspChrgExchangeRate : Decimal(28, 14) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Exchange Rate Type'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FEXCHANGERATETYPE'
    TranspChrgExchangeRateType : String(4) not null;
    @Common.Label : 'Exch Rate Quote Dte'
    @Common.Heading : 'Exchange Rate Quote Date'
    @Common.QuickInfo : 'Exchange Rate Quote Date'
    ExchangeRateDate : Date;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderChargeItem : Association to one FreightOrderChargeItem on _FreightOrderChargeItem.TranspChargeItemUUID = TranspChargeItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Itm Main BP Addr Ad Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdItmMainBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdItmMainBPAddrAddlRprstn {
    @Core.Computed : true
    @Common.Label : 'UUID of TO Item'
    @Common.Heading : 'UUID of Transportation Order Item with Conversion Exit'
    @Common.QuickInfo : 'UUID of Transportation Order Item with Conversion Exit'
    key TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    key AddressRepresentationCode : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdItmMainBPAddrDfltRprstn : Association to one FrtOrdItmMainBPAddrDfltRprstn on _FrtOrdItmMainBPAddrDfltRprstn.TranspOrdBizPartnerFunction = TranspOrdBizPartnerFunction;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Itm Main BP Addr Df Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightOrder',
    '_FreightOrderItem',
    '_FrtOrdItmMainBPAddrAddlRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdItmMainBPAddrDfltRprstn {
    @Core.Computed : true
    @Common.Label : 'UUID of TO Item'
    @Common.Heading : 'UUID of Transportation Order Item with Conversion Exit'
    @Common.QuickInfo : 'UUID of Transportation Order Item with Conversion Exit'
    key TransportationOrderItemUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalPhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalMobilePhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Fax Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FXNRLNG'
    InternationalFaxNumber : String(30) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderItem : Association to one FreightOrderItem on _FreightOrderItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
    @Common.Composition : true
    _FrtOrdItmMainBPAddrAddlRprstn : Composition of many FrtOrdItmMainBPAddrAddlRprstn on _FrtOrdItmMainBPAddrAddlRprstn._FrtOrdItmMainBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Main BP Addr Addl Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdMainBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdMainBPAddrAddlRprstn {
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    key TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    key AddressRepresentationCode : String(1) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdMainBPAddrDfltRprstn : Association to one FrtOrdMainBPAddrDfltRprstn on _FrtOrdMainBPAddrDfltRprstn.TranspOrdBizPartnerFunction = TranspOrdBizPartnerFunction;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Main BP Addr Dflt Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdMainBPAddrAddlRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdMainBPAddrDfltRprstn {
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    key TransportationOrderUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalPhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalMobilePhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Fax Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FXNRLNG'
    InternationalFaxNumber : String(30) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    _FrtOrdMainBPAddrAddlRprstn : Composition of many FrtOrdMainBPAddrAddlRprstn on _FrtOrdMainBPAddrAddlRprstn._FrtOrdMainBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stage BP Addr Addl Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdStgeBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdStgeBPAddrAddlRprstn {
    @Core.Computed : true
    @Common.Label : 'Stage UUID'
    @Common.QuickInfo : 'Transportation Order Stage UUID'
    key TransportationOrderStageUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    key AddressRepresentationCode : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdStgeBPAddrDfltRprstn : Association to one FrtOrdStgeBPAddrDfltRprstn on _FrtOrdStgeBPAddrDfltRprstn.TranspOrdBizPartnerFunction = TranspOrdBizPartnerFunction;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stage BP Addr Dflt Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderStage,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderStage', '_FrtOrdStgeBPAddrAddlRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdStgeBPAddrDfltRprstn {
    @Core.Computed : true
    @Common.Label : 'Stage UUID'
    @Common.QuickInfo : 'Transportation Order Stage UUID'
    key TransportationOrderStageUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Partner Function'
    @Common.Heading : 'Function'
    key TranspOrdBizPartnerFunction : String(2) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    @Common.Label : 'Email Address'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_SMTPADR'
    EmailAddress : String(241) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalPhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Telephone Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_TELNRLG'
    InternationalMobilePhoneNumber : String(30) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Fax Number'
    @Common.QuickInfo : 'Complete Number: Dialing Code+Number+Extension'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_FXNRLNG'
    InternationalFaxNumber : String(30) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderStage : Association to one FreightOrderStage on _FreightOrderStage.TransportationOrderStageUUID = TransportationOrderStageUUID;
    @Common.Composition : true
    _FrtOrdStgeBPAddrAddlRprstn : Composition of many FrtOrdStgeBPAddrAddlRprstn on _FrtOrdStgeBPAddrAddlRprstn._FrtOrdStgeBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stop Loc Addr Addl Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FrtOrdStopLocAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdStopLocAddrAddlRprstn {
    @Core.Computed : true
    @Common.Label : 'NodeID'
    key TransportationOrderStopUUID : UUID not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Address Version'
    @Common.Heading : 'Version'
    @Common.QuickInfo : 'Version ID for International Addresses'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NATION'
    key AddressRepresentationCode : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FrtOrdStopLocAddrDfltRprstn : Association to one FrtOrdStopLocAddrDfltRprstn on _FrtOrdStopLocAddrDfltRprstn.TransportationOrderStopUUID = TransportationOrderStopUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Order Stop Loc Addr Dflt Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightOrder,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightOrderStop,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightOrder', '_FreightOrderStop', '_FrtOrdStopLocAddrAddlRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtOrdStopLocAddrDfltRprstn {
    @Core.Computed : true
    @Common.Label : 'NodeID'
    key TransportationOrderStopUUID : UUID not null;
    @Core.Computed : true
    @Common.Label : 'Transportation Order UUID'
    TransportationOrderUUID : UUID not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Address Number'
    @Common.Heading : 'Addr. No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_ADDRNUM'
    AddressID : String(10) not null;
    @Common.Label : 'Full Name'
    @Common.QuickInfo : 'Full Name of Person'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_NAMTEXT'
    AddresseeFullName : String(80) not null;
    @Common.Label : 'City'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_CITY1'
    CityName : String(40) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Postal Code'
    @Common.Heading : 'Post. Code'
    @Common.QuickInfo : 'City Postal Code'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_PSTCD1'
    PostalCode : String(10) not null;
    @Common.Label : 'Street'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_STREET'
    StreetName : String(60) not null;
    @Common.Label : 'House Number'
    @Common.Heading : 'House No.'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=AD_HSNM1'
    HouseNumber : String(10) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Country/Region Key'
    @Common.Heading : 'C/R'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=LAND1'
    Country : String(3) not null;
    @Common.IsUpperCase : true
    @Common.Label : 'Region'
    @Common.Heading : 'Rg'
    @Common.QuickInfo : 'Region (State, Province, County)'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=REGIO'
    Region : String(3) not null;
    _FreightOrder : Association to one FreightOrder on _FreightOrder.TransportationOrderUUID = TransportationOrderUUID;
    _FreightOrderStop : Association to one FreightOrderStop on _FreightOrderStop.TransportationOrderStopUUID = TransportationOrderStopUUID;
    @Common.Composition : true
    _FrtOrdStopLocAddrAddlRprstn : Composition of many FrtOrdStopLocAddrAddlRprstn on _FrtOrdStopLocAddrAddlRprstn._FrtOrdStopLocAddrDfltRprstn = $self;
  };
};

