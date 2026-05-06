import 'package:go_router/go_router.dart';
import 'package:peilar_superapp/features/landing/presentation/pages/landing_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
  ],
);
