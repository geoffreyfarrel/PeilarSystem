import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../../domain/entities/itinerary_result.dart';
import '../providers/itinerary_provider.dart';

class ItineraryResultPage extends ConsumerWidget {
  const ItineraryResultPage({super.key});

  static const Color _green = Color(0xFF0E9A33);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);
    final state = ref.watch(itineraryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: state.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _green),
              SizedBox(height: 16),
              Text(
                'Generating your itinerary...',
                style: TextStyle(color: _green, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) =>
            _ErrorView(text: text, onRetry: () => context.go('/ai-itinerary')),
        data: (result) => result != null
            ? _ResultView(result: result, text: text)
            : _ErrorView(
                text: text,
                onRetry: () => context.go('/ai-itinerary'),
              ),
      ),
    );
  }
}

class _ResultView extends ConsumerStatefulWidget {
  final ItineraryResult result;
  final Map<String, String> text;

  const _ResultView({required this.result, required this.text});

  @override
  ConsumerState<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<_ResultView> {

  @override
  Widget build(BuildContext context) {
    final destination = ref.watch(itineraryDestinationProvider);
    final tips = widget.result.tips;

    return Column(
      children: [
        _ResultHeader(
          title: widget.result.title,
          onBack: () => context.go('/ai-itinerary'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              const _StepProgress(current: 3),
              const SizedBox(height: 22),
              _RouteMapCard(
                destination: destination,
                text: widget.text,
              ),
              const SizedBox(height: 18),
              const _SavingsBanner(),
              const SizedBox(height: 18),
              ...widget.result.stops.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StopCard(stop: entry.value, index: entry.key),
                ),
              ),
              if (tips != null && tips.isNotEmpty) ...[
                const SizedBox(height: 4),
                _TipsCard(tips: tips, text: widget.text),
              ],
              const SizedBox(height: 18),
              _PrimaryResultButton(
                label: widget.text['saveItinerary'] ?? 'Save Itinerary',
                icon: Icons.bookmark_border,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              _OutlineResultButton(
                label: widget.text['backHome'] ?? 'Back Home',
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ResultHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 12,
        18,
        18,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const LanguageToggle(darkMode: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int current;

  const _StepProgress({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final active = step == current;
        final done = step < current;
        final stepColor = const [
          Color(0xFFC6006E),
          Color(0xFF0079BF),
          Color(0xFF0E9A33),
        ][index];
        return Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: active || done ? stepColor : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active || done ? stepColor : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: active || done ? Colors.white : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            if (step < 3)
              Container(
                width: 36,
                height: 3,
                color: done ? const Color(0xFFEDA944) : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}

class _RouteMapCard extends StatelessWidget {
  final LatLng? destination;
  final Map<String, String> text;

  const _RouteMapCard({
    required this.destination,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final target = destination ?? const LatLng(24.9421, 121.3702);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 190,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: target,
                initialZoom: 12.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.peilar.superapp',
                ),
              ],
            ),
            Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
            const Positioned(left: 118, top: 74, child: _NumberPin(number: 1)),
            const Positioned(left: 218, top: 36, child: _NumberPin(number: 2)),
            const Positioned(right: 118, top: 82, child: _NumberPin(number: 3)),
            Positioned(
              right: 16,
              bottom: 14,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(text['viewFullMap'] ?? 'View full map'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF181A20),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0E9A33)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.30, size.height * 0.58)
      ..lineTo(size.width * 0.52, size.height * 0.34)
      ..lineTo(size.width * 0.72, size.height * 0.60);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NumberPin extends StatelessWidget {
  final int number;

  const _NumberPin({required this.number});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const Icon(Icons.location_pin, color: Color(0xFF0E9A33), size: 48),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavingsBanner extends StatelessWidget {
  const _SavingsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB9D8FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7E7FF)),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFF0079BF),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text.rich(
                  TextSpan(
                    text: 'Estimated savings ',
                    children: [
                      TextSpan(
                        text: 'NT\$165',
                        style: TextStyle(color: Color(0xFF0079BF)),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: Color(0xFF181A20),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: const [
                    _SavingsChip(label: 'Student ticket'),
                    _SavingsChip(label: 'EasyCard bus transfer'),
                    _SavingsChip(label: 'Partner discount'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsChip extends StatelessWidget {
  final String label;

  const _SavingsChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFB9D8FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0079BF), size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF181A20),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final ItineraryStop stop;
  final int index;

  const _StopCard({required this.stop, required this.index});

  @override
  Widget build(BuildContext context) {
    final tags = [
      'Snack deal',
      'Student discount available',
      'Student admission',
    ];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StopThumbnail(stop: stop, index: index),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F5EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stop.time,
                        style: const TextStyle(
                          color: Color(0xFF0E9A33),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stop.place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF181A20),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  stop.activity,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F5EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_mall_outlined,
                        color: Color(0xFF0E9A33),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tags[index % tags.length],
                        style: const TextStyle(
                          color: Color(0xFF0E9A33),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StopThumbnail extends StatelessWidget {
  final ItineraryStop stop;
  final int index;

  const _StopThumbnail({required this.stop, required this.index});

  @override
  Widget build(BuildContext context) {
    final imageUrls = ItineraryImageResolver.urlsFor(
      place: stop.place,
      activity: stop.activity,
      primaryUrl: stop.imageUrl,
    );
    if (imageUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 112,
          height: 112,
          child: _FallbackScene(index: index),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 112,
        height: 112,
        color: const Color(0xFFF1F1F1),
        child: _NetworkStopImage(urls: imageUrls, fallbackIndex: index),
      ),
    );
  }
}

class _NetworkStopImage extends StatefulWidget {
  final List<String> urls;
  final int fallbackIndex;

  const _NetworkStopImage({required this.urls, required this.fallbackIndex});

  @override
  State<_NetworkStopImage> createState() => _NetworkStopImageState();
}

class _NetworkStopImageState extends State<_NetworkStopImage> {
  int _urlIndex = 0;

  @override
  void didUpdateWidget(covariant _NetworkStopImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.urls.join('|') != widget.urls.join('|')) {
      _urlIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_urlIndex >= widget.urls.length) {
      return _FallbackScene(index: widget.fallbackIndex);
    }

    return Image.network(
      widget.urls[_urlIndex],
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _urlIndex < widget.urls.length) {
            setState(() => _urlIndex += 1);
          }
        });
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _FallbackScene extends StatelessWidget {
  final int index;

  const _FallbackScene({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      (const Color(0xFFB55642), const Color(0xFFFFD9C8), Icons.storefront),
      (const Color(0xFFC98218), const Color(0xFFFFE8B8), Icons.temple_buddhist),
      (const Color(0xFF4D7FA3), const Color(0xFFD8EDFF), Icons.museum),
    ];
    final item = colors[index % colors.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.$2, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _ScenePainter(color: item.$1, index: index),
        child: Center(child: Icon(item.$3, color: item.$1, size: 56)),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Color color;
  final int index;

  const _ScenePainter({required this.color, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.66, size.width, size.height * 0.34),
      paint,
    );
    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.12 + i * 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * (0.18 + (i % 2) * 0.08), 18, 62),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.index != index;
}

class _TipsCard extends StatelessWidget {
  final String tips;
  final Map<String, String> text;

  const _TipsCard({required this.tips, required this.text});

  static const Color _darkGreen = Color(0xFF0E9A33);
  static const Color _lightGreen = Color(0xFFE5F5EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: _darkGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                text['travelTips'] ?? 'Travel Tips',
                style: const TextStyle(
                  color: _darkGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tips,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryResultButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryResultButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineResultButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineResultButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0079BF),
          side: const BorderSide(color: Color(0xFF0079BF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Map<String, String> text;
  final VoidCallback onRetry;

  const _ErrorView({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFC6006E),
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                text['generationError'] ??
                    'Failed to generate itinerary. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0E9A33),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(text['tryAgain'] ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9A33),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
