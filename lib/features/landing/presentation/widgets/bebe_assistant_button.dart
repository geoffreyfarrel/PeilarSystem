import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';

class BebeAssistantButton extends ConsumerStatefulWidget {
  const BebeAssistantButton({super.key});

  @override
  ConsumerState<BebeAssistantButton> createState() =>
      _BebeAssistantButtonState();
}

class _BebeAssistantButtonState extends ConsumerState<BebeAssistantButton> {
  bool showHelp = false;
  bool showOptions = false;
  Timer? timer;

  void handleTap() {
    setState(() {
      showHelp = true;
      showOptions = false;
    });

    timer?.cancel();
    timer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        showOptions = true;
      });
    });
  }

  void openFeature(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    context.go(
      '/feature/$id',
      extra: {
        'title': title,
        'subtitle': subtitle,
        'icon': icon,
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);

    return Positioned(
      right: 18,
      bottom: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showHelp)
            _Bubble(
              text: text['bebeHelp'] ?? 'How may I help you?',
              onTap: null,
            ),
          if (showOptions) ...[
            _Bubble(
              text: text['travelHelp'] ?? 'Need help with travel plan?',
              onTap: () => context.go('/ai-itinerary'),
            ),
            _Bubble(
              text: text['ttsHelp'] ?? 'Need TTS assistance?',
              onTap: () => openFeature(
                context,
                id: 'tts',
                title: text['tts'] ?? 'Text-to-Speech',
                subtitle: text['ttsDemoDesc'] ??
                    'Example voice output: Shuttle arrives in 4 minutes.',
                icon: Icons.volume_up,
              ),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: handleTap,
            child: SizedBox(
              width: 86,
              height: 86,
              child: Image.asset(
                'assets/images/Bebe.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _Bubble({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clickable = onTap != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 8,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 245),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: clickable
                          ? const Color(0xFF0E9A33)
                          : const Color(0xFF2F2929),
                      fontSize: 13,
                      fontWeight: clickable ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
                if (clickable) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF0E9A33),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}