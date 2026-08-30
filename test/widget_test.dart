// Splash renders the brand. Full-app boot is covered by integration/manual
// runs since it requires Firebase initialization.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/core/theme/app_theme.dart';
import 'package:swiftdrop/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('Splash shows the SwiftDrop brand', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const SplashScreen()),
    );
    await tester.pump();

    expect(find.text('SwiftDrop'), findsOneWidget);
    expect(find.text('Deliver together. Arrive smarter.'), findsOneWidget);
  });
}
