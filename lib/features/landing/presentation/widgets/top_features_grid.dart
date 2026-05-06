import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/landing_providers.dart';
import '../../domain/entities/feature_item.dart';

class TopFeaturesGrid extends ConsumerWidget {
  final void Function(FeatureItem) onFeatureTap;

  const TopFeaturesGrid({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topFeaturesAsync = ref.watch(topFeaturesProvider);

    return topFeaturesAsync.when(
      data: (features) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: features.take(4).map((feature) {
              return InkWell(
                onTap: () => onFeatureTap(feature),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          feature.iconData,
                          size: 32,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature.title,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const Center(child: Text('Error loading features')),
    );
  }
}
