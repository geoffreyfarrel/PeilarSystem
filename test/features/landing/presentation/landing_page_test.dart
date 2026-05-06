import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/landing_page.dart';
import 'package:peilar_superapp/features/landing/presentation/widgets/promo_carousel.dart';
import 'package:peilar_superapp/features/landing/presentation/widgets/top_features_grid.dart';
import 'package:peilar_superapp/features/landing/presentation/widgets/feature_category_list.dart';
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

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Let the FutureProviders complete
    await tester.pumpAndSettle();

    // Verify presence of all major components
    expect(find.byType(PromoCarousel), findsOneWidget);
    expect(find.byType(TopFeaturesGrid), findsOneWidget);
    expect(find.byType(FeatureCategoryList), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);

    // Verify some text from mock data
    expect(find.text('QR Payment'), findsOneWidget);
    expect(find.text('Campus Life'), findsOneWidget);
    expect(find.text('Lifestyle'), findsOneWidget);
  });
}
