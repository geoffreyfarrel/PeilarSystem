import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../data/services/gemini_service.dart';
import '../../domain/entities/itinerary_request.dart';
import '../../domain/entities/itinerary_result.dart';

final itineraryProvider =
    AsyncNotifierProvider<ItineraryNotifier, ItineraryResult?>(
  ItineraryNotifier.new,
);

// Stores the destination from the last generation so the result page
// can show the map without needing coordinates in ItineraryResult.
final itineraryDestinationProvider =
    NotifierProvider<ItineraryDestinationNotifier, LatLng?>(
  ItineraryDestinationNotifier.new,
);

class ItineraryDestinationNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void set(LatLng? geo) => state = geo;
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
