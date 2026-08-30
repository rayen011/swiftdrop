import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../utils/food_images.dart';
import 'app_network_image.dart';

/// Renders the photo for a dish or restaurant, choosing the best source:
///
///  1. A real partner's `imageUrl` from Firestore, if set — always wins.
///  2. A bundled asset at `assets/food/{keyword}.jpg`, if the file exists.
///  3. The network keyword photo (LoremFlickr) otherwise.
///
/// Step 2 is why this exists: drop a `burger.jpg` into [FoodImages.assetDir] and
/// every burger uses it, with no code change. A missing file quietly degrades to
/// step 3 via [Image.asset]'s errorBuilder, so screenshots look right whether or
/// not the assets have been added yet.
class FoodImage extends StatelessWidget {
  const FoodImage._({
    required this.firestoreUrl,
    required this.assetPath,
    required this.networkUrl,
    required this.fit,
  });

  factory FoodImage.menuItem(MenuItem item, {BoxFit fit = BoxFit.cover}) =>
      FoodImage._(
        firestoreUrl: item.imageUrl,
        assetPath: FoodImages.assetForMenuItem(item),
        networkUrl: FoodImages.forMenuItem(item),
        fit: fit,
      );

  factory FoodImage.restaurant(Restaurant restaurant,
          {BoxFit fit = BoxFit.cover}) =>
      FoodImage._(
        firestoreUrl: restaurant.imageUrl,
        assetPath: FoodImages.assetForRestaurant(restaurant),
        networkUrl: FoodImages.forRestaurant(restaurant),
        fit: fit,
      );

  final String firestoreUrl;
  final String assetPath;
  final String networkUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (firestoreUrl.isNotEmpty) {
      return AppNetworkImage(
          url: firestoreUrl, fallbackUrl: networkUrl, fit: fit);
    }
    return Image.asset(
      assetPath,
      fit: fit,
      // The file isn't there yet -> use the network photo rather than a broken
      // image box. This is the normal path until assets are populated.
      errorBuilder: (_, _, _) =>
          AppNetworkImage(url: '', fallbackUrl: networkUrl, fit: fit),
    );
  }
}
