/* checksum : 477356e022ba0d87874535de8f7eb437 */
@cds.external : true
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
service CE_FREIGHTUNIT_0001 {
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
  @Common.Label : 'Freight Unit'
  @Common.Messages : SAP__Messages
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_ConsigneeAddrDfltRprstn',
    '_FreightUnitBusinessPartner',
    '_FreightUnitDocumentReference',
    '_FreightUnitItem',
    '_FreightUnitStop',
    '_FrtUnitMainBPAddrDfltRprstn',
    '_ShipperAddrDfltRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ 'ChangedDateTime' ]
  entity FreightUnit {
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
    @Common.IsUpperCase : true
    @Common.Label : 'Person Responsible'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FRESP_PERSON'
    TranspOrdResponsiblePerson : String(12) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderLifecycleStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Lifecycle Status'
    @Common.QuickInfo : 'Transportation Order Lifecycle Status'
    TranspOrdLifeCycleStatus : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdDangerousGoodsStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Dangerous Goods Sts'
    @Common.QuickInfo : 'Transportation Order Dangerous Goods Status'
    TranspOrderDngrsGdsSts : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrderPlanningBlock'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Planning Block'
    @Common.QuickInfo : 'Transportation Order Planning Block'
    TranspOrdPlanningBlock : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Execution Block'
    @Common.QuickInfo : 'Transportation Order Execution Block'
    TranspOrdExecutionIsBlocked : Boolean not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdGoodsMovementStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Goods Mvmt. Status'
    @Common.Heading : 'GM Status'
    @Common.QuickInfo : 'Delivery Goods Movement Status'
    TranspOrdGoodsMovementStatus : String(1) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdPlanningStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Planning Status'
    @Common.QuickInfo : 'Transportation Order Planning Status'
    TranspOrdPlanningStatus : String(2) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspOrdWhseProcessingStatus'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Whse Proc. Status'
    @Common.Heading : 'Warehouse Processing Status'
    @Common.QuickInfo : 'Warehouse Processing Status'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FWH_PROCESSING_STATUS'
    TranspOrdWhseProcessingStatus : String(1) not null;
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
    _ConsigneeAddrDfltRprstn : Association to one FrtUnitMainBPAddrDfltRprstn {  };
    @Common.Composition : true
    _FreightUnitBusinessPartner : Composition of many FreightUnitBusinessPartner on _FreightUnitBusinessPartner._FreightUnit = $self;
    @Common.Composition : true
    _FreightUnitDocumentReference : Composition of many FreightUnitDocumentReference on _FreightUnitDocumentReference._FreightUnit = $self;
    @Common.Composition : true
    _FreightUnitItem : Composition of many FreightUnitItem on _FreightUnitItem._FreightUnit = $self;
    @Common.Composition : true
    _FreightUnitStop : Composition of many FreightUnitStop on _FreightUnitStop._FreightUnit = $self;
    @Common.Composition : true
    _FrtUnitMainBPAddrDfltRprstn : Composition of many FrtUnitMainBPAddrDfltRprstn on _FrtUnitMainBPAddrDfltRprstn._FreightUnit = $self;
    _ShipperAddrDfltRprstn : Association to one FrtUnitMainBPAddrDfltRprstn {  };
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Business Partner'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FrtUnitBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  entity FreightUnitBusinessPartner {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    _FrtUnitBPAddrDfltRprstn : Composition of one FrtUnitBPAddrDfltRprstn on _FrtUnitBPAddrDfltRprstn._FreightUnitBusinessPartner = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Document Reference'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  entity FreightUnitDocumentReference {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Item'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightUnit',
    '_FreightUnitItemBatch',
    '_FreightUnitItemCommodityCode',
    '_FreightUnitItemDocRef',
    '_FreightUnitItemSerialNumber'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: TranspOrdItmMinTemp, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItmMaxTemp, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemQuantity, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemGrossWeight, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemGrossVolume, AllowedExpressions: 'MultiValue' },
    { Property: TranspOrdItemNetWeight, AllowedExpressions: 'MultiValue' }
  ]
  entity FreightUnitItem {
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
    @Core.Computed : true
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
    @Core.Computed : true
    @Common.Label : 'Parent Item UUID'
    @Common.QuickInfo : 'Transportation Order Parent Item UUID'
    TranspOrdItemParentItemUUID : UUID;
    @Core.Computed : true
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
    @Common.SAPObjectNodeTypeReference : 'ShippingCondition'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Transportation Service Level (Sales)'
    @Common.QuickInfo : 'Transportation Service Level Code for Sales'
    TranspOrdItemShippingCondition : String(2) not null;
    @Core.Computed : true
    @Common.Label : 'Source Stop UUID'
    SourceStopUUID : UUID;
    @Core.Computed : true
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
    @Common.IsUpperCase : true
    @Common.Label : 'Business Tr. Doc. ID'
    @Common.Heading : 'Business Transaction Document ID'
    @Common.QuickInfo : 'Bus. Trans. Document ID'
    TranspBaseDocument : String(35) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocTypeCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Document Type'
    @Common.Heading : 'Document Type for Business Transaction'
    @Common.QuickInfo : 'Document Type for Business Transaction'
    @Common.DocumentationRef : 'urn:sap-com:documentation:key?=type=DE&id=%2FSCMTMS%2FBTD_TYPE_CODE'
    TranspBaseDocumentType : String(5) not null;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'BTD Item ID'
    TranspBaseDocumentItem : String(10) not null;
    @Common.SAPObjectNodeTypeReference : 'TranspBizTransacDocItmTypeCode'
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Base Doc. Item Type'
    @Common.Heading : 'Base Document Item Type f. Business Transaction'
    @Common.QuickInfo : 'Base Document Item Type Code for Business Transaction'
    TranspBaseDocumentItemType : String(5) not null;
    @Core.Computed : true
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
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemQuantityUnit
    @Common.Label : 'Quantity'
    @Common.QuickInfo : 'Transportation Order Item Quantity'
    TranspOrdItemQuantity : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Quantity UoM'
    @Common.QuickInfo : 'Transportation Order Item Quantity Unit of Measure'
    TranspOrdItemQuantityUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemGrossWeightUnit
    @Common.Label : 'Gross Weight'
    @Common.QuickInfo : 'Transportation Order Item Gross Weight'
    TranspOrdItemGrossWeight : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Gross Weight UoM'
    @Common.QuickInfo : 'Transportation Order Item Gross Weight Unit of Measure'
    TranspOrdItemGrossWeightUnit : String(3) not null;
    @Core.Computed : true
    @Measures.Unit : TranspOrdItemGrossVolumeUnit
    @Common.Label : 'Gross Volume'
    @Common.QuickInfo : 'Transportation Order Item Gross Volume'
    TranspOrdItemGrossVolume : Decimal(31, 14) not null;
    @Common.SAPObjectNodeTypeReference : 'UnitOfMeasure'
    @Common.IsUnit : true
    @Core.Computed : true
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FreightUnitItemBatch : Composition of many FreightUnitItemBatch on _FreightUnitItemBatch._FreightUnitItem = $self;
    @Common.Composition : true
    _FreightUnitItemCommodityCode : Composition of many FreightUnitItemCommodityCode on _FreightUnitItemCommodityCode._FreightUnitItem = $self;
    @Common.Composition : true
    _FreightUnitItemDocRef : Composition of many FreightUnitItemDocRef on _FreightUnitItemDocRef._FreightUnitItem = $self;
    @Common.Composition : true
    _FreightUnitItemSerialNumber : Composition of many FreightUnitItemSerialNumber on _FreightUnitItemSerialNumber._FreightUnitItem = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Item Batch'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightUnitItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightUnitItemBatch {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitItem : Association to one FreightUnitItem on _FreightUnitItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Item Commodity Code'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightUnitItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightUnitItemCommodityCode {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitItem : Association to one FreightUnitItem on _FreightUnitItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Item Document Reference'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightUnitItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  entity FreightUnitItemDocRef {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitItem : Association to one FreightUnitItem on _FreightUnitItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Item Serial Number'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    },
    {
      NavigationProperty: _FreightUnitItem,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitItem' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FreightUnitItemSerialNumber {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitItem : Association to one FreightUnitItem on _FreightUnitItem.TransportationOrderItemUUID = TransportationOrderItemUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Stage'
  @Common.Messages : SAP__Messages
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.UpdateRestrictions.DeltaUpdateSupported : true
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitStop' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Capabilities.DeepUpdateSupport.ContentIDSupported : true
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  @Capabilities.FilterRestrictions.FilterExpressionRestrictions : [
    { Property: TranspOrdStageDistance, AllowedExpressions: 'MultiValue' }
  ]
  entity FreightUnitStage {
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
    @Core.Computed : true
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
    @Core.Computed : true
    @Measures.Unit : TranspOrdStageDistanceUnit
    @Common.Label : 'Stage Distance'
    @Common.QuickInfo : 'Transportation Order Stage Distance'
    TranspOrdStageDistance : Decimal(28, 6) not null;
    @Common.IsUnit : true
    @Core.Computed : true
    @Common.Label : 'Stage Distance Unit'
    @Common.QuickInfo : 'Transportation Order Stage Distance Unit'
    TranspOrdStageDistanceUnit : String(3) not null;
    @Core.Computed : true
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitStop : Association to one FreightUnitStop on _FreightUnitStop.TransportationOrderStopUUID = TranspOrdStageSrceStopUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Stop'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitStage', '_FrtUnitStopLocAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  @Core.OptimisticConcurrency : [ '_FreightUnit/ChangedDateTime' ]
  entity FreightUnitStop {
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
    @Common.Label : 'Acceptable Start Date/Time at Stop'
    TranspOrdStopAccptblStrtDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Requested Start Date/Time at Stop'
    TranspOrdStopReqStartDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Requested End Date/Time at Stop'
    TranspOrdStopReqEndDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Common.Label : 'Acceptable End Date/Time at Stop'
    TranspOrdStopAccptblEndDteTme : DateTime;
    @odata.Precision : 0
    @odata.Type : 'Edm.DateTimeOffset'
    @Core.Computed : true
    @Common.Label : 'Actual Event Date/Time'
    @Common.QuickInfo : 'Actual Date/Time of Event'
    TranspOrdStopDteTme : DateTime;
    @Core.Computed : true
    @Common.IsUpperCase : true
    @Common.Label : 'Stop Position'
    @Common.Heading : 'Stop Position in Transportation Stop Sequence'
    @Common.QuickInfo : 'Stop Position in Transportation Stop Sequence'
    TranspOrdStopSequencePosition : String(1) not null;
    @Core.Computed : true
    @Common.Label : 'Capacity Stop UUID'
    @Common.QuickInfo : 'Transportation Order Capacity Stop UUID'
    TranspOrdCapacityStopUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Stop Capacity Item UUID'
    @Common.QuickInfo : 'Transportation Order Stop Capacity Item UUID'
    TranspOrdStopCapacityItemUUID : UUID;
    @Core.Computed : true
    @Common.Label : 'Execution Block'
    @Common.QuickInfo : 'Transportation Order Execution Block'
    TranspOrdStopExecIsBlocked : Boolean not null;
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    @Validation.MaxItems : 1
    _FreightUnitStage : Composition of many FreightUnitStage on _FreightUnitStage._FreightUnitStop = $self;
    @Common.Composition : true
    _FrtUnitStopLocAddrDfltRprstn : Composition of one FrtUnitStopLocAddrDfltRprstn on _FrtUnitStopLocAddrDfltRprstn._FreightUnitStop = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit BP Addr Addl Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FrtUnitBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitBPAddrAddlRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FrtUnitBPAddrDfltRprstn : Association to one FrtUnitBPAddrDfltRprstn on _FrtUnitBPAddrDfltRprstn.TransportationOrderBusPartUUID = TransportationOrderBusPartUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit BP Addr Dflt Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [
    '_FreightUnit',
    '_FreightUnitBusinessPartner',
    '_FrtUnitBPAddrAddlRprstn'
  ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitBPAddrDfltRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitBusinessPartner : Association to one FreightUnitBusinessPartner on _FreightUnitBusinessPartner.TransportationOrderBusPartUUID = TransportationOrderBusPartUUID;
    @Common.Composition : true
    _FrtUnitBPAddrAddlRprstn : Composition of many FrtUnitBPAddrAddlRprstn on _FrtUnitBPAddrAddlRprstn._FrtUnitBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Main BP Addr Addl Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FrtUnitMainBPAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitMainBPAddrAddlRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FrtUnitMainBPAddrDfltRprstn : Association to one FrtUnitMainBPAddrDfltRprstn on _FrtUnitMainBPAddrDfltRprstn.TranspOrdBizPartnerFunction = TranspOrdBizPartnerFunction;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Main BP Addr Dflt Rprstn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FrtUnitMainBPAddrAddlRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitMainBPAddrDfltRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    @Common.Composition : true
    _FrtUnitMainBPAddrAddlRprstn : Composition of many FrtUnitMainBPAddrAddlRprstn on _FrtUnitMainBPAddrAddlRprstn._FrtUnitMainBPAddrDfltRprstn = $self;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Stop Loc Addr Addl Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FrtUnitStopLocAddrDfltRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitStopLocAddrAddlRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FrtUnitStopLocAddrDfltRprstn : Association to one FrtUnitStopLocAddrDfltRprstn on _FrtUnitStopLocAddrDfltRprstn.TransportationOrderStopUUID = TransportationOrderStopUUID;
  };

  @cds.external : true
  @cds.persistence.skip : true
  @Common.Label : 'Freight Unit Stop Loc Addr Dflt Rpn'
  @Capabilities.NavigationRestrictions.RestrictedProperties : [
    {
      NavigationProperty: _FreightUnit,
      DeepUpdateSupport: { Supported: false }
    }
  ]
  @Capabilities.SearchRestrictions.Searchable : false
  @Capabilities.InsertRestrictions.Insertable : false
  @Capabilities.DeleteRestrictions.Deletable : false
  @Capabilities.UpdateRestrictions.Updatable : false
  @Capabilities.UpdateRestrictions.NonUpdatableNavigationProperties : [ '_FreightUnit', '_FreightUnitStop', '_FrtUnitStopLocAddrAddlRprstn' ]
  @Capabilities.UpdateRestrictions.QueryOptions.SelectSupported : true
  entity FrtUnitStopLocAddrDfltRprstn {
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
    _FreightUnit : Association to one FreightUnit on _FreightUnit.TransportationOrderUUID = TransportationOrderUUID;
    _FreightUnitStop : Association to one FreightUnitStop on _FreightUnitStop.TransportationOrderStopUUID = TransportationOrderStopUUID;
    @Common.Composition : true
    _FrtUnitStopLocAddrAddlRprstn : Composition of many FrtUnitStopLocAddrAddlRprstn on _FrtUnitStopLocAddrAddlRprstn._FrtUnitStopLocAddrDfltRprstn = $self;
  };
};

