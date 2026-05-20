import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/landing_page.dart';
import 'package:peilar_superapp/features/landing/presentation/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('LandingPage renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LandingPage(),
        ),
      ),
    );

    // Verify presence of BottomNavBar which is always present
    expect(find.byType(BottomNavBar), findsOneWidget);

    // Verify some content from the landing page
    expect(find.text('Easy Wallet'), findsOneWidget);
  });
}
