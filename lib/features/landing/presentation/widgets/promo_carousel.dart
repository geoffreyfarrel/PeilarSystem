import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/landing_providers.dart';

class PromoCarousel extends ConsumerWidget {
  const PromoCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsyncValue = ref.watch(promoBannersProvider);

    return bannersAsyncValue.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey.shade300,
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error, color: Colors.grey));
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => SizedBox(
        height: 180,
        child: Center(child: Text('Failed to load banners')),
      ),
    );
  }
}
