using DispatchService as service from '../../srv/dispatch-service';
annotate service.FreightOrders with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : TransportationOrder,
            },
            {
                $Type : 'UI.DataField',
                Value : TransportationOrderType,
            },
            {
                $Type : 'UI.DataField',
                Value : TransportationMode,
            },
            {
                $Type : 'UI.DataField',
                Value : Carrier,
            },
            {
                $Type : 'UI.DataField',
                Value : Shipper,
            },
            {
                $Type : 'UI.DataField',
                Value : Consignee,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspPurgOrg,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspPurgGroup,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspOrdResponsiblePerson,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspOrdLifeCycleStatus,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspOrdExecutionIsBlocked,
            },
            {
                $Type : 'UI.DataField',
                Value : TranspOrdOrderDateTime,
            },
            {
                $Type : 'UI.DataField',
                Label : 'sourceLocation',
                Value : sourceLocation,
            },
            {
                $Type : 'UI.DataField',
                Label : 'destinationLocation',
                Value : destinationLocation,
            },
            {
                $Type : 'UI.DataField',
                Label : 'pickupDateTime',
                Value : pickupDateTime,
            },
            {
                $Type : 'UI.DataField',
                Label : 'deliveryDateTime',
                Value : deliveryDateTime,
            },
            {
                $Type : 'UI.DataField',
                Label : 'dispatchStatus',
                Value : dispatchStatus,
            },
            {
                $Type : 'UI.DataField',
                Label : 'dispatchStatusCriticality',
                Value : dispatchStatusCriticality,
            },
            {
                $Type : 'UI.DataField',
                Label : 'bestQuote',
                Value : bestQuote,
            },
            {
                $Type : 'UI.DataField',
                Label : 'bestQuoteCurrency',
                Value : bestQuoteCurrency,
            },
            {
                $Type : 'UI.DataField',
                Label : 'quoteCount',
                Value : quoteCount,
            },
            {
                $Type : 'UI.DataField',
                Label : 'quoteDeadline',
                Value : quoteDeadline,
            },
            {
                $Type : 'UI.DataField',
                Label : 'deadlineExpired',
                Value : deadlineExpired,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : TransportationOrder,
        },
        {
            $Type : 'UI.DataField',
            Value : TransportationOrderType,
        },
        {
            $Type : 'UI.DataField',
            Value : TransportationMode,
        },
        {
            $Type : 'UI.DataField',
            Value : Carrier,
        },
        {
            $Type : 'UI.DataField',
            Value : Shipper,
        },
    ],
);

