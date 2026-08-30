import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';

/// Brand moment shown while [AuthCubit] resolves the persisted session.
/// The router's redirect moves the user on once auth state is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.ember, Color(0xFFFF9466)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.bolt_rounded,
                  color: context.colors.onEmber, size: 52),
            ),
            const SizedBox(height: 24),
            Text('SwiftDrop',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 6),
            Text('Deliver together. Arrive smarter.',
                style: AppTypography.mono(
                    fontSize: 13, color: context.colors.inkSoft)),
            const SizedBox(height: 40),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: context.colors.ember),
            ),
          ],
        ),
      ),
    );
  }
}
