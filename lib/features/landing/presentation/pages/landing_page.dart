import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/top_features_grid.dart';
import '../widgets/feature_category_list.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../domain/entities/feature_item.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  void _handleFeatureTap(BuildContext context, FeatureItem feature) {
    if (feature.requiresAuth) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Authentication Required'),
          content: Text('Please log in to access ${feature.title}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Log In'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to ${feature.title}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const PromoCarousel(),
            const SizedBox(height: 24),
            TopFeaturesGrid(onFeatureTap: (f) => _handleFeatureTap(context, f)),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 8, color: Colors.black12),
            const SizedBox(height: 8),
            FeatureCategoryList(onFeatureTap: (f) => _handleFeatureTap(context, f)),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
