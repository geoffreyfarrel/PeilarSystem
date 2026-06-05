class ItineraryStop {
  final String time;
  final String place;
  final String activity;
  final String? imageUrl;

  const ItineraryStop({
    required this.time,
    required this.place,
    required this.activity,
    this.imageUrl,
  });

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    final place = json['place'] as String? ?? '';
    final activity = json['activity'] as String? ?? '';
    return ItineraryStop(
      time: json['time'] as String? ?? '',
      place: place,
      activity: activity,
      imageUrl:
          ItineraryImageResolver.normalizeUrl(json['imageUrl'] as String?) ??
          ItineraryImageResolver.generatedUrlFor('$place $activity'),
    );
  }
}

class ItineraryResult {
  final String title;
  final List<ItineraryStop> stops;
  final String? tips;

  const ItineraryResult({required this.title, required this.stops, this.tips});

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

class ItineraryImageResolver {
  static List<String> urlsFor({
    required String place,
    required String activity,
    String? primaryUrl,
  }) {
    final urls = <String>[];
    final normalizedPrimary = normalizeUrl(primaryUrl);
    if (normalizedPrimary != null) {
      urls.add(normalizedPrimary);
    }

    final generated = generatedUrlFor('$place $activity');
    if (!urls.contains(generated)) {
      urls.add(generated);
    }

    final fallbackGenerated = fallbackGeneratedUrlFor('$place $activity');
    if (!urls.contains(fallbackGenerated)) {
      urls.add(fallbackGenerated);
    }

    const genericTaiwan = 'https://loremflickr.com/640/420/taiwan,travel';
    if (!urls.contains(genericTaiwan)) {
      urls.add(genericTaiwan);
    }

    return urls;
  }

  static String generatedUrlFor(String text) {
    final query = _queryFor(text.toLowerCase());
    return Uri.https('source.unsplash.com', '/640x420/', {
      'q': query,
    }).toString();
  }

  static String fallbackGeneratedUrlFor(String text) {
    final query = _queryFor(text.toLowerCase());
    return Uri.https('loremflickr.com', '/640/420/$query').toString();
  }

  static String? normalizeUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || parsed.scheme != 'https') {
      return null;
    }

    if (trimmed.startsWith('assets/') || trimmed.startsWith('asset:')) {
      return null;
    }

    return trimmed;
  }

  static String _queryFor(String text) {
    if (_hasAny(text, ['三峽老街', '三峡老街', 'sanxia old street'])) {
      return 'sanxia,old,street,taiwan';
    }
    if (_hasAny(text, ['breakfast', '早餐', 'restaurant', '餐廳', '餐厅'])) {
      return 'taiwanese,breakfast,food';
    }
    if (_hasAny(text, ['lunch', 'dinner', '午餐', '晚餐', '小吃', 'snack'])) {
      return 'taiwanese,street,food';
    }
    if (_hasAny(text, ['zushi', '祖師', '祖师', 'temple', '廟', '庙'])) {
      return 'taiwan,temple';
    }
    if (_hasAny(text, ['yingge', '鶯歌', '莺歌', 'ceramic', '陶瓷'])) {
      return 'taiwan,ceramics';
    }
    if (_hasAny(text, ['wulai', '烏來', '乌来', 'waterfall', '瀑布'])) {
      return 'taiwan,waterfall';
    }
    if (_hasAny(text, ['ximen', 'ximending', '西門', '西门'])) {
      return 'ximending,taipei';
    }
    if (_hasAny(text, ['taipei 101', '台北101', '臺北101'])) {
      return 'taipei,101';
    }
    if (_hasAny(text, ['night market', '夜市', 'raohe', '饒河', '饶河'])) {
      return 'taiwan,night,market';
    }
    if (_hasAny(text, ['university', 'ntpu', '北大', '大學', '大学'])) {
      return 'taiwan,university,campus';
    }
    return 'taiwan,travel';
  }

  static bool _hasAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
