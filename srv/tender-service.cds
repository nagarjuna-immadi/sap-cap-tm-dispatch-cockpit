using { tm.dispatch as db } from '../db/schema';

/**
 * Carrier desk's service (blueprint §5). Deliberately narrow: the one place a
 * non-dispatcher writes, and only the quote fields of an open invitation.
 *
 * Pulled forward from phase 3 (step 1, service core only) so that quotes can be entered
 * through test/http/tender-flow.http during phase 2. Still to come in phase 3: @restrict
 * rules, the freight order context from TM (lane, dates) and the Tender Desk app.
 */
@path: '/odata/v4/tender'
@requires: 'CarrierDesk'
service TenderService {

  /** INVITED offers whose round is open and whose deadline has not passed. No award fields. */
  @readonly
  entity OpenInvitations as projection on db.CarrierOffers {
    key ID,
        parent.parent.freightOrderId as freightOrderId,
        parent.roundNumber           as roundNumber,
        parent.mode.code             as tenderMode,
        parent.deadline              as deadline,
        carrierId,
        carrierName,
        status.code                  as status,
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
