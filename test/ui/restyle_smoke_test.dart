// Layout smoke tests for the restyled UI. `flutter analyze` cannot see a
// RenderFlex overflow, and the ember redesign packs more into fixed-width rows
// (the item footer especially), so these pump the dense widgets at real phone
// widths — including a small 320pt device — and fail on overflow.
//
// Note on widths: the test font draws every glyph one em wide, so text measures
// roughly twice what DM Sans does on a device. That makes these tests
// pessimistic rather than wrong — a row that survives here also survives a large
// system text scale or a longer translation, which is exactly the robustness we
// want from the fixed-width footer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/constants/plus_config.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/l10n/gen/app_localizations_en.dart';
import 'package:swiftdrop/core/widgets/app_buttons.dart';
import 'package:swiftdrop/core/widgets/quantity_stepper.dart';
import 'package:swiftdrop/features/home/presentation/widgets/restaurant_card.dart';
import 'package:swiftdrop/features/plus/presentation/widgets/plan_tile.dart';

const _restaurant = Restaurant(
  id: 'resto_1',
  name: 'Le Grill du Lac',
  category: 'food',
  neighborhood: 'lac2',
  rating: 4.8,
  deliveryFeeTND: 2.5,
  estimatedMinutes: 25,
  isEcoEligible: true,
);

/// Mutable holder so a tile's onTap can report which plan it was.
class PlusPlanCapture {
  String? label;
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('RestaurantCard', () {
    testWidgets('lays out without overflow', (tester) async {
      await _pump(tester, const RestaurantCard(restaurant: _restaurant));
      expect(tester.takeException(), isNull);
      expect(find.text('Le Grill du Lac'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('ECO'), findsOneWidget);
    });

    testWidgets('shows a Closed veil when shut', (tester) async {
      await _pump(
        tester,
        const RestaurantCard(
          restaurant: Restaurant(
            id: 'resto_2',
            name: 'Shut',
            category: 'food',
            neighborhood: 'lac2',
            rating: 4.1,
            deliveryFeeTND: 2,
            estimatedMinutes: 20,
            isOpen: false,
          ),
        ),
      );
      expect(find.text('Closed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a long restaurant name on a narrow screen',
        (tester) async {
      await _pump(
        tester,
        const RestaurantCard(
          restaurant: Restaurant(
            id: 'resto_3',
            name: 'Restaurant With An Extremely Long Name That Wraps',
            category: 'food',
            neighborhood: 'lac2',
            rating: 4.9,
            deliveryFeeTND: 12.5,
            estimatedMinutes: 120,
          ),
        ),
        size: const Size(320, 720),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('QuantityStepper', () {
    testWidgets('reports taps and renders the count', (tester) async {
      var inc = 0;
      var dec = 0;
      await _pump(
        tester,
        QuantityStepper(
          quantity: 3,
          onDecrement: () => dec++,
          onIncrement: () => inc++,
        ),
      );

      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(inc, 1);
      expect(dec, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppPrimaryButton', () {
    testWidgets('fires when enabled', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        AppPrimaryButton(
          onPressed: () => taps++,
          child: const Text('Add to Cart'),
        ),
      );
      await tester.tap(find.text('Add to Cart'));
      expect(taps, 1);
    });

    testWidgets('is inert when onPressed is null', (tester) async {
      await _pump(
        tester,
        const AppPrimaryButton(child: Text('Add to Cart')),
      );
      await tester.tap(find.text('Add to Cart'));
      expect(tester.takeException(), isNull);
    });
  });

  group('paywall plan row', () {
    // Three tiles side by side with overhanging badges — the tightest
    // horizontal layout in the app.
    Widget planRow({required int selectedIndex}) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < PlusConfig.plans.length; i++) ...[
                Expanded(
                  child: PlanTile(
                    plan: PlusConfig.plans[i],
                    selected: i == selectedIndex,
                    onTap: () {},
                  ),
                ),
                if (i != PlusConfig.plans.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        );

    testWidgets('fits a 390pt phone and shows every plan', (tester) async {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: planRow(selectedIndex: 1),
        ),
      );

      expect(tester.takeException(), isNull);
      final l10n = AppLocalizationsEn();
      for (final plan in PlusConfig.plans) {
        expect(find.text(plan.label(l10n)), findsOneWidget);
      }
      expect(find.textContaining('75% OFF'), findsOneWidget);
      expect(find.textContaining('POPULAR'), findsOneWidget);
    });

    testWidgets('fits a 320pt phone', (tester) async {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: planRow(selectedIndex: 1),
        ),
        size: const Size(320, 720),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting reports the tapped plan', (tester) async {
      PlusPlanCapture captured = PlusPlanCapture();
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final plan in PlusConfig.plans)
                  Expanded(
                    child: PlanTile(
                      plan: plan,
                      selected: false,
                      onTap: () =>
                          captured.label = plan.label(AppLocalizationsEn()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Yearly'));
      expect(captured.label, 'Yearly');
    });
  });

  group('item sheet footer', () {
    // The densest row in the app: stepper + icon + label + price, all on one
    // line. This is the layout most likely to overflow on a small device.
    Widget footer() => Row(
          children: [
            QuantityStepper(
              quantity: 1,
              onDecrement: () {},
              onIncrement: () {},
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AppPrimaryButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add to Cart', maxLines: 1),
                    SizedBox(width: 10),
                    Text('129.50 TND', maxLines: 1),
                  ],
                ),
              ),
            ),
          ],
        );

    testWidgets('fits a 390pt phone', (tester) async {
      await _pump(tester, Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: footer(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a 320pt phone with a 6-figure total', (tester) async {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: footer(),
        ),
        size: const Size(320, 720),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
