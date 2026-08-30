import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/models/store_vertical.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/core/widgets/skeletons.dart';
import 'package:swiftdrop/data/repositories/restaurant_repository.dart';
import 'package:swiftdrop/features/search/presentation/search_screen.dart';

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(320, 640)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100)); // let the pulse tick
}

/// Never emits and never closes — keeps the search screen in its loading state.
/// (Stream.empty() would close immediately, ending the waiting state.)
class _PendingRepo implements RestaurantRepository {
  final _controller = StreamController<List<Restaurant>>.broadcast();

  @override
  Stream<List<Restaurant>> watchRestaurants({String? category}) =>
      _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('store list skeleton lays out on a narrow screen',
      (tester) async {
    await _pump(
      tester,
      const Padding(
        padding: EdgeInsets.all(20),
        child: StoreListSkeleton(),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(StoreCardSkeleton), findsNWidgets(3));
  });

  testWidgets('product grid skeleton lays out on a narrow screen',
      (tester) async {
    await _pump(
      tester,
      const Padding(
        padding: EdgeInsets.all(20),
        child: ProductGridSkeleton(),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(ProductTileSkeleton), findsNWidgets(6));
  });

  testWidgets('search shows skeletons, not a spinner, while loading',
      (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SearchScreen(
          vertical: StoreVertical.fastFood,
          repo: _PendingRepo(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(StoreCardSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // The pulse animation repeats forever; settle the pump by removing it.
    await tester.pumpWidget(const SizedBox());
  });
}
