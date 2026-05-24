class ItineraryRequest {
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final String travelWith;
  final List<String> interests;
  final String budget;

  const ItineraryRequest({
    required this.location,
    this.latitude,
    this.longitude,
    required this.date,
    required this.travelWith,
    required this.interests,
    required this.budget,
  });
}
