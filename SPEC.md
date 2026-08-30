# SwiftDrop — Locked Build Specification

> Status: **Blueprint finalized — ready to code.** All 5 open questions resolved.
> Tagline: *Deliver together. Arrive smarter.*
> Stack: Flutter 3.x · flutter_bloc + freezed · get_it/injectable · go_router · Firestore · Firebase Auth (Phone OTP) · google_maps_flutter · FCM · hive_flutter · dio · cached_network_image

---

## 0. Resolved Decisions (the 5 open questions)

| # | Question | Decision |
|---|----------|----------|
| 1 | Driver tracking for MVP | **Mock simulation** — animated pin + timer-driven status |
| 2 | Group order delivery fee | **Split equally** among participants |
| 3 | Eco Bundle Mode | **UI label + auto discount** (no real batching in MVP) |
| 4 | Passport neighborhoods | **Seed Firestore** once with a fixed Tunis list |
| 5 | Restaurant data | **Seed fake restaurants** (schema-stable for real partners later) |

---

## 1. Mock Driver Simulation (resolves Q1)

No driver app, no real GeoPoint writes. Everything is client-side and demo-paced.

**Driver pool** (pick one at random when an order is placed):
- Each driver: `name`, `rating` (4.6–4.9), `vehicle` (e.g. "Scooter"), `initials` for avatar.
- e.g. Mehdi K. · Yassine B. · Sami T. · Oussama R.

**Status auto-advance** (demo timings — keep in one config constant `kDemoTimings`):
| Step | Status enum | Fires at |
|------|-------------|----------|
| Order placed | `confirmed` | 0 s |
| Kitchen | `preparing` | +8 s |
| Driver pickup | `picked_up` | +16 s |
| En route | `on_the_way` (pin animates) | +24 s |
| Arrived | `delivered` | +40 s |

**Pin movement:** linearly interpolate `driverLocation` between the restaurant's
`(lat,lng)` and the delivery address `(lat,lng)` over the `on_the_way` window.
Drive it with a single `AnimationController` / `Timer.periodic` in the tracking bloc.

> Production note: the `Order.driverId` / `driverLocation` fields stay in the model
> unchanged, so a real driver app can later write to them with zero schema change.

---

## 2. Group Order — Equal Fee Split (resolves Q2)

- `feeShare = (deliveryFeeTND / participantCount)` rounded to 3 decimals (TND millimes).
- The **last** participant absorbs any rounding remainder so the parts sum exactly to `deliveryFeeTND`.
- `Order.deliveryFeeTND` remains the **full** fee (single delivery). The split is a
  presentation concern shown per participant in the Group Lobby + Checkout.
- Each participant row shows: `their items subtotal + their feeShare = their total`.
- Host taps **Lock & Checkout** → one combined `Order` is created with
  `isGroupOrder = true`, `groupOrderId` set, and `items` = flattened participant items.

---

## 3. Eco Bundle Mode — Cosmetic + Auto Discount (resolves Q3)

Pure UX, no real order batching. Constants live in `kEcoConfig`:

- **Discount:** flat `ecoDiscountTND = 1.5` when the toggle is on.
- **Simulated bundle size:** random integer `2–3` ("Bundled with N nearby orders").
- **CO₂ saved:** `co2SavedGrams = 70 * bundleSize` → **140–210 g** per eco order.
- On checkout: `ecoDiscountTND` subtracts from total; `isEcoOrder = true`;
  `co2SavedGrams` stored on the order.
- On delivery: `User.totalCo2Saved += co2SavedGrams`, shown on Profile.
- Order Tracking shows a "Bundled with N nearby orders" chip + CO₂ chip.

> Production note: real batching (matching nearby pending orders) is V2; the toggle,
> discount line, and CO₂ accounting are already complete UX.

---

## 4. Passport Neighborhoods — Firestore Seed (resolves Q4)

Written once to `/neighborhoods/{id}` via a seed routine. Fixed Tunis list,
`requiredStamps = 3` each unless noted. Editable without an app update.

| id | name | emoji | deal |
|----|------|-------|------|
| centre_ville | Centre Ville | 🏙️ | 15% off any order |
| lac1 | Les Berges du Lac 1 | 🌊 | Free delivery x1 |
| lac2 | Lac 2 | 🛥️ | 20% off |
| el_menzah | El Menzah | 🌿 | 20% off a partner resto |
| la_marsa | La Marsa | 🏖️ | Free dessert |
| carthage | Carthage | 🏛️ | 15% off |
| bardo | Le Bardo | 🕌 | Free delivery x2 |
| beb_bhar | Beb Bhar | 🚪 | 10% off |
| ariana | Ariana | 🌳 | 15% off |
| manar | El Manar | 🎓 | Free delivery x1 |

A stamp is earned when an order's `neighborhoodId` is completed for the first time
(logic on the Order Delivered screen). After `requiredStamps` orders in a zone the
deal unlocks → FCM push.

---

## 5. Restaurant Data — Seeded Fakes (resolves Q5)

Seed `/restaurants/{id}` (+ `/restaurants/{id}/menuItems/{id}`) with realistic Tunis
data. Schema is identical to a real-partner record, so partners swap in later with no
migration. Minimum viable seed:

- **Food:** ~6 restaurants across neighborhoods (pizza, tacos, lablabi, sushi, burgers, grilled).
- **Grocery:** ~2 (Monoprix-style mini-market, fresh produce).
- **Pharmacy:** ~1.
- Each restaurant: 8–15 menu items, 1–2 with `MenuOption`s (size / extras).
- Set `isEcoEligible`, `neighborhood` (maps to a `/neighborhoods` id), `rating`,
  `deliveryFeeTND`, `estimatedMinutes`, `isOpen`.

A single `seed.dart` (or Firebase callable / one-off script) writes neighborhoods +
restaurants + menus together.

---

## 6. Data Model Deltas vs. original blueprint

These are the only model adjustments implied by the decisions above — everything else
in the original blueprint stands as written:

- `Order` — no new fields needed; `driverLocation`/`driverId` now populated by the
  **mock** simulator. Add nothing.
- `GroupOrder.participants[].feeShare (double)` — derived at lock time, stored for
  receipt clarity (optional; can be recomputed).
- Add app-level config constants (not Firestore): `kDemoTimings`, `kEcoConfig`.

---

## 7. Build Order (unchanged, now unblocked)

1. **Phase 1 — Solo loop:** Auth (OTP) → Home → Restaurant Menu → Item Detail → Cart → Checkout → (mock) Order Tracking → Delivered. Includes the seed routine so screens have data.
2. **Phase 2 — History & polish:** Order History, Order Detail, reorder, Profile.
3. **Phase 3 — Group Order:** Lobby with real-time Firestore sync, equal-split checkout.
4. **Phase 4 — Eco + Passport:** Eco toggle + CO₂ accounting, Passport map + stamps, Profile eco stats.

---

## 8. Definition of Done for MVP

- [ ] Solo order completes end-to-end with mock tracking animating.
- [ ] Group order: 2+ participants join a shared cart, fee splits equally, one combined order.
- [ ] Eco toggle applies −1.5 TND, stores CO₂, updates Profile total.
- [ ] Passport: first order in a zone earns a stamp; 3 stamps unlock a deal + push.
- [ ] All data (restaurants, menus, neighborhoods) loaded from seeded Firestore.
- [ ] Phone OTP auth + address setup on first launch.
