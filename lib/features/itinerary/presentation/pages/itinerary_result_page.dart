import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../domain/entities/itinerary_result.dart';
import '../providers/itinerary_provider.dart';

class ItineraryResultPage extends ConsumerWidget {
  const ItineraryResultPage({super.key});

  static const Color _darkGreen = Color(0xFF515F49);

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
              CircularProgressIndicator(color: _darkGreen),
              SizedBox(height: 16),
              Text(
                'Generating your itinerary...',
                style: TextStyle(color: _darkGreen, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        error: (e, _) => _ErrorView(
          text: text,
          onRetry: () => context.go('/ai-itinerary'),
        ),
        data: (result) => result != null
            ? _ResultView(result: result, text: text)
            : _ErrorView(text: text, onRetry: () => context.go('/ai-itinerary')),
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
  static const Color _darkGreen = Color(0xFF515F49);
  static const String _mapStyle =
      'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json';

  MapLibreMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destination = ref.watch(itineraryDestinationProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: _darkGreen),
                  onPressed: () => context.go('/ai-itinerary'),
                ),
                Expanded(
                  child: Text(
                    widget.result.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _darkGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
            child: Text(
              widget.text['resultSubtitle'] ??
                  'A recommended plan based on your choices',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          // Map canvas
          if (destination != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      MapLibreMap(
                        styleString: _mapStyle,
                        initialCameraPosition: CameraPosition(
                          target: destination,
                          zoom: 13,
                        ),
                        onMapCreated: (ctrl) => _mapController = ctrl,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        compassEnabled: false,
                        myLocationEnabled: false,
                      ),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Color(0xFF515F49),
                              size: 36,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Stops
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              itemCount: widget.result.stops.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _StopCard(
                stop: widget.result.stops[i],
                isFirst: i == 0,
              ),
            ),
          ),

          // Tips
          if (widget.result.tips != null && widget.result.tips!.isNotEmpty)
            _TipsCard(tips: widget.result.tips!, text: widget.text),

          // Back home
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  widget.text['backHome'] ?? 'Back Home',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final ItineraryStop stop;
  final bool isFirst;

  const _StopCard({required this.stop, required this.isFirst});

  static const Color _darkGreen = Color(0xFF515F49);
  static const Color _lightGreen = Color(0xFFF2F6EF);
  static const Color _border = Color(0xFFDDE7D7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? _lightGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: _darkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stop.time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.place,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.activity,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
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

class _TipsCard extends StatelessWidget {
  final String tips;
  final Map<String, String> text;

  const _TipsCard({required this.tips, required this.text});

  static const Color _darkGreen = Color(0xFF515F49);
  static const Color _lightGreen = Color(0xFFF2F6EF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _lightGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE7D7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: _darkGreen, size: 16),
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
            const SizedBox(height: 6),
            Text(
              tips,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
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
              Icon(Icons.error_outline,
                  color: Colors.red.shade300, size: 52),
              const SizedBox(height: 16),
              Text(
                text['generationError'] ??
                    'Failed to generate itinerary. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF515F49),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(text['tryAgain'] ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF515F49),
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
