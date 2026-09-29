using TenderService as service from '../../srv/tender-service';

/*
 * Tender Desk (blueprint §7 App 2, development plan phase 3).
 *
 * Pages: OpenInvitations list (sorted by deadline, countdown) → OpenInvitations object
 *        page (freight order context from TM, Submit Quote / Decline).
 * deadlineCriticality and timeLeft are evaluated on the server on every read
 * (tender-service.js): 1 red once expired, 2 yellow under 24 h, 3 green otherwise.
 * No award fields exist in TenderService, so none can show up here.
 */

annotate service.OpenInvitations with {
  ID                  @UI.Hidden;
  freightOrderId      @title: 'Freight Order';
  sourceLocation      @title: 'Source';
  destinationLocation @title: 'Destination';
  pickupDateTime      @title: 'Pick-Up';
  deliveryDateTime    @title: 'Delivery';
  carrierId           @title: 'Carrier'  @Common.Text: carrierName  @Common.TextArrangement: #TextFirst;
  carrierName         @title: 'Carrier Name';
  roundNumber         @title: 'Round';
  tenderMode          @title: 'Tender Mode'  @Common.Text: tenderModeName  @Common.TextArrangement: #TextOnly;
  tenderModeName      @UI.Hidden;
  deadline            @title: 'Quote Deadline';
  timeLeft            @title: 'Time Left';
  deadlineCriticality @UI.Hidden;
  status              @title: 'Status'  @Common.Text: statusName  @Common.TextArrangement: #TextOnly;
  statusName          @UI.Hidden;
  statusCriticality   @UI.Hidden;
  canRespond          @UI.Hidden;
};

annotate service.OpenInvitations with @(
  UI.SelectionFields: [
    freightOrderId,
    carrierId,
    deadline,
  ],

  UI.LineItem: [
    { $Type: 'UI.DataFieldForAction', Action: 'TenderService.submitQuote', Label: 'Submit Quote' },
    { $Type: 'UI.DataFieldForAction', Action: 'TenderService.decline', Label: 'Decline' },
    { Value: freightOrderId },
    { Value: sourceLocation },
    { Value: destinationLocation },
    { Value: pickupDateTime },
    { Value: deliveryDateTime },
    { Value: carrierId },
    { Value: tenderMode },
    { Value: deadline, Criticality: deadlineCriticality },
    { Value: timeLeft, Criticality: deadlineCriticality },
  ],

  // Most urgent first
  UI.PresentationVariant: {
    SortOrder     : [{ Property: deadline, Descending: false }],
    Visualizations: ['@UI.LineItem'],
  },

  UI.HeaderInfo: {
    TypeName      : 'Invitation',
    TypeNamePlural: 'Open Invitations',
    Title         : { Value: freightOrderId },
    Description   : { Value: carrierName },
  },

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'TenderService.submitQuote', Label: 'Submit Quote' },
    { $Type: 'UI.DataFieldForAction', Action: 'TenderService.decline', Label: 'Decline' },
  ],

  UI.HeaderFacets: [
    { $Type: 'UI.ReferenceFacet', ID: 'Deadline', Target: '@UI.DataPoint#Deadline' },
    { $Type: 'UI.ReferenceFacet', ID: 'TimeLeft', Target: '@UI.DataPoint#TimeLeft' },
    { $Type: 'UI.ReferenceFacet', ID: 'Status', Target: '@UI.DataPoint#Status' },
  ],

  UI.DataPoint #Deadline: {
    Value      : deadline,
    Title      : 'Quote Deadline',
    Criticality: deadlineCriticality,
  },

  UI.DataPoint #TimeLeft: {
    Value      : timeLeft,
    Title      : 'Time Left',
    Criticality: deadlineCriticality,
  },

  UI.DataPoint #Status: {
    Value      : status,
    Title      : 'Status',
    Criticality: statusCriticality,
  },

  UI.FieldGroup #FreightOrder: { Data: [
    { Value: freightOrderId },
    { Value: sourceLocation },
    { Value: destinationLocation },
    { Value: pickupDateTime },
    { Value: deliveryDateTime },
  ] },

  UI.FieldGroup #Tender: { Data: [
    { Value: carrierId },
    { Value: roundNumber },
    { Value: tenderMode },
    { Value: deadline, Criticality: deadlineCriticality },
    { Value: status, Criticality: statusCriticality },
  ] },

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'FreightOrder', Label: 'Freight Order', Target: '@UI.FieldGroup#FreightOrder' },
    { $Type: 'UI.ReferenceFacet', ID: 'Tender', Label: 'Tender', Target: '@UI.FieldGroup#Tender' },
  ],
);

// Only while the invitation is open; award-rules.js checks again on the server.
// The side effect re-reads every binding on the OpenInvitations entity set: the list
// drops the answered row, and the object page (read by key, which still returns an
// answered invitation) shows the new status, so the buttons are disabled.
annotate service.OpenInvitations with actions {
  submitQuote @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/canRespond' } },
    Common.SideEffects     : { TargetEntities: ['/TenderService.EntityContainer/OpenInvitations'] }
  )(
    price        @title: 'Price',
    currency     @title: 'Currency'  @UI.ParameterDefaultValue: 'EUR',
    transitHours @title: 'Transit (Hours)',
    comment      @title: 'Comment'  @UI.MultiLineText
  );
  decline @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/canRespond' } },
    Common.SideEffects     : { TargetEntities: ['/TenderService.EntityContainer/OpenInvitations'] }
  )(
    comment @title: 'Reason'  @UI.MultiLineText
  );
};
