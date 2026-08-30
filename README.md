# SwiftDrop

*Deliver together. Arrive smarter.*

A Tunis food-delivery app built on Flutter + Firebase. Beyond the standard
browse → cart → checkout → track loop, it has three differentiators:

- **Group orders** — a shared cart with the delivery fee split equally.
- **Eco Bundle Mode** — a discount plus CO₂ accounting for bundled deliveries.
- **Delivery Passport** — collect stamps per Tunis neighborhood to unlock deals.

The full product spec, including the mock-driver simulation and eco math, is in
[SPEC.md](SPEC.md).

**Stack:** Flutter 3.x · flutter_bloc · get_it · go_router · Firestore ·
Firebase Auth (Phone OTP)

---

## Running it

```bash
flutter pub get
flutter run
```

Firebase project: `swiftdrop-da64a` (config is committed in
`lib/firebase_options.dart`).

---

## Business model — SwiftDrop Plus

A subscription tier gating three perks (see
[plus_config.dart](lib/core/constants/plus_config.dart)):

| Perk | Free | Plus |
|---|---|---|
| Browse, order, track, Passport stamps | ✅ | ✅ |
| Join a group order via invite code | ✅ | ✅ |
| Delivery fee | Pays it | **Waived** |
| Eco Bundle Mode | 🔒 | ✅ |
| **Host** a group order | 🔒 | ✅ |

Plans: Weekly 6.99 TND (3-day trial), Monthly 19.99 TND, Yearly 89.99 TND.
Per-week prices and the "% OFF" badges are **derived** from price ÷ period, so
the merchandising can't advertise a discount a plan doesn't give.

Entitlement is `AppUser.plusUntil`, and `isPlus()` is derived from it — an expiry
needs no job to flip it off, so a subscription can't get stuck active. Losing
Plus mid-cart also drops Eco Bundle, so totals never keep an unentitled perk.

> ### ⚠️ The purchase is a stub
>
> `AuthRepository.activatePlus` just writes an expiry. **No payment is taken and
> nothing verifies entitlement** — the client writes its own `plusUntil`, so any
> user can grant themselves Plus for free, and the gating is cosmetic.
>
> To make it real: the store (App Store / Play) becomes the source of truth, its
> server-to-server webhook hits a Cloud Function that writes `plusUntil`, and
> `plusPlanId` / `plusUntil` come **out** of the client-writable allowlist in
> `validProfile` (firestore.rules). Only then does any of the gating bind.

## Passport deals

Stamps unlock a neighborhood's deal; the code is redeemed at checkout. Deals are
structured, not prose — `DealType` (percent off / free delivery / fixed off) plus
a value, so checkout can actually compute what a code is worth. `dealDescription`
is human copy and is never parsed.

Two rules worth knowing:

- **Redemption caps are load-bearing.** Free delivery is the headline Plus perk,
  so an uncapped free-delivery deal would undercut the subscription. Caps come
  from `PassportDeal.maxRedemptions` (the `xN` in SPEC §4).
- **Redemptions are derived** by counting orders carrying the code
  ([UserStats](lib/core/models/user_stats.dart)) — no ledger to drift. They count
  from *placement* (not delivery), or a single-use code could be spent several
  times inside the 40-second delivery window. Cancelling releases the redemption.

The cart stores the **deal**, not a fixed discount: a 20% deal worth 4 TND on a
20 TND cart must not still take 4 TND off after the user halves it.

## Payments

There is **no payment gateway and no in-app charge**. Both methods are settled
with the driver — cash, or card on a POS terminal at the door (standard in
Tunis). That's why `PaymentMethod` can offer "Card" honestly; checkout previously
let users pick Card and then silently recorded the order as cash.

## Security model

Two things are worth knowing before changing data code, because both are
enforced by [firestore.rules](firestore.rules) and a violation shows up as an
opaque `permission-denied` at runtime.

### Order status is derived, not stored

The mock delivery simulation is a pure function of time, so status is computed
from the order's server-stamped `placedAt` — see
[`OrderTimeline`](lib/core/utils/order_timeline.dart). Nothing writes
transitions.

Consequences:

- `/orders` is **create-only**. There is no `updateStatus` or `markDelivered`.
- New orders must leave `placedAt` **null** so `toMap()` emits a
  `serverTimestamp()` sentinel. Rules require `placedAt == request.time`, so a
  client-supplied timestamp is rejected.
- Read status via `order.liveStatus()`, never the stored `order.status` (which
  is only a seed value written at creation).

This also means tracking survives the app being closed: reopening a 30-second-old
order correctly shows "on the way" rather than resuming from a dead timer.

### User stats are derived, not stored

Order / CO₂ / stamp totals are projected from the user's own delivered orders via
[`UserStats`](lib/core/models/user_stats.dart), and are **not** fields on
`/users`. A stored counter would have to be incremented by whoever completes the
order — which, on a client-driven simulation, is the client, letting anyone grant
themselves stamps for free.

Rules pin `/users` to an exact field allowlist (`hasOnly`), so adding a counter to
`AppUser.toMap()` will be rejected by the backend. If you add a profile field,
update the `validProfile` allowlist in `firestore.rules` to match.

---

## Firestore rules

Validate without deploying:

```bash
firebase deploy --only firestore:rules --dry-run
```

Deploy:

```bash
firebase deploy --only firestore:rules
```

> The Firestore emulator needs **JDK 21+**. On an older JDK,
> `firebase emulators:*` fails; the `--dry-run` above still works.

---

## Seeding the catalog

`/restaurants`, `/restaurants/{id}/menuItems` and `/neighborhoods` are
**admin-write-only**. The app does not seed itself — that used to run on every
Home mount, costing a read per launch.

Seed data lives in [lib/data/seed/seed_data.dart](lib/data/seed/seed_data.dart)
and is written by [`FirestoreSeeder`](lib/data/seed/firestore_seeder.dart). To
run it, grant your account the `admin` custom claim with the Admin SDK:

```js
admin.auth().setCustomUserClaims(uid, { admin: true });
```

The claim reaches the ID token on next refresh; then call
`FirestoreSeeder().seed()` while signed in as that account.

---

## Tests

```bash
flutter test
```

Coverage is on the pure derivation logic — `OrderTimeline` and `UserStats` — since
that is where the security properties live. The rest is covered by manual runs.
