// Dispatcher's agent service (blueprint §13, development plan 6.2).
//
// Served as an MCP server (/mcp/dispatch-agent) and as an A2A agent (/a2a/dispatch-agent),
// never as OData. Deliberately narrow: local tender data plus a small, fixed freight
// order context, and no generic TM entity (SAP API Policy §2.2.2). Everything delegates
// to DispatchService, so the rules stay in award-rules.js and are not implemented twice.
//
// - @protocol lists both protocols: once it is set, CAP ignores the @mcp / @agent
//   shorthands. @path has no leading slash, so each protocol prefixes its own root.
// - @agent.connect 'none': the agent uses this service's tools only. The plugin default
//   ('auto') would add every other MCP or agent service, such as the tender agent.
// - The persona (AGENTS.md and skills/) is in this folder. The plugin finds it because
//   AGENTS.md is next to this file, so no @agent.directory is needed. If the two are
//   separated, the plugin builds the agent without the persona and reports no error.
// - Doc comments (/** … */) are what the LLM reads: the one on the service goes into the
//   agent's system prompt, the ones on elements, actions and parameters become the tool
//   descriptions. So every element and action gets one; notes for developers go in
//   line comments like this one.
// - The entities are what the query tool reads: projections on the local DB only, with
//   explicit columns. Code list associations are flattened to their codes (the code
//   lists are not exposed, so the doc comments name the values), and freightOrderId is
//   on every entity, so a question about one freight order needs no join.

using { tm.dispatch as db } from '../../../db/schema';

/**
 * Freight tendering for dispatchers: find the freight orders that still need a carrier,
 * invite carriers to quote on them in tender rounds, compare the carrier offers, award
 * one, and record execution exceptions such as delays. Freight orders come from SAP
 * Transportation Management and are read-only; they are identified by their freight
 * order ID. Tender rounds, offers, awards and exceptions are kept in this app.
 */
