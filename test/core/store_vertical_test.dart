import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/store_vertical.dart';
import 'package:swiftdrop/data/seed/seed_data.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_en.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_fr.dart';

void main() {
  group('StoreVertical', () {
    test('maps to the Restaurant.category it filters by', () {
      expect(StoreVertical.fastFood.category, 'food');
      expect(StoreVertical.groceries.category, 'grocery');
      expect(StoreVertical.pharmacy.category, 'pharmacy');
      expect(StoreVertical.coffee.category, 'coffee');
    });

    test('fast food is the default landing vertical', () {
      expect(StoreVertical.menu.first, StoreVertical.fastFood);
    });

    test('every vertical carries complete copy in every language', () {
      // Exhaustive: a vertical added without its strings fails here for each
      // supported locale, not silently at runtime.
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsFr()]) {
        for (final v in StoreVertical.menu) {
          expect(v.label(l10n), isNotEmpty);
          expect(v.tagline(l10n), isNotEmpty);
          expect(v.listHeading(l10n), isNotEmpty);
          expect(v.searchHint(l10n), isNotEmpty);
          expect(v.emptyLabel(l10n), isNotEmpty);
        }
      }
    });

    test('French copy actually differs from English where it should', () {
      final en = AppLocalizationsEn();
      final fr = AppLocalizationsFr();
      expect(StoreVertical.groceries.label(fr),
          isNot(StoreVertical.groceries.label(en)));
      expect(StoreVertical.pharmacy.listHeading(fr),
          isNot(StoreVertical.pharmacy.listHeading(en)));
    });

    test('each vertical has at least one seeded store to show', () {
      for (final v in StoreVertical.menu) {
        final hasStore =
            seedRestaurants.any((r) => r.category == v.category);
        expect(hasStore, isTrue,
            reason: 'no seeded store for ${v.name} (${v.category})');
      }
    });
  });
}
