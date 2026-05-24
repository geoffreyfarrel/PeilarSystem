class ItineraryStop {
  final String time;
  final String place;
  final String activity;

  const ItineraryStop({
    required this.time,
    required this.place,
    required this.activity,
  });

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    return ItineraryStop(
      time: json['time'] as String? ?? '',
      place: json['place'] as String? ?? '',
      activity: json['activity'] as String? ?? '',
    );
  }
}

class ItineraryResult {
  final String title;
  final List<ItineraryStop> stops;
  final String? tips;

  const ItineraryResult({
    required this.title,
    required this.stops,
    this.tips,
  });

  factory ItineraryResult.fromJson(Map<String, dynamic> json) {
    final stopsJson = json['stops'] as List<dynamic>? ?? [];
    return ItineraryResult(
      title: json['title'] as String? ?? 'Itinerary',
      stops: stopsJson
          .map((s) => ItineraryStop.fromJson(s as Map<String, dynamic>))
          .toList(),
      tips: json['tips'] as String?,
    );
  }
}
