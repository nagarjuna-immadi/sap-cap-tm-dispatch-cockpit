// Carrier desk's agent service (blueprint §13, development plan 6.3).
//
// Served as an MCP server (/mcp/tender-agent) and as an A2A agent (/a2a/tender-agent),
// never as OData. As narrow as TenderService: open invitations with a small, fixed freight
// order context, and the carrier's own answer. No award fields (awarded carrier, price,
// user, time), no other carrier's offer, no entity for the query tool. Everything
// delegates to TenderService, so the rules stay in award-rules.js.
//
// The notes in dispatch-agent-service.cds apply here too: @protocol lists both protocols,
// @path has no leading slash, @agent.connect 'none' keeps the dispatch agent's tools out,
// the persona is found because AGENTS.md is next to this file, and doc comments (/** … */)
// are what the LLM reads, while line comments like this one are for developers.

/**
 * Carrier desk: enter the quotes that carriers send by mail or phone for the tender
 * invitations they received, or decline an invitation for them. Each invitation asks one
 * carrier to quote a price and a transit time for one freight order until a deadline.
 * Freight orders come from SAP Transportation Management and are identified by their
 * freight order ID; the invitations and quotes are kept in this app.
 */
@path: 'tender-agent'
@requires: 'CarrierDesk'
@protocol: ['mcp', 'agent']
@agent.connect: 'none'
@mcp.instructions: 'Carrier desk for freight tenders: enter or decline quotes for the invitations carriers received. Use openInvitations to find the open invitations (optionally for one carrier ID) and invitationDetails for one invitation; identify an invitation by its offer ID and name its freight order ID and carrier. Read deadlines and statuses with the tools and never guess them. All timestamps are in UTC. submitQuote and decline change data: before calling one, state the carrier, the freight order ID, the price with its currency and the transit time, and call it only when the user gave you these values. Warn when less than 24 hours are left. When an action is rejected, report the message as it is, because it names the rule that was not met.'
service TenderAgentService {

  // --- invitations (functions) ----------------------------------------------------------
  // Read through TenderService.OpenInvitations, which adds lane and dates from TM (one call
  // per page) and the countdown. No parameter reaches TM: carrierId and offerId filter the
  // local offers only (tender-agent-service.js).

  type Invitation {
    offerId             : UUID;
    freightOrderId      : String(20);
    carrierId           : String(10);
    carrierName         : String(120);
    roundNumber         : Integer;
    mode                : String(10);
    deadline            : Timestamp;
    timeLeft            : String(20);
    lessThan24hLeft     : Boolean;
    sourceLocation      : String(20);
    destinationLocation : String(20);
    pickupDateTime      : Timestamp;
    deliveryDateTime    : Timestamp;
  }

  type InvitationList {
    total       : Integer;
    invitations : many Invitation;
  }

  type InvitationDetails : Invitation {
    status       : String(10);
    canRespond   : Boolean;
    price        : Decimal(15, 2);
    currency     : String(3);
    transitHours : Integer;
    comment      : String(255);
    respondedAt  : Timestamp;
  }

  /**
   * Lists the open tender invitations: offers still waiting for a quote whose round is
   * open and whose deadline has not passed, soonest deadline first. Each row has the offer
   * ID, the carrier, the freight order with its lane (source and destination location)
   * and pickup and delivery dates, the tender mode and the quote deadline with the time
   * left. lessThan24hLeft is true when the deadline is less than 24 hours away.
   */
  function openInvitations(
    /** Optional carrier ID (business partner number), e.g. 10300001, to list only that carrier's invitations. Omit it to list all; each row names its carrier. */
    carrierId : String(10)
  ) returns InvitationList;

  /**
   * One invitation with its freight order context, also once it has been answered: status
   * INVITED (waiting for a quote), QUOTED, DECLINED, EXPIRED (deadline passed or round
   * closed without an answer), WON or LOST (after the award). canRespond is true while a
   * quote is still possible; timeLeft and lessThan24hLeft are the time left to quote, so
   * they are empty and false once it is not. price, currency, transitHours, comment and
   * respondedAt are this carrier's own answer; they are empty until it answered.
   */
  function invitationDetails(
    /** Offer ID of the invitation, as offerId from openInvitations. */
    offerId : UUID @mandatory
  ) returns InvitationDetails;

  // --- changes (actions) ----------------------------------------------------------------
  // Each delegates to the TenderService action on OpenInvitations, which checks
  // award-rules.js and changes only the quote fields and the status of the offer.
  // @agent.hitl pauses the agent's task until the user approves (not for external MCP
  // clients such as Claude Code). Both return the invitation as it is afterwards.

  /**
   * Submits the carrier's quote for an open invitation: price, currency and transit time.
   * Possible only while the invitation is waiting for a quote, its round is open and the
   * deadline has not passed; a quote cannot be changed afterwards. Changes data: call it
   * only with the values the user gave you.
   */
  @agent.hitl
  action submitQuote(
    /** Offer ID of the invitation, as offerId from openInvitations. */
    offerId      : UUID           @mandatory,
    /** Quoted price for the whole freight order; greater than 0. */
    price        : Decimal(15, 2) @mandatory,
    /** Three-letter currency code of the price, e.g. EUR. */
    currency     : String(3)      @mandatory,
    /** Quoted transit time in hours, from pickup to delivery; greater than 0. */
    transitHours : Integer        @mandatory,
    /** Optional comment of the carrier on the quote. */
    comment      : String(255)
  ) returns InvitationDetails;

  /**
   * Declines an invitation for the carrier: the carrier will not quote. Possible while
   * the invitation is waiting for a quote and its round is open. Changes data and cannot
   * be undone: call it only when the user asked to decline.
   */
  @agent.hitl
  action decline(
    /** Offer ID of the invitation, as offerId from openInvitations. */
    offerId : UUID @mandatory,
    /** Optional reason the carrier gave. */
    comment : String(255)
  ) returns InvitationDetails;
}