@path: 'dispatch-agent'
@requires: 'Dispatcher'
@protocol: ['mcp', 'agent']
@agent.connect: 'none'
@mcp.instructions: 'Freight tendering for a dispatcher. Use the describe tool first to see the entities, functions and actions with their parameters, then the query tool to read data and the function and action tools for everything else. Always identify a freight order by its freight order ID. Read prices, deadlines and statuses with the tools and never guess them. All timestamps are in UTC. Actions change data: before calling one, state the freight order ID and the parameters you will use, and call it only when the user asked for that change. When an action is rejected, report the message as it is, because it names the rule that was not met.'
service DispatchAgentService {

  // --- local, read-only (query tool) ----------------------------------------------------

  /**
   * The tender state of a freight order: its dispatch status, the deadline of the current
   * tender round and, once awarded, the winning carrier and price. There is one per
   * freight order, created when the order is first opened, so a freight order without a
   * row here has no tender yet and counts as NEW.
   */
  @readonly
  entity Dispatches as projection on db.FreightOrderDispatch {
        /** Technical ID of the dispatch. */
    key ID,
        /** Freight order ID from Transportation Management, e.g. 6100000002. */
        freightOrderId,
        /** NEW (no tender yet), TENDERING (a round is open), AWARDED (an offer was awarded), FAILED (tender cancelled or no acceptable offer) or CLOSED. */
        dispatchStatus.code as status,
        /** Carrier ID of the awarded carrier; empty until an offer is awarded. */
        awardedCarrier,
        /** Price of the awarded offer. */
        awardedPrice,
        /** Currency code of awardedPrice, e.g. EUR. */
        currency.code       as currency,
        /** When the offer was awarded (UTC). */
        awardedAt,
        /** User who awarded the offer. */
        awardedBy,
        /** Quote deadline of the current tender round (UTC). */
        quoteDeadline,
        /** Tender rounds of this freight order. */
        rounds,
        /** Execution events (pickup, delivery, delay, damage) reported for this freight order. */
        exceptions,
        /** When the freight order was first opened in this app (UTC). */
        createdAt,
        /** When the dispatch was last changed (UTC). */
        modifiedAt,
  };

  /**
   * Tender rounds: each round invites a set of carriers to quote on one freight order
   * until a deadline. A freight order has at most one open round; a new round gets the
   * next round number.
   */
  @readonly
  entity TenderRounds as projection on db.TenderRounds {
        /** Technical ID of the tender round. */
    key ID,
        /** Freight order ID the round belongs to. */
        parent.freightOrderId as freightOrderId,
        /** Number of the round within its freight order, starting at 1. */
        roundNumber,
        /** BROADCAST (all invited carriers quote until the deadline; award only after it has passed), PEER (carriers are invited one at a time; award possible before the deadline) or SPOT (ad-hoc spot quote). */
        mode.code             as mode,
        /** Quote deadline of the round (UTC). */
        deadline,
        /** True once the round is closed: by an award, by closing it or by cancelling the tender. */
        closed,
        // same rule as enrich.js (open and isExpired), evaluated on read
        /** True while the round is still open although its deadline has passed. */
        case when closed = false and deadline <= $now then true else false end as deadlineExpired : Boolean,
        /** The dispatch of the freight order. */
        parent                as dispatch,
        /** Carrier offers of this round, one per invited carrier. */
        offers,
        /** When the round was started (UTC). */
        createdAt             as startedAt,
        /** User who started the round. */
        createdBy             as startedBy,
  };

  /**
   * Carrier offers: one per carrier invited to a tender round, with the quoted price and
   * transit time once the carrier has answered.
   */
  @readonly
  entity CarrierOffers as projection on db.CarrierOffers {
        /** Technical ID of the offer; the award action takes this ID. */
    key ID,
        /** Freight order ID the offer is for. */
        parent.parent.freightOrderId as freightOrderId,
        /** Number of the tender round the offer belongs to. */
        parent.roundNumber           as roundNumber,
        /** Carrier ID (business partner number), e.g. 10300001. */
        carrierId,
        /** Name of the carrier, as it was when the carrier was invited. */
        carrierName,
        // same rule as effectiveOfferStatus in award-rules.js, evaluated on read
        /** INVITED (waiting for a quote), QUOTED (price and transit time submitted), DECLINED, EXPIRED (deadline passed without a quote), WON (awarded) or LOST (another offer was awarded). */
        case when status.code = 'INVITED' and parent.deadline <= $now then 'EXPIRED' else status.code end as status : String(10),
        /** Quoted price; empty until the carrier has quoted. */
        price,
        /** Currency code of the price, e.g. EUR. */
        currency.code                as currency,
        /** Quoted transit time in hours. */
        transitHours,
        /** When the carrier quoted or declined (UTC). */
        respondedAt,
        /** Comment of the carrier on the quote or the decline. */
        comment,
        /** The tender round of the offer. */
        parent                       as round,
        /** When the carrier was invited (UTC). */
        createdAt                    as invitedAt,
  };

  /**
   * Carriers that can be invited to a tender round. Only active carriers are listed.
   */
  @readonly
  entity Carriers as projection on db.Carriers {
        /** Carrier ID (business partner number), e.g. 10300001; used to invite the carrier to a tender. */
    key carrierId,
        /** Name of the carrier. */
        name,
        /** City of the carrier's address. */
        city,
        /** Country code of the carrier's address. */
        country,
        /** E-mail address of the carrier desk. */
        email,
  } where active = true;

  /**
   * Execution events reported for a freight order after the award: pickup, delivery,
   * delays and damages.
   */
  @readonly
  entity ExecutionEvents as projection on db.ExecutionEvents {
        /** Technical ID of the event. */
    key ID,
        /** Freight order ID the event was reported for. */
        parent.freightOrderId as freightOrderId,
        /** PICKED_UP, DELIVERED, DELAY or DAMAGE. */
        eventType.code        as eventType,
        /** When the event happened (UTC). */
        eventTime,
        /** Cause of a delay: TRAFFIC, WEATHER, CARRIER, SHIPPER or CUSTOMS; empty for other event types. */
        delayReason.code      as delayReason,
        /** Length of the delay in minutes. */
        delayMins,
        /** Free-text comment on the event. */
        comment,
        /** The dispatch of the freight order. */
        parent                as dispatch,
        /** When the event was reported (UTC). */
        createdAt             as reportedAt,
        /** User who reported the event. */
        createdBy             as reportedBy,
  };

  // --- freight order context (functions) ------------------------------------------------
  // The only place TM data comes in: a small, fixed set of fields (ID, lane, dates), read
  // through DispatchService. No parameter reaches the TM $filter: status is resolved
  // locally and lane is matched on the rows TM returned (dispatch-agent-service.js).

  type FreightOrderRow {
    freightOrderId      : String(20);
    sourceLocation      : String(20);
    destinationLocation : String(20);
    pickupDateTime      : Timestamp;
    deliveryDateTime    : Timestamp;
    dispatchStatus      : String(10);
    bestQuote           : Decimal(15, 2);
    bestQuoteCurrency   : String(3);
    quoteCount          : Integer;
    quoteDeadline       : Timestamp;
    deadlineExpired     : Boolean;
  }

  type FreightOrderList {
    total         : Integer;
    freightOrders : many FreightOrderRow;
  }

  type OfferRow {
    offerId      : UUID;
    carrierId    : String(10);
    carrierName  : String(120);
    status       : String(10);
    price        : Decimal(15, 2);
    currency     : String(3);
    transitHours : Integer;
    respondedAt  : Timestamp;
    comment      : String(255);
  }

  type RoundRow {
    roundNumber     : Integer;
    mode            : String(10);
    deadline        : Timestamp;
    closed          : Boolean;
    deadlineExpired : Boolean;
    offers          : many OfferRow;
  }

  type FreightOrderSummary : FreightOrderRow {
    freightUnitCount : Integer;
    awardedCarrier   : String(10);
    awardedPrice     : Decimal(15, 2);
    awardedCurrency  : String(3);
    awardedAt        : Timestamp;
    awardedBy        : String(120);
    rounds           : many RoundRow;
  }

  type RankedOffer : OfferRow {
    rank     : Integer;
    canAward : Boolean;
    reason   : String;
  }

  type OfferComparison {
    freightOrderId  : String(20);
    dispatchStatus  : String(10);
    roundNumber     : Integer;
    mode            : String(10);
    deadline        : Timestamp;
    closed          : Boolean;
    deadlineExpired : Boolean;
    note            : String;
    offers          : many RankedOffer;
  }

  /**
   * Lists the freight orders that still need a carrier, with lane, pickup and delivery
   * dates and their tender state: dispatch status, best quote and number of quotes in the
   * current round, quote deadline, and deadlineExpired (the round is still open although
   * its deadline has passed). total is the number of matching freight orders, which can
   * be more than the rows returned.
   */
  function openFreightOrders(
    /** Optional lane filter, matched on the location IDs, ignoring case. 'MUC -> VIE' matches source and destination, 'MUC ->' the source only, '-> VIE' the destination only, and a single term such as 'MUC' either end. */
    lane   : String,
    /** Optional dispatch status: NEW (no tender yet), TENDERING, AWARDED, FAILED or CLOSED. */
    status : String(10),
    /** Maximum number of rows, 1 to 50. Default 20. */
    top    : Integer
  ) returns FreightOrderList;

  /**
   * Everything about one freight order: lane, pickup and delivery dates, number of
   * freight units, dispatch status, best quote, the award if there is one, and all
   * tender rounds with their carrier offers.
   */
  function freightOrderSummary(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20) @mandatory
  ) returns FreightOrderSummary;

  /**
   * Compares the carrier offers of the open tender round of a freight order (or of its
   * last round, if none is open). Quoted offers come first, ranked by price and then by
   * transit time; rank 1 is the cheapest. canAward tells whether the offer can be awarded
   * right now, and reason names the rule that blocks it otherwise. Use this before
   * recommending or awarding an offer.
   */
  function compareOffers(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20) @mandatory
  ) returns OfferComparison;

  // --- changes (actions) ----------------------------------------------------------------
  // Each delegates to the bound DispatchService action, which checks award-rules.js and
  // writes to the local entities only; TM stays read-only. @agent.hitl pauses the agent's
  // task (input-required) until the user approves the call. It does not cover external
  // MCP clients, which call the tool directly (development plan 6.7). Every action returns
  // the freight order summary, so the result of the change needs no second call.

  /**
   * Starts a new tender round on a freight order: invites the given carriers to quote
   * until the deadline. Not possible while another round of the freight order is open, or
   * once it is awarded. Changes data: call it only when the user asked to start a tender.
   */
  @agent.hitl
  action startTender(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20) @mandatory,
    /** BROADCAST (all invited carriers quote until the deadline; award only after it has passed), PEER (an offer can be awarded before the deadline) or SPOT (ad-hoc spot quote). */
    mode           : String(10) @mandatory,
    /** Quote deadline in UTC as an ISO timestamp, e.g. 2026-10-02T12:00:00Z. Must be in the future. */
    deadline       : Timestamp  @mandatory,
    /** Carrier IDs to invite, at least one, each an active carrier from the Carriers entity, e.g. 10300001. */
    carriers       : many String(10)
  ) returns FreightOrderSummary;

  /**
   * Cancels the tender of a freight order: closes its open round, expires the unanswered
   * invitations and sets the dispatch status to FAILED. The reason is kept as a note.
   * Changes data: call it only when the user asked to cancel the tender.
   */
  @agent.hitl
  action cancelTender(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20)   @mandatory,
    /** Why the tender is cancelled. */
    reason         : String(1000) @mandatory
  ) returns FreightOrderSummary;

  /**
   * Closes the open tender round of a freight order without awarding: invitations that
   * were not answered expire, and a new round can be started afterwards. Changes data:
   * call it only when the user asked to close the round.
   */
  @agent.hitl
  action closeRound(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20) @mandatory
  ) returns FreightOrderSummary;

  /**
   * Awards a carrier offer: the offer wins, the other quoted offers of the round lose, the
   * round is closed and the freight order becomes AWARDED with this carrier and price. The
   * offer must be quoted and its round open; in a BROADCAST round the deadline must have
   * passed. Check with compareOffers first. Changes data and cannot be undone: call it
   * only when the user asked to award this offer.
   */
  @agent.hitl
  action award(
    /** ID of the offer to award, as offerId from compareOffers or freightOrderSummary. */
    offerId : UUID @mandatory
  ) returns FreightOrderSummary;

  /**
   * Reports an execution event for a freight order: pickup, delivery, a delay or a
   * damage. The event time is the time of the report. Changes data: call it only when the
   * user asked to report the event.
   */
  @agent.hitl
  action reportException(
    /** Freight order ID, e.g. 6100000002. */
    freightOrderId : String(20) @mandatory,
    /** PICKED_UP, DELIVERED, DELAY or DAMAGE. */
    type           : String(12) @mandatory,
    /** Cause of a delay: TRAFFIC, WEATHER, CARRIER, SHIPPER or CUSTOMS. Required when type is DELAY. */
    reason         : String(10),
    /** Length of the delay in minutes; not negative. */
    minutes        : Integer
  ) returns FreightOrderSummary;
}
