import 'package:go_router/go_router.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/landing_page.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/feature_detail_page.dart';
import 'package:peilar_superapp/features/auth/presentation/pages/student_bind_page.dart';
import 'package:peilar_superapp/features/auth/presentation/pages/card_design_edit_page.dart';
import 'package:peilar_superapp/features/itinerary/presentation/pages/ai_itinerary_page.dart';
import 'package:peilar_superapp/features/itinerary/presentation/pages/itinerary_result_page.dart';
import 'package:peilar_superapp/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'package:peilar_superapp/features/qr_scanner/presentation/pages/payment_page.dart';
import 'package:peilar_superapp/features/qr_scanner/presentation/pages/payment_result_page.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/secondhand_marketplace_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/feature/:id',
      builder: (context, state) {
        return FeatureDetailPage(
          featureId: state.pathParameters['id'] ?? 'feature',
          data: state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null,
        );
      },
    ),
    GoRoute(
      path: '/student-bind',
      builder: (context, state) => const StudentBindPage(),
    ),
    GoRoute(
      path: '/ai-itinerary',
      builder: (context, state) => const AiItineraryPage(),
    ),
    GoRoute(
      path: '/itinerary-result',
      builder: (context, state) => const ItineraryResultPage(),
    ),
    GoRoute(
      path: '/qr-scanner',
      builder: (context, state) => const QrScannerPage(),
    ),
    GoRoute(path: '/payment', builder: (context, state) => const PaymentPage()),
    GoRoute(
      path: '/payment-result',
      builder: (context, state) => const PaymentResultPage(),
    ),
    GoRoute(
      path: '/secondhand',
      builder: (context, state) => const SecondhandMarketplacePage(),
    ),
    GoRoute(
      path: '/card-design-edit',
      builder: (context, state) => const CardDesignEditPage(),
    ),
  ],
);
