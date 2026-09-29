using { tm.dispatch as db } from '../db/schema';

/**
 * Carrier desk's service (blueprint §5, development plan phase 3). Deliberately narrow:
 * the one place a non-dispatcher writes, and only the quote fields of an open invitation.
 * It exposes no award fields (awarded carrier, price, user, time) and no other entity.
 */
@path: '/odata/v4/tender'
@requires: 'CarrierDesk'
service TenderService {

  /**
   * INVITED offers whose round is open and whose deadline has not passed. The freight
   * order context (lane, dates) is read from TM per page; deadlineCriticality and timeLeft
   * are evaluated on read (tender-service.js). A read by key also returns an invitation
   * that has been answered meanwhile, so the object page can show the outcome.
   */
  @readonly
  @restrict: [{ grant: ['READ', 'submitQuote', 'decline'], to: 'CarrierDesk' }]
  @Capabilities.SearchRestrictions.Searchable: false
  @Capabilities.SortRestrictions.NonSortableProperties: [
    sourceLocation, destinationLocation, pickupDateTime, deliveryDateTime, deadlineCriticality, timeLeft
  ]
  @Capabilities.FilterRestrictions.NonFilterableProperties: [
    sourceLocation, destinationLocation, pickupDateTime, deliveryDateTime, deadlineCriticality, timeLeft
  ]
  entity OpenInvitations as projection on db.CarrierOffers {
    key ID,
        parent.parent.freightOrderId as freightOrderId,
        parent.roundNumber           as roundNumber,
        parent.mode.code             as tenderMode,
        parent.mode.name             as tenderModeName,
        parent.deadline              as deadline,
        carrierId,
        carrierName,
        status.code                  as status,
        status.name                  as statusName,
        status.criticality           as statusCriticality,
        // enables Submit Quote / Decline; a Boolean path, because the table toolbar
        // cannot evaluate an expression in Core.OperationAvailable
        case when status.code = 'INVITED' then true else false end as canRespond : Boolean,
        // freight order context from TM (first and last stop)
        virtual sourceLocation      : String(20),
        virtual destinationLocation : String(20),
        virtual pickupDateTime      : Timestamp,
        virtual deliveryDateTime    : Timestamp,
        // countdown: 1 red (expired), 2 yellow (< 24 h), 3 green
        virtual deadlineCriticality : Integer,
        virtual timeLeft            : String(20),
  } where status.code = 'INVITED' and parent.closed = false and parent.deadline > $now
  actions {
    action submitQuote(
      price       : Decimal(15, 2) @mandatory,
      currency    : String(3)      @mandatory,
      transitHours: Integer        @mandatory,
      comment     : String(255)
    );
    action decline(comment : String(255));
  };
}
