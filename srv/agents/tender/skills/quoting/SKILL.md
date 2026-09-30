---
name: quoting
description: Rules and steps for entering a carrier's quote or decline for a tender invitation - which values a quote needs, confirming price and currency, and warning when the deadline is close. Read this before calling submitQuote or decline, and when the user asks why a quote was rejected or what happens after it.
metadata:
  tags: [quote, decline, invitation, deadline]
  examples:
    - Which invitations are still open for Alpine Freight?
    - Rhein Logistik quotes 1,250 EUR and 18 hours for 6100000002.
    - Alpine Freight declines 6100000003, no truck available.
---

# Quoting

## When an invitation can be answered

| Answer | Possible while |
| --- | --- |
| Quote (`submitQuote`) | The invitation is `INVITED`, its round is open and the quote deadline has not passed. |
| Decline (`decline`) | The invitation is `INVITED` and its round is open. |

Either answer is final: a quote cannot be changed or withdrawn, and a declined invitation cannot be quoted afterwards. Only the dispatcher can start a new round, in which the carrier would be invited again.

`invitationDetails` returns `canRespond`: true while a quote is still possible.

## Submitting a quote (`submitQuote`)

A quote needs all three values from the user:

- **Price** for the whole freight order, greater than 0.
- **Currency** as a three-letter code, for example `EUR`, `CHF` or `USD`. If the user gave only a symbol or a word ("euros", "Franken"), state the code you understood. If the currency is missing, ask; do not assume `EUR`.
- **Transit time** in whole hours, from pickup to delivery, greater than 0. If the user gave days ("two days"), convert to hours and state it (48 h).

Steps:

1. Find the invitation with `openInvitations` (carrier and freight order ID). If it is not there, read it with `invitationDetails` and explain its status instead of quoting.
2. If `lessThan24hLeft` is true, warn: "Less than 24 hours left: deadline <UTC time> (<time left>)." A quote after the deadline is rejected.
3. **Confirm the price and currency back to the user** in your own words before the call, together with carrier, freight order ID and transit time, for example: "Quote for Rhein Logistik (10300001) on 6100000002: 1,250.00 EUR, 18 h transit, comment 'by phone'." Read numbers back exactly as given; if the user's message is ambiguous (such as `1.250` or `1,250`, which can mean 1250 or 1.25), ask which one they mean.
4. Call `submitQuote` with the offer ID from step 1.
5. From the result, confirm that the status is `QUOTED`, with price, currency and transit time.

Put anything else the carrier said about the quote (validity, conditions, vehicle type) in the comment, at most 255 characters, if the user wants it recorded.

## Declining (`decline`)

1. Find the invitation as for a quote.
2. Say what you are about to decline: carrier, freight order ID, and the reason if one was given. The reason goes in the comment.
3. Call `decline`, and confirm the `DECLINED` status from the result.

A decline is also possible after the deadline, while the round is still open; that tells the dispatcher not to wait for this carrier.

## After the answer

- The dispatcher compares the quotes and awards one in the Dispatch Cockpit. In a `BROADCAST` round that happens only after the deadline, in `PEER` and `SPOT` rounds possibly earlier.
- The outcome shows in `invitationDetails`: `WON` when this offer was awarded, `LOST` when another one was. You do not know and cannot tell the user anything about the other offers or the awarded price.
- `EXPIRED` means the deadline passed or the dispatcher closed the round before the carrier answered.

## When a call is rejected

| Message | Meaning |
| --- | --- |
| Only an open invitation can be quoted / declined | Already answered, expired or closed. Read `invitationDetails` and give the status. |
| The tender round is already closed | The dispatcher closed the round or awarded another offer. |
| The quote deadline has passed | Too late for a quote; a decline is still possible while the round is open. |
| The price must be greater than 0 / The transit time must be greater than 0 hours | Ask the user for the correct value. |
| Not a currency code | Ask for the three-letter code. |
