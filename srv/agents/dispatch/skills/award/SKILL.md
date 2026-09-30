---
name: award
description: Rules and steps for comparing carrier offers and awarding one, and for reporting execution events after the award. Read this before calling award or reportException, and when the user asks which offer is best, why an offer cannot be awarded yet, or what happens after an award.
metadata:
  tags: [award, offers, quotes, compare, exception]
  examples:
    - Compare the offers for 6100000005 and award the cheapest.
    - Why can't I award the offer from Alpine Freight yet?
    - Report a 45 minute traffic delay on 6100000003.
---

# Awarding an offer

## When an offer can be awarded

All of this must hold:

- The offer is `QUOTED`: the carrier submitted a price and a transit time.
- Its round is still open.
- The freight order is not `AWARDED` already.
- In a `BROADCAST` round, the quote deadline has passed.

You do not need to work this out yourself. `compareOffers` returns `canAward` for every offer, and `reason` with the rule that blocks it.

## Comparing

1. Call `compareOffers` with the freight order ID, every time. Quotes arrive until the deadline, so an earlier comparison may be incomplete.
2. Present the quoted offers in rank order: carrier, price with currency, transit time in hours, and the carrier's comment if there is one. Rank 1 is the lowest price; equal prices are ranked by shorter transit time.
3. Mention what the ranking does not show:
   - A slightly more expensive offer with a clearly shorter transit time. Whether the difference matters depends on the delivery date, which `freightOrderSummary` shows. The dispatcher decides.
   - Carriers that were invited but have not answered, if the round is still open and the deadline has not passed.
   - Quotes in different currencies. Then there is no rank and `note` says so. Show them side by side and do not convert.
4. If no offer can be awarded, give the `reason` and what changes it. For a broadcast round before the deadline, that is the deadline itself: state when it passes.

Recommend only on the facts you have: price, transit time and the dates. You know nothing about carrier reliability or contracts, so do not imply it.

## Awarding (`award`)

1. Take the `offerId` from a `compareOffers` result you just read, never from earlier in the conversation or from memory.
2. "Award the cheapest" means rank 1. If rank 1 cannot be awarded, do not move on to rank 2 on your own; explain and ask.
3. Say what you are about to award: freight order ID, carrier, price with currency and transit time. Then call `award`.
4. From the result, confirm the awarded carrier and price.

What the award does: the offer becomes `WON`, the other quoted offers of the round `LOST`, unanswered invitations `EXPIRED`, the round is closed, and the freight order becomes `AWARDED` with the carrier, the price, the time and the dispatcher's user as the awarding user.

An award cannot be undone or moved to another offer. The only way back is `cancelTender`, which ends tendering for the freight order altogether. That is why the dispatcher should see carrier and price in your own words before the approval prompt.

## After the award: execution events (`reportException`)

Once a freight order is on its way, the dispatcher records what happens to it.

| Type | Meaning | Also needed |
| --- | --- | --- |
| `PICKED_UP` | Goods picked up at the source location. | |
| `DELIVERED` | Goods delivered at the destination. | |
| `DELAY` | The shipment is late. | A reason: `TRAFFIC`, `WEATHER`, `CARRIER` (vehicle or driver), `SHIPPER` (goods not ready at pickup) or `CUSTOMS`. The delay in minutes, if known. |
| `DAMAGE` | Goods damaged in transit. | |

The event time is the time of the report; it cannot be set to an earlier time. If the dispatcher reports something that happened hours ago, tell them the event will carry the current time.

If the dispatcher describes a delay without a cause that maps to one of the reasons, ask which one fits. Do not choose for them: delays are attributed to the awarded carrier in the carrier scorecard, and the reason records whether the carrier caused it, so a guessed reason distorts that picture.

Reported events can be read from the `ExecutionEvents` entity with the query tool.
