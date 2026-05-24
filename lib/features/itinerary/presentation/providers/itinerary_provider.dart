import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../data/services/gemini_service.dart';
import '../../domain/entities/itinerary_request.dart';
import '../../domain/entities/itinerary_result.dart';

final itineraryProvider =
    AsyncNotifierProvider<ItineraryNotifier, ItineraryResult?>(
  ItineraryNotifier.new,
);

// Stores the destination LatLng from the last generation so the result page
// can show the map without needing coordinates in ItineraryResult.
final itineraryDestinationProvider =
    NotifierProvider<ItineraryDestinationNotifier, LatLng?>(
  ItineraryDestinationNotifier.new,
);

class ItineraryDestinationNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void set(LatLng? latlng) => state = latlng;
}

class ItineraryNotifier extends AsyncNotifier<ItineraryResult?> {
  @override
  Future<ItineraryResult?> build() async => null;

  Future<void> generate(ItineraryRequest request, String language) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => GeminiService().generateItinerary(request, language),
    );
  }
}
