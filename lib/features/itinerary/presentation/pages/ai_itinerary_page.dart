import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../widgets/itinerary_step_indicator.dart';

class AiItineraryPage extends ConsumerStatefulWidget {
  const AiItineraryPage({super.key});

  @override
  ConsumerState<AiItineraryPage> createState() => _AiItineraryPageState();
}

class _AiItineraryPageState extends ConsumerState<AiItineraryPage> {
  static const Color darkGreen = Color(0xFF515F49);
  static const Color green = Color(0xFF79926C);

  final TextEditingController destinationController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  int step = 0;
  DateTime selectedDate = DateTime(2026, 6, 20);
  String travelWith = 'friends';
  final Set<String> selectedInterests = {'historic', 'food'};

  late final List<_SanxiaPhoto> photos;

  @override
  void initState() {
    super.initState();

    photos = List<_SanxiaPhoto>.from(_sanxiaPhotos);
    photos.shuffle(Random());
  }

  @override
  void dispose() {
    destinationController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  void next() {
    if (step < 4) {
      setState(() => step++);
    } else {
      context.go('/itinerary-result');
    }
  }

  void back() {
    if (step == 0) {
      context.go('/');
    } else {
      setState(() => step--);
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );

    if (date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final photo = photos[step % photos.length];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _HeroHeader(
            title: text['aiTitle'] ?? 'AI Itinerary',
            subtitle: text['aiSubtitle'] ?? 'Plan your Sanxia trip with AI assistance',
            photo: photo,
            onBack: back,
          ),
          const SizedBox(height: 24),
          ItineraryStepIndicator(currentStep: step),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: buildStep(text),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
            child: SizedBox(
              width: 160,
              height: 49,
              child: ElevatedButton(
                onPressed: next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  step == 4 ? text['submit'] ?? 'Submit' : text['next'] ?? 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStep(Map<String, String> text) {
    if (step == 0) {
      return _QuestionBlock(
        key: const ValueKey('step1'),
        question: text['whereGo'] ?? 'Where do you want to go?',
        child: _InputBox(
          controller: destinationController,
          hintText: text['wherePlaceholder'] ?? 'e.g. Sanxia Old Street',
          icon: Icons.place_outlined,
        ),
      );
    }

    if (step == 1) {
      return _QuestionBlock(
        key: const ValueKey('step2'),
        question: text['whenGo'] ?? 'When do you plan to go?',
        child: GestureDetector(
          onTap: pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: green),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: green),
                const SizedBox(width: 12),
                Text(
                  '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (step == 2) {
      return _QuestionBlock(
        key: const ValueKey('step3'),
        question: text['whoGo'] ?? 'Who is going with you?',
        child: Column(
          children: [
            _ChoiceButton(
              label: text['solo'] ?? 'Solo',
              selected: travelWith == 'solo',
              icon: Icons.person,
              onTap: () => setState(() => travelWith = 'solo'),
            ),
            const SizedBox(height: 12),
            _ChoiceButton(
              label: text['friends'] ?? 'Friends',
              selected: travelWith == 'friends',
              icon: Icons.group,
              onTap: () => setState(() => travelWith = 'friends'),
            ),
            const SizedBox(height: 12),
            _ChoiceButton(
              label: text['family'] ?? 'Family',
              selected: travelWith == 'family',
              icon: Icons.family_restroom,
              onTap: () => setState(() => travelWith = 'family'),
            ),
          ],
        ),
      );
    }

    if (step == 3) {
      final options = [
        _InterestOption('historic', text['historic'] ?? 'Historic Landmarks', Icons.account_balance),
        _InterestOption('food', text['food'] ?? 'Delicious Foods', Icons.restaurant),
        _InterestOption('art', text['art'] ?? 'Art Galleries', Icons.palette),
        _InterestOption('hiking', text['hiking'] ?? 'Hiking', Icons.hiking),
        _InterestOption('shopping', text['shopping'] ?? 'Shopping', Icons.shopping_bag),
        _InterestOption('mustSee', text['mustSee'] ?? 'Must-see Attractions', Icons.star),
      ];

      return _QuestionBlock(
        key: const ValueKey('step4'),
        question: text['interests'] ?? 'What are you interested in?',
        subtitle: text['chooseAll'] ?? '*Choose all that apply',
        child: Column(
          children: options.map((item) {
            final selected = selectedInterests.contains(item.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InterestTile(
                label: item.label,
                icon: item.icon,
                selected: selected,
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedInterests.remove(item.id);
                    } else {
                      selectedInterests.add(item.id);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      );
    }

    return _QuestionBlock(
      key: const ValueKey('step5'),
      question: text['budget'] ?? 'What is your estimated budget?',
      child: _InputBox(
        controller: budgetController,
        hintText: text['budgetHint'] ?? 'e.g. 5000, numbers only',
        icon: Icons.payments_outlined,
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _SanxiaPhoto {
  final String name;
  final String url;

  const _SanxiaPhoto({
    required this.name,
    required this.url,
  });
}

const List<_SanxiaPhoto> _sanxiaPhotos = [
  _SanxiaPhoto(
    name: 'Sanxia Old Street',
    url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Sanxia%20Old%20Street.jpg?width=1200',
  ),
  _SanxiaPhoto(
    name: 'Sanxia Zushi Temple',
    url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Sanxia%20Zushi%20Temple.jpg?width=1200',
  ),
  _SanxiaPhoto(
    name: 'Manyueyuan Forest Recreation Area',
    url: 'https://commons.wikimedia.org/wiki/Special:FilePath/%E6%BB%BF%E6%9C%88%E5%9C%93%E6%A3%AE%E6%9E%97%E9%81%8A%E6%A8%82%E5%8D%80%20Manyueyuan%20Forest%20Recreation%20Area%20-%20panoramio%20%282%29.jpg?width=1200',
  ),
  _SanxiaPhoto(
    name: 'New Taipei City Hakka Museum',
    url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Hakka%20Museum%20%E5%AE%A2%E5%AE%B6%E5%8D%9A%E7%89%A9%E9%A4%A8%20-%20panoramio.jpg?width=1200',
  ),
  _SanxiaPhoto(
    name: 'Yuan Shan Weir',
    url: 'https://commons.wikimedia.org/wiki/Special:FilePath/Yuan%20Shan%20Weir.jpg?width=1200',
  ),
];

class _InterestOption {
  final String id;
  final String label;
  final IconData icon;

  const _InterestOption(this.id, this.label, this.icon);
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final _SanxiaPhoto photo;
  final VoidCallback onBack;

  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.photo,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFF515F49),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photo.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3F4D38), Color(0xFF79926C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          Container(color: Colors.black.withValues(alpha: 0.42)),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 18,
                  child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Positioned(
                  top: 22,
                  right: 18,
                  child: LanguageToggle(darkMode: true),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            photo.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _QuestionBlock extends StatelessWidget {
  final String question;
  final String? subtitle;
  final Widget child;

  const _QuestionBlock({
    super.key,
    required this.question,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF515F49),
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.24,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 30),
        child,
      ],
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InputBox({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 286,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF79926C)),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF79926C)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF515F49), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF515F49) : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF79926C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 288,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF79926C)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: fg, size: 22),
          ],
        ),
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _InterestTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF515F49) : const Color(0xFF79926C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 288,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2F6EF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: color,
            ),
            const SizedBox(width: 14),
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}