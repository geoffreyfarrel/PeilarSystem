import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

class LanguageToggle extends ConsumerWidget {
  final bool darkMode;

  const LanguageToggle({
    super.key,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: darkMode ? Colors.white.withValues(alpha: 0.18) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            label: '繁中',
            selected: language == AppLanguage.zh,
            darkMode: darkMode,
            onTap: () {
              ref.read(languageProvider.notifier).state = AppLanguage.zh;
            },
          ),
          _ToggleItem(
            label: 'EN',
            selected: language == AppLanguage.en,
            darkMode: darkMode,
            onTap: () {
              ref.read(languageProvider.notifier).state = AppLanguage.en;
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool selected;
  final bool darkMode;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.selected,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = darkMode ? Colors.white : const Color(0xFF2F2929);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0079BF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : selectedColor.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}