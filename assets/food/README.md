# Food photos

Drop `.jpg` files in **this folder**, named by keyword. Each one replaces the
network placeholder for every matching dish/restaurant across the app. Anything
you don't add falls back to the network photo automatically — so you only need
the images for the screens you're screenshotting.

Filename = keyword + `.jpg` (lowercase). For example `assets/food/burger.jpg`.

## Priority — the food screenshots will show these

| File | Put a photo of… |
|------|------------------|
| `pizza.jpg` | a whole pizza |
| `burger.jpg` | a burger |
| `tacos.jpg` | tacos |
| `sushi.jpg` | a sushi platter |
| `soup.jpg` | a bowl of soup (lablabi / chickpea) |
| `fries.jpg` | french fries |
| `nuggets.jpg` | chicken nuggets |
| `harissa.jpg` | harissa / red chili paste |
| `lemonade.jpg` | a glass of lemonade |
| `cola.jpg` | a cola drink |
| `tea.jpg` | a cup of tea |
| `water.jpg` | a water bottle |
| `coffee.jpg` | a cup of coffee |
| `juice.jpg` | a glass of fresh juice |
| `croissant.jpg` | a croissant / pastry |

## Grocery & pharmacy (only if you screenshot those categories)

| File | Put a photo of… |
|------|------------------|
| `milk.jpg` | a milk carton |
| `eggs.jpg` | a carton of eggs |
| `pasta.jpg` | dry pasta |
| `orange.jpg` | oranges |
| `apple.jpg` | apples |
| `tomato.jpg` | tomatoes |
| `lettuce.jpg` | lettuce |
| `corn.jpg` | corn |
| `groceries.jpg` | a grocery/market shelf |
| `pills.jpg` | a blister pack of pills |
| `vitamins.jpg` | vitamin supplements |
| `mask.jpg` | a medical face mask |
| `medicine.jpg` | medicine / cough syrup |
| `skincare.jpg` | a face wash / skincare bottle |
| `pharmacy.jpg` | a pharmacy storefront |

## Generic fallbacks

| File | Put a photo of… |
|------|------------------|
| `drink.jpg` | any drink |
| `food.jpg` | any appetising dish |
| `restaurant.jpg` | a restaurant interior / plated food |

## Notes

- Any size works; the app crops to fit. Square-ish (≈800×800) is a safe default;
  restaurant banners are shown wide (≈800×500).
- Landscape licensing is on you — use photos you have the right to ship.
- Two dishes with the same keyword share a photo (both pizzas → `pizza.jpg`). If
  you want them distinct, that's a small code change — ask.
- After adding files, run `flutter pub get` (or hot-restart) so they're bundled.
