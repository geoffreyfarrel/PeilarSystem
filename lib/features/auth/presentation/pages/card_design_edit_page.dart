import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../providers/student_auth_provider.dart';

class CardDesign {
  final String name;
  final List<Color> colors;
  final IconData icon;
  final bool limited;

  const CardDesign({
    required this.name,
    required this.colors,
    required this.icon,
    required this.limited,
  });
}

const List<CardDesign> kCardDesigns = [
  CardDesign(name: 'NTPU 2026', colors: [Color(0xFF2F2929), Color(0xFF0079BF)], icon: Icons.school, limited: true),
  CardDesign(name: 'Sanxia Ink', colors: [Color(0xFF2F2929), Color(0xFFC6006E)], icon: Icons.brush, limited: false),
  CardDesign(name: 'Cherry Rail', colors: [Color(0xFFC6006E), Color(0xFFEDA944)], icon: Icons.confirmation_number, limited: true),
  CardDesign(name: 'Dorm Life', colors: [Color(0xFF0E9A33), Color(0xFF0079BF)], icon: Icons.apartment, limited: false),
];

List<String> _designSubtitles(bool isZh) => [
  isZh ? '北大年度款' : 'University yearly design',
  isZh ? '台灣藝術家合作' : 'Taiwan artist collab',
  isZh ? '期間限定' : 'Limited release',
  isZh ? '宿舍生活款' : 'Campus dorm series',
];

class CardDesignEditPage extends ConsumerStatefulWidget {
  const CardDesignEditPage({super.key});

  @override
  ConsumerState<CardDesignEditPage> createState() => _CardDesignEditPageState();
}

class _CardDesignEditPageState extends ConsumerState<CardDesignEditPage> {
  static const Color _blue = Color(0xFF0079BF);
  static const Color _grey = Color(0xFF646363);

  int _selectedTab = 0;
  late int _localDesign;

  @override
  void initState() {
    super.initState();
    _localDesign = ref.read(selectedCardDesignProvider);
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final language = ref.watch(languageProvider);
    final isZh = language == AppLanguage.zh;
    final tabs = isZh ? ['藝術家', '大學', '限定'] : ['Artists', 'University', 'Limited'];
    final subtitles = _designSubtitles(isZh);
    final current = kCardDesigns[_localDesign];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _IconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                  Expanded(
                    child: Text(
                      text['editCardDesign'] ?? 'Edit Card Design',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2F2929),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48, child: LanguageToggle()),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
                children: [
                  Text(
                    isZh ? '像 UT 一樣選擇你的卡面' : 'Choose your card face like UT collections',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _grey,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _CardPreview(design: current, isZh: isZh),
                  const SizedBox(height: 22),
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final selected = _selectedTab == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = index),
                          child: Container(
                            height: 44,
                            margin: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? _blue : const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: selected ? Colors.white : _grey,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isZh ? '卡面收藏' : 'Card Collections',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kCardDesigns.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      return _DesignTile(
                        design: kCardDesigns[index],
                        subtitle: subtitles[index],
                        selected: _localDesign == index,
                        onTap: () => setState(() => _localDesign = index),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(selectedCardDesignProvider.notifier).state = _localDesign;
                        context.pop();
                      },
                      icon: const Icon(Icons.nfc, size: 20),
                      label: Text(
                        isZh ? '套用卡面' : 'Apply design',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final CardDesign design;
  final bool isZh;

  const _CardPreview({required this.design, required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: design.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: design.colors.last.withValues(alpha: 0.24),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(design.icon, size: 84, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  const Positioned(
                    left: 0,
                    top: 0,
                    child: Text(
                      'EasyCard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 28,
                    child: Text(
                      design.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text(
                      isZh ? '數位悠遊卡・學生版' : 'Digital EasyCard · Student Edition',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (design.limited)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isZh ? '限定' : 'LIMITED',
                          style: TextStyle(
                            color: design.colors.last,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniPill(icon: Icons.qr_code, label: 'QR'),
              const SizedBox(width: 8),
              _MiniPill(icon: Icons.nfc, label: 'NFC'),
              const SizedBox(width: 8),
              _MiniPill(icon: Icons.download_done, label: isZh ? '已選擇' : 'Selected'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0079BF), size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0079BF),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesignTile extends StatelessWidget {
  final CardDesign design;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _DesignTile({
    required this.design,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2FB) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0079BF) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: design.colors),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(design.icon, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    design.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (design.limited)
                  const Icon(Icons.lock_clock, color: Color(0xFFC6006E), size: 16),
              ],
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF646363),
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
