// Regression test for the Passport deal sheet overflow: an unlocked deal on a
// short screen (header + reward + code + copy button) must scroll, not overflow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/models/neighborhood.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/features/passport/presentation/widgets/deal_detail_sheet.dart';

const _zone = PassportNeighborhood(
  id: 'la_marsa',
  name: 'La Marsa',
  city: 'Tunis',
  iconEmoji: '🏖️',
  deal: PassportDeal(
    type: DealType.fixedOff,
    value: 4,
    code: 'MARSADESS',
    description: "4 TND off — dessert's on us",
  ),
);

Future<void> _open(WidgetTester tester, {required Size size, int used = 0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              // 3 stamps earned, unlocked.
              onPressed: () =>
                  showDealDetailSheet(context, _zone, 3, redemptionsUsed: used),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('unlocked deal sheet fits a short screen', (tester) async {
    await _open(tester, size: const Size(360, 560));
    expect(tester.takeException(), isNull);
    expect(find.text('MARSADESS'), findsOneWidget);
    expect(find.textContaining('Unlocked'), findsOneWidget);
    expect(find.text('Copy code'), findsOneWidget);
  });

  testWidgets('holds up at a large text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 560),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDealDetailSheet(context, _zone, 3),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a spent deal shows the claimed state, not a code',
      (tester) async {
    await _open(tester, size: const Size(360, 640), used: 1); // cap is 1
    expect(tester.takeException(), isNull);
    expect(find.textContaining('claimed'), findsOneWidget);
    expect(find.text('MARSADESS'), findsNothing);
  });
}
