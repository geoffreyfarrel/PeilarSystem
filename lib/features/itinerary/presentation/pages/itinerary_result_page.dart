import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';

class ItineraryResultPage extends ConsumerWidget {
  const ItineraryResultPage({super.key});

  static const Color darkGreen = Color(0xFF515F49);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);
    final language = ref.watch(languageProvider);

    final stops = language == AppLanguage.zh
        ? const [
            ['09:30', '三峽老街', '散步、拍照、品嚐在地小吃'],
            ['11:00', '清水祖師廟', '欣賞歷史建築與文化故事'],
            ['12:30', '在地午餐', '推薦金牛角、豆花、傳統小吃'],
            ['14:00', '鳶山步道', '輕鬆健行，俯瞰三峽景色'],
            ['16:30', '返回 NTPU / 捷運站', '搭乘公車或 YouBike 接駁'],
          ]
        : const [
            ['09:30', 'Sanxia Old Street', 'Walk, take photos, and try local snacks'],
            ['11:00', 'Zushi Temple', 'Explore historic architecture and culture'],
            ['12:30', 'Local Lunch', 'Try croissants, tofu pudding, and street food'],
            ['14:00', 'Yuan Shan Trail', 'Light hiking with a Sanxia city view'],
            ['16:30', 'Back to NTPU / MRT', 'Use shuttle, bus, or YouBike connection'],
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/ai-itinerary'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      text['resultTitle'] ?? 'Sanxia One-Day AI Itinerary',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                text['resultSubtitle'] ??
                    'A recommended plan based on your choices',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: stops.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final stop = stops[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? const Color(0xFFF2F6EF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFDDE7D7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: darkGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            stop[0],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop[1],
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stop[2],
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 26),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    text['backHome'] ?? 'Back Home',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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