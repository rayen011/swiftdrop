import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/l10n/l10n.dart';
import 'package:swiftdrop/core/models/order.dart';
import 'package:swiftdrop/core/models/restaurant.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/features/cart/cubit/cart_cubit.dart';
import 'package:swiftdrop/features/cart/presentation/widgets/global_cart_bar.dart';

const _restaurant = Restaurant(
  id: 'resto_1',
  name: 'Le Grill du Lac',
  category: 'food',
  neighborhood: 'lac2',
  deliveryFeeTND: 2.5,
);

const _item = OrderItem(
  menuItemId: 'm1',
  name: 'Burger',
  priceTND: 10,
  quantity: 2,
);

Future<CartCubit> _pump(WidgetTester tester,
    {VoidCallback? onTap, Size size = const Size(360, 720)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final cubit = CartCubit();
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          bottomNavigationBar: GlobalCartBar(onTap: onTap ?? () {}),
        ),
      ),
    ),
  );
  return cubit;
}

void main() {
  testWidgets('collapsed when the cart is empty', (tester) async {
    await _pump(tester);
    expect(find.text('View cart'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appears with count, store and total once items are added',
      (tester) async {
    final cubit = await _pump(tester);

    cubit.addItem(_restaurant, _item);
    await tester.pumpAndSettle();

    expect(find.text('View cart'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // item count
    expect(find.text('Le Grill du Lac'), findsOneWidget);
    expect(find.text('22.5 TND'), findsOneWidget); // 20 + 2.5 delivery
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapses again when the cart empties', (tester) async {
    final cubit = await _pump(tester);
    cubit.addItem(_restaurant, _item);
    await tester.pumpAndSettle();
    expect(find.text('View cart'), findsOneWidget);

    cubit.clear();
    await tester.pumpAndSettle();
    expect(find.text('View cart'), findsNothing);
  });

  testWidgets('fires onTap', (tester) async {
    var taps = 0;
    final cubit = await _pump(tester, onTap: () => taps++);
    cubit.addItem(_restaurant, _item);
    await tester.pumpAndSettle();

    await tester.tap(find.text('View cart'));
    expect(taps, 1);
  });

  testWidgets('fits a narrow screen with a long store name', (tester) async {
    final cubit = await _pump(tester, size: const Size(320, 640));
    cubit.addItem(
      const Restaurant(
        id: 'r2',
        name: 'A Restaurant With A Very Long Name Indeed',
        category: 'food',
        neighborhood: 'lac2',
        deliveryFeeTND: 2,
      ),
      _item,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
