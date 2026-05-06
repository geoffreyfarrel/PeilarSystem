import 'package:flutter/material.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/entities/feature_item.dart';

class MockLandingRepository {
  Future<List<PromoBanner>> getPromoBanners() async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const PromoBanner(
        id: '1',
        imageUrl: 'https://picsum.photos/id/1018/800/400',
        targetRoute: '/promo/1',
      ),
      const PromoBanner(
        id: '2',
        imageUrl: 'https://picsum.photos/id/1015/800/400',
        targetRoute: '/promo/2',
      ),
      const PromoBanner(
        id: '3',
        imageUrl: 'https://picsum.photos/id/1019/800/400',
        targetRoute: '/promo/3',
      ),
    ];
  }

  Future<List<FeatureItem>> getTopFeatures() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const FeatureItem(
        id: 'f1',
        title: 'QR Payment',
        iconData: Icons.qr_code_scanner,
        targetRoute: '/payment',
        requiresAuth: false,
      ),
      const FeatureItem(
        id: 'f2',
        title: 'Digital Card',
        iconData: Icons.credit_card,
        targetRoute: '/digital-card',
        requiresAuth: true, // Student only
      ),
      const FeatureItem(
        id: 'f3',
        title: 'Transfer',
        iconData: Icons.compare_arrows,
        targetRoute: '/transfer',
        requiresAuth: true,
      ),
      const FeatureItem(
        id: 'f4',
        title: 'Travel Hub',
        iconData: Icons.map,
        targetRoute: '/travel',
        requiresAuth: false,
      ),
    ];
  }

  Future<List<FeatureCategory>> getFeatureCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      FeatureCategory(
        id: 'c1',
        title: 'Campus Life',
        items: [
          const FeatureItem(
            id: 'c1_f1',
            title: 'Secondhand Books',
            iconData: Icons.menu_book,
            targetRoute: '/books',
            requiresAuth: true, // Student only
          ),
          const FeatureItem(
            id: 'c1_f2',
            title: 'Student Forum',
            iconData: Icons.forum,
            targetRoute: '/forum',
            requiresAuth: true, // Student only
          ),
          const FeatureItem(
            id: 'c1_f3',
            title: 'Laundry Hub',
            iconData: Icons.local_laundry_service,
            targetRoute: '/laundry',
            requiresAuth: false,
          ),
        ],
      ),
      FeatureCategory(
        id: 'c2',
        title: 'Lifestyle',
        items: [
          const FeatureItem(
            id: 'c2_f1',
            title: 'Food Delivery',
            iconData: Icons.fastfood,
            targetRoute: '/food',
            requiresAuth: false,
          ),
          const FeatureItem(
            id: 'c2_f2',
            title: 'Movie Tickets',
            iconData: Icons.movie,
            targetRoute: '/movies',
            requiresAuth: false,
          ),
        ],
      ),
    ];
  }
}
