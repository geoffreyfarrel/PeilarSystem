import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_landing_repository.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/entities/feature_item.dart';

final landingRepositoryProvider = Provider<MockLandingRepository>((ref) {
  return MockLandingRepository();
});

final promoBannersProvider = FutureProvider<List<PromoBanner>>((ref) {
  return ref.read(landingRepositoryProvider).getPromoBanners();
});

final topFeaturesProvider = FutureProvider<List<FeatureItem>>((ref) {
  return ref.read(landingRepositoryProvider).getTopFeatures();
});

final featureCategoriesProvider = FutureProvider<List<FeatureCategory>>((ref) {
  return ref.read(landingRepositoryProvider).getFeatureCategories();
});
