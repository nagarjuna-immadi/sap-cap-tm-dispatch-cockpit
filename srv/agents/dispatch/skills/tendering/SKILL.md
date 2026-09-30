---
name: tendering
description: Rules and steps for tender rounds on a freight order - choosing the mode (BROADCAST, PEER, SPOT), the carriers and the deadline, and when to close a round or cancel the tender. Read this before calling startTender, closeRound or cancelTender, and when the user asks how tendering works or why a tender cannot be started.
metadata:
  tags: [tender, round, carriers, deadline]
  examples:
    - Which freight orders from Munich still need a carrier?
    - Start a broadcast tender on 6100000005 to all carriers, deadline tomorrow 12:00 UTC.
    - Nobody quoted on 6100000002. Close the round and invite two other carriers.
---

# Tendering

A tender round invites a set of carriers to quote on one freight order until a deadline. A freight order can have several rounds, numbered from 1, but only one open round at a time.

## Dispatch status

| Status | Meaning | What is possible |
| --- | --- | --- |
| `NEW` | No tender started yet. A freight order that was never opened also counts as `NEW`. | Start a tender. |
| `TENDERING` | A round was started. It may be open or already closed without an award. | Award an offer of the open round, close the round, start the next round once none is open, cancel. |
| `AWARDED` | An offer was awarded. | Report execution events. |
| `FAILED` | The tender was cancelled. | Nothing further: a new tender cannot be started. |

## Modes

| Mode | Use it when | Award |
| --- | --- | --- |
| `BROADCAST` | Several carriers should compete on the same terms. | Only after the deadline has passed, so that every invited carrier had the same time to quote. |
| `PEER` | The dispatcher approaches one or a few preferred carriers. | Any time while the round is open, as soon as an offer is quoted. |
| `SPOT` | An ad-hoc quote for a single urgent shipment. | Any time while the round is open. |

The deadline rule for the award is the only difference the app enforces between the modes. If the dispatcher wants to be able to award early, that rules out `BROADCAST`; say so when they ask for a broadcast round with a long deadline on an urgent freight order.

## Starting a round (`startTender`)

The app accepts a new round only if all of this holds:

- The dispatch status is `NEW` or `TENDERING`.
- No round of the freight order is open. If one is, it must be closed first.
- The deadline is in the future.
- At least one carrier is given, none twice, and each is an active carrier.

Steps:

1. Read the freight order with `freightOrderSummary` to check its status and whether a round is open.
2. Settle the carriers. Read them from the `Carriers` entity; use the carrier IDs, not the names, in the call. "All carriers" means every row of `Carriers`. If the dispatcher named no carriers, ask which ones.
3. Settle the mode and the deadline. If either is missing, ask. For a relative deadline, read the current time first and work out the UTC timestamp.
4. Say what you are about to start (freight order ID, mode, deadline in UTC, carriers by name), then call `startTender`.
5. From the result, confirm the round number and the invited carriers.

In a later round, the dispatcher usually wants different carriers or a later deadline than in the round that brought no result. Show who was invited before and how they answered, so they can decide.

## While a round is open

- Carriers can quote until the deadline and decline at any time while the round is open.
- An invitation that was not answered by the deadline reads as `EXPIRED`.
- `deadlineExpired` is true when the round is still open although its deadline has passed. That round is waiting for the dispatcher: award an offer, or close it.

## Closing a round (`closeRound`)

Closing ends the round without an award. Unanswered invitations expire, the status stays `TENDERING`, and a new round can be started.

Close a round when the dispatcher wants to go on to another round: the deadline has passed without a usable quote, or the quotes are not acceptable.

Do not close a round to "finish" it before an award. An offer can only be awarded while its round is open, and the award closes the round by itself. If the round has quoted offers, point that out before closing: after closing, those offers can no longer be awarded.

## Cancelling a tender (`cancelTender`)

Cancelling closes any open round and sets the dispatch status to `FAILED`. The reason is mandatory and is kept as a note on the freight order.

Cancelling is final: no new tender can be started on a `FAILED` freight order, and the app allows it from any status, including `AWARDED`. So use it only when the dispatcher wants to give up tendering this freight order in the app, for example because the shipment was dropped. If they only want to try again with other carriers, that is `closeRound` followed by a new round. If the freight order is already `AWARDED`, make sure they mean to cancel the awarded order before you call it.
