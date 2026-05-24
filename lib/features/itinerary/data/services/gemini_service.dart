import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/itinerary_request.dart';
import '../../domain/entities/itinerary_result.dart';

class GeminiService {
  static const String _apiBase =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<ItineraryResult> generateItinerary(
    ItineraryRequest request,
    String language,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model =
        dotenv.env['NEXT_PUBLIC_GEMINI_MODEL'] ?? 'gemini-2.5-flash';

    final response = await http.post(
      Uri.parse('$_apiBase/$model:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _buildPrompt(request, language)}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.7,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Gemini');
    }

    final text =
        candidates[0]['content']['parts'][0]['text'] as String;
    final jsonResult = jsonDecode(text) as Map<String, dynamic>;
    return ItineraryResult.fromJson(jsonResult);
  }

  String _buildPrompt(ItineraryRequest request, String language) {
    final lang =
        language == 'zh' ? 'Traditional Chinese (繁體中文)' : 'English';
    final interests = request.interests.isNotEmpty
        ? request.interests.join(', ')
        : 'general sightseeing';
    final dateStr =
        '${request.date.year}-${request.date.month.toString().padLeft(2, '0')}-${request.date.day.toString().padLeft(2, '0')}';
    const budgetMap = {
      'under1k': 'Under NT\$1,000',
      '1k3k': 'NT\$1,000–3,000',
      '3k5k': 'NT\$3,000–5,000',
      'over5k': 'Over NT\$5,000',
    };
    final budgetStr = budgetMap[request.budget] ?? request.budget;

    return '''
You are an expert travel planner for Taiwan. Generate a detailed one-day travel itinerary.

Trip Details:
- Destination: ${request.location}
- Date: $dateStr
- Travel Companion: ${request.travelWith}
- Interests: $interests
- Budget: $budgetStr per person

Respond ONLY in $lang with exactly this JSON structure:
{
  "title": "Descriptive trip title",
  "stops": [
    {
      "time": "HH:MM",
      "place": "Specific place name",
      "activity": "What to do there (1-2 sentences)"
    }
  ],
  "tips": "2-3 practical travel tips for this trip"
}

Requirements:
- Include 5-7 stops from morning to evening
- Stops must be real, specific places in or near ${request.location}
- Include meal stops at appropriate times
- Match interests: $interests
- Keep recommendations within budget: $budgetStr
''';
  }
}
