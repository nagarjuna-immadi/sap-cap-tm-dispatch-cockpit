using { tm.dispatch as db } from '../db/schema';
using { DispatchService } from './dispatch-service';

/*
 * Value helps and texts shared by the Fiori apps (blueprint §7).
 *
 * Code lists are sap.common.CodeList, which carries @cds.odata.valuelist: CAP already
 * generates a Common.ValueList for every association to one (dispatch status, tender
 * mode, offer status, event type, delay reason, currency), and Currencies.code already
 * has Common.Text. Added here: texts and dropdowns for our code lists, the carrier value
 * help, and value helps where there is no association (virtual fields, action parameters).
 */

// --- code lists: show the name, pick from a dropdown ----------------------------------

annotate db.DispatchStatus with { code @Common.Text: name  @title: 'Dispatch Status'; };
annotate db.TenderModes    with { code @Common.Text: name  @title: 'Tender Mode'; };
annotate db.OfferStatus    with { code @Common.Text: name  @title: 'Offer Status'; };
annotate db.EventTypes     with { code @Common.Text: name  @title: 'Event Type'; };
annotate db.DelayReasons   with { code @Common.Text: name  @title: 'Delay Reason'; };

annotate db.FreightOrderDispatch with {
  dispatchStatus @Common.Text: dispatchStatus.name  @Common.TextArrangement: #TextOnly
                 @Common.ValueListWithFixedValues;
};

annotate db.TenderRounds with {
  mode @Common.Text: mode.name  @Common.TextArrangement: #TextOnly
       @Common.ValueListWithFixedValues;
};

annotate db.CarrierOffers with {
  status    @Common.Text: status.name  @Common.TextArrangement: #TextOnly
            @Common.ValueListWithFixedValues;
  // the name is a snapshot taken at invite time, so it is the text even if the carrier changes
  carrierId @Common.Text: carrierName  @Common.TextArrangement: #TextFirst;
};

annotate db.ExecutionEvents with {
  eventType   @Common.Text: eventType.name    @Common.TextArrangement: #TextOnly
              @Common.ValueListWithFixedValues;
  delayReason @Common.Text: delayReason.name  @Common.TextArrangement: #TextOnly
              @Common.ValueListWithFixedValues;
};

// --- carriers --------------------------------------------------------------------------

annotate db.Carriers with {
  carrierId  @title: 'Carrier'  @Common.Text: name  @Common.TextArrangement: #TextFirst;
  name       @title: 'Carrier Name';
  street     @title: 'Street';
  postalCode @title: 'Postal Code';
  city       @title: 'City';
  country    @title: 'Country';
  email      @title: 'Email';
  active     @title: 'Active';
};

// --- DispatchService: no association to hang a value help on ---------------------------

// Virtual, filled by enrich.js; the filter bar offers the status codes as a dropdown
annotate DispatchService.FreightOrders with {
  dispatchStatus @Common.ValueListWithFixedValues  @Common.ValueList: {
    CollectionPath: 'DispatchStatus',
    Parameters    : [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: dispatchStatus, ValueListProperty: 'code' },
    ],
  };
};

annotate DispatchService.FreightOrders with actions {
  startTender(
    mode @Common.ValueListWithFixedValues  @Common.ValueList: {
      CollectionPath: 'TenderModes',
      Parameters    : [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: mode, ValueListProperty: 'code' },
      ],
    },
    // Carriers is already restricted to active = true in the service
    carriers @Common.ValueList: {
      CollectionPath: 'Carriers',
      Parameters    : [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: carriers, ValueListProperty: 'carrierId' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'city' },
        { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'country' },
      ],
    }
  );
};

annotate DispatchService.Dispatch with actions {
  reportException(
    type @Common.ValueListWithFixedValues  @Common.ValueList: {
      CollectionPath: 'EventTypes',
      Parameters    : [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: type, ValueListProperty: 'code' },
      ],
    },
    reason @Common.ValueListWithFixedValues  @Common.ValueList: {
      CollectionPath: 'DelayReasons',
      Parameters    : [
        { $Type: 'Common.ValueListParameterOut', LocalDataProperty: reason, ValueListProperty: 'code' },
      ],
    }
  );
};
