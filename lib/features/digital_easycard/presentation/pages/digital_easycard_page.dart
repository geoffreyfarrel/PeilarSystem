import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../landing/presentation/providers/language_provider.dart';

class DigitalEasyCardPage extends StatefulWidget {
  final AppLanguage language;
  final VoidCallback onBack;

  const DigitalEasyCardPage({
    super.key,
    required this.language,
    required this.onBack,
  });

  @override
  State<DigitalEasyCardPage> createState() => _DigitalEasyCardPageState();
}

class _DigitalEasyCardPageState extends State<DigitalEasyCardPage> {
  int step = 0;
  int selectedPack = 0;
  int selectedCategory = 0;
  int selectedTool = 0;

  bool get isZh => widget.language == AppLanguage.zh;

  List<_DesignPack> get packs => const [
    _DesignPack(
      'School Spirit',
      'Show off your school pride with our mascot',
      _CardArtKind.school,
      Icons.school_outlined,
    ),
    _DesignPack(
      'City Vibes',
      'Vibrant and trendy street inspired designs',
      _CardArtKind.city,
      Icons.location_city_outlined,
    ),
    _DesignPack(
      'Cultural Heritage',
      'Celebrate local culture and traditions',
      _CardArtKind.culture,
      Icons.music_note_outlined,
    ),
  ];

  List<_DesignOption> get designs => const [
    _DesignOption('National U Mascot', _CardArtKind.school, false),
    _DesignOption('Campus Landmarks', _CardArtKind.campus, false),
    _DesignOption('Featured Artist', _CardArtKind.artist, false),
    _DesignOption('Ximen Street Pop', _CardArtKind.city, false),
    _DesignOption('Taiwan Folk Song', _CardArtKind.culture, false),
    _DesignOption('Other School Mascot', _CardArtKind.locked, true),
  ];

  void nextStep() => setState(() => step = math.min(step + 1, 3));

  void goBack() {
    if (step == 0) {
      widget.onBack();
    } else {
      setState(() => step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _CardFlowScaffold(
          title: 'Choose Design Pack',
          stepText: 'Step 1 of 4',
          onBack: goBack,
          trailingIcon: Icons.add,
          body: _ChoosePackScreen(
            packs: packs,
            selectedPack: selectedPack,
            onSelectPack: (index) => setState(() => selectedPack = index),
            onStart: nextStep,
          ),
        );
      case 1:
        return _CardFlowScaffold(
          title: 'Choose Design Pack',
          stepText: 'Step 2 of 4',
          onBack: goBack,
          trailingIcon: Icons.add,
          body: _ChooseDesignScreen(
            designs: designs,
            selectedDesign: selectedPack,
            selectedCategory: selectedCategory,
            onCategoryTap: (index) => setState(() => selectedCategory = index),
            onDesignTap: (index) => setState(() => selectedPack = index),
            onUsePack: nextStep,
          ),
        );
      case 2:
        return _MyCardScreen(
          onBack: goBack,
          onEdit: nextStep,
          onChangePack: () => setState(() => step = 1),
        );
      default:
        return _CardFlowScaffold(
          title: 'Customize Card',
          stepText: 'Step 2 of 5',
          onBack: goBack,
          trailingIcon: Icons.info_outline,
          body: _CardEditorScreen(
            selectedTool: selectedTool,
            onToolTap: (index) => setState(() => selectedTool = index),
          ),
        );
    }
  }
}

enum _CardArtKind { school, city, culture, campus, artist, locked }

class _DesignPack {
  final String title;
  final String subtitle;
  final _CardArtKind art;
  final IconData icon;

  const _DesignPack(this.title, this.subtitle, this.art, this.icon);
}

class _DesignOption {
  final String title;
  final _CardArtKind art;
  final bool locked;

  const _DesignOption(this.title, this.art, this.locked);
}

class _CardFlowScaffold extends StatelessWidget {
  final String title;
  final String stepText;
  final VoidCallback onBack;
  final IconData trailingIcon;
  final Widget body;

  const _CardFlowScaffold({
    required this.title,
    required this.stepText,
    required this.onBack,
    required this.trailingIcon,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 168,
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const _CardStatusBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 18,
                          top: 28,
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 78,
                          top: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 31,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                stepText,
                                style: const TextStyle(
                                  color: Color(0xFFBDBDBD),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 22,
                          top: 28,
                          child: Icon(
                            trailingIcon,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: const _CardBottomNav(),
    );
  }
}

class _CardStatusBar extends StatelessWidget {
  const _CardStatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 24, 0),
        child: Row(
          children: const [
            Text(
              '10:13',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.nightlight_round, color: Colors.white, size: 18),
            Spacer(),
            Icon(Icons.signal_cellular_alt, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              '4G',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            _StudentBatteryBadge(),
          ],
        ),
      ),
    );
  }
}

class _ChoosePackScreen extends StatelessWidget {
  final List<_DesignPack> packs;
  final int selectedPack;
  final ValueChanged<int> onSelectPack;
  final VoidCallback onStart;

  const _ChoosePackScreen({
    required this.packs,
    required this.selectedPack,
    required this.onSelectPack,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _BoundUniversityPill(compact: true),
          ),
          const SizedBox(height: 18),
          _StudentMascotCard(art: packs[selectedPack].art),
          const SizedBox(height: 28),
          const Text(
            'Customize Card Design',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a design pack to personalize your student card.',
            style: TextStyle(color: Color(0xFF707070), fontSize: 15),
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(packs.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == packs.length - 1 ? 0 : 10,
                  ),
                  child: _PackPreviewCard(
                    pack: packs[index],
                    selected: selectedPack == index,
                    onTap: () => onSelectPack(index),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          _CardPrimaryButton(label: 'Start Designing', onTap: onStart),
        ],
      ),
    );
  }
}

class _ChooseDesignScreen extends StatelessWidget {
  final List<_DesignOption> designs;
  final int selectedDesign;
  final int selectedCategory;
  final ValueChanged<int> onCategoryTap;
  final ValueChanged<int> onDesignTap;
  final VoidCallback onUsePack;

  const _ChooseDesignScreen({
    required this.designs,
    required this.selectedDesign,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.onDesignTap,
    required this.onUsePack,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _DesignCategory(Icons.school_outlined, 'School'),
      _DesignCategory(Icons.palette_outlined, 'Artist'),
      _DesignCategory(Icons.temple_buddhist_outlined, 'Taiwan'),
      _DesignCategory(Icons.music_note_outlined, 'Music'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Transform.translate(
            offset: const Offset(0, -28),
            child: const _BoundUniversityPill(compact: false),
          ),
          Row(
            children: List.generate(categories.length, (index) {
              final selected = selectedCategory == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == categories.length - 1 ? 0 : 10,
                  ),
                  child: InkWell(
                    onTap: () => onCategoryTap(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE6005C)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFE6005C)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            categories[index].icon,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF555555),
                            size: 20,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            categories[index].label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: designs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: .86,
            ),
            itemBuilder: (context, index) {
              final design = designs[index];
              return _DesignChoiceCard(
                design: design,
                selected: selectedDesign == index,
                onTap: () => onDesignTap(index),
              );
            },
          ),
          const SizedBox(height: 18),
          _CardPrimaryButton(label: 'Use Selected Pack', onTap: onUsePack),
        ],
      ),
    );
  }
}

class _DesignCategory {
  final IconData icon;
  final String label;

  const _DesignCategory(this.icon, this.label);
}

class _MyCardScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onChangePack;

  const _MyCardScreen({
    required this.onBack,
    required this.onEdit,
    required this.onChangePack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 172,
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const _CardStatusBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          left: 24,
                          bottom: 28,
                          child: const Text(
                            'My Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          top: 22,
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const Positioned(
                          right: 24,
                          bottom: 28,
                          child: Icon(Icons.add, color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: const _MyCardPreview(),
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: const Center(child: _ActiveDesignPill()),
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: const _CardInfoPanel(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CardOutlineButton(
                        label: 'Edit Design',
                        icon: Icons.edit_outlined,
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CardPrimaryButton(
                        label: 'Change Pack',
                        icon: Icons.sync,
                        onTap: onChangePack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'More designs you’ll love',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFFE6005C),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _MoreDesignsRail(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _CardBottomNav(),
    );
  }
}

class _CardEditorScreen extends StatelessWidget {
  final int selectedTool;
  final ValueChanged<int> onToolTap;

  const _CardEditorScreen({
    required this.selectedTool,
    required this.onToolTap,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      _DesignCategory(Icons.bubble_chart_outlined, 'Stickers'),
      _DesignCategory(Icons.text_fields, 'Text'),
      _DesignCategory(Icons.image_outlined, 'Background'),
      _DesignCategory(Icons.grid_view, 'Layout'),
    ];
    final stickers = [
      Icons.pets,
      Icons.flag,
      Icons.temple_buddhist,
      Icons.signpost,
      Icons.light_mode,
      Icons.cloud,
      Icons.local_florist,
      Icons.school,
      Icons.brush,
      Icons.star,
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          const Center(child: _PackDropdownPill()),
          const SizedBox(height: 20),
          const _EditableStudentCard(),
          const SizedBox(height: 18),
          Row(
            children: List.generate(tools.length, (index) {
              final selected = selectedTool == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == tools.length - 1 ? 0 : 9,
                  ),
                  child: InkWell(
                    onTap: () => onToolTap(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEAF4FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF9CC8F7)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tools[index].icon,
                            color: selected
                                ? const Color(0xFF1473F3)
                                : Colors.black,
                            size: 23,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            tools[index].label,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF1473F3)
                                  : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            children: stickers.map((icon) => _StickerTile(icon: icon)).toList(),
          ),
          const SizedBox(height: 16),
          const _EditorDots(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CardOutlineButton(label: 'Reset', onTap: () {}),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _CardPrimaryButton(
                  label: 'Next: Keychain',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoundUniversityPill extends StatelessWidget {
  final bool compact;

  const _BoundUniversityPill({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 38 : 62,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 28 : 40,
            height: compact ? 28 : 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: Color(0xFF1473F3),
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            compact
                ? 'Bound: National University'
                : 'Bound to National University  •  Student identity verified',
            style: TextStyle(
              color: Colors.black,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentMascotCard extends StatelessWidget {
  final _CardArtKind art;
  final bool compact;
  final bool editor;

  const _StudentMascotCard({
    required this.art,
    this.compact = false,
    this.editor = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: compact ? 1.55 : 1.72,
      child: Container(
        padding: EdgeInsets.all(compact ? 10 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 10 : 18),
          boxShadow: compact
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _CardScenePainter(art: art)),
            ),
            Positioned(
              left: compact ? 6 : 18,
              top: compact ? 6 : 16,
              child: Text(
                editor ? 'NU' : 'Alex Chen',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: compact ? 13 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!compact)
              const Positioned(
                left: 18,
                top: 48,
                child: Text(
                  'Student',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            Positioned(
              right: compact ? 10 : 34,
              top: compact ? 8 : 22,
              child: Text(
                'NU',
                style: TextStyle(
                  color: const Color(0xFF0C3568),
                  fontSize: compact ? 24 : 36,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: compact ? Alignment.center : Alignment.centerRight,
                child: _MascotFigure(size: compact ? 68 : 178),
              ),
            ),
            Positioned(
              left: compact ? 8 : 18,
              bottom: compact ? 8 : 22,
              child: Text(
                compact ? '' : 'Balance\nNT\$ 1,250',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MascotFigure extends StatelessWidget {
  final double size;

  const _MascotFigure({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * .08,
            child: Container(
              width: size * .68,
              height: size * .62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * .32),
                border: Border.all(color: const Color(0xFF0C3568), width: 2),
              ),
            ),
          ),
          Positioned(
            top: size * .13,
            child: Container(
              width: size * .58,
              height: size * .30,
              decoration: BoxDecoration(
                color: const Color(0xFF0C3568),
                borderRadius: BorderRadius.circular(size * .18),
              ),
              alignment: Alignment.center,
              child: Text(
                'NU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * .16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size * .18,
            child: Container(
              width: size * .60,
              height: size * .30,
              decoration: BoxDecoration(
                color: const Color(0xFF0C3568),
                borderRadius: BorderRadius.circular(size * .08),
              ),
              alignment: Alignment.center,
              child: Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * .22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            top: size * .42,
            left: size * .34,
            child: Container(
              width: size * .07,
              height: size * .09,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * .42,
            right: size * .34,
            child: Container(
              width: size * .07,
              height: size * .09,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * .49,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFFFB000),
              size: size * .20,
            ),
          ),
          Positioned(
            right: size * .05,
            top: size * .34,
            child: Icon(
              Icons.flag,
              color: const Color(0xFF0C62B7),
              size: size * .30,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardScenePainter extends CustomPainter {
  final _CardArtKind art;

  const _CardScenePainter({required this.art});

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0xFFCDEAFF);
    final ground = Paint()..color = const Color(0xFF8BC46A);
    canvas.drawRect(Offset.zero & size, sky);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .72, size.width, size.height * .28),
      ground,
    );

    final cloud = Paint()..color = Colors.white.withValues(alpha: .9);
    for (final offset in [
      Offset(size.width * .18, size.height * .22),
      Offset(size.width * .43, size.height * .32),
      Offset(size.width * .70, size.height * .18),
    ]) {
      canvas.drawCircle(offset, size.width * .035, cloud);
      canvas.drawCircle(
        offset + Offset(size.width * .04, 0),
        size.width * .025,
        cloud,
      );
      canvas.drawRect(Rect.fromLTWH(offset.dx - 14, offset.dy, 52, 9), cloud);
    }

    final paint = Paint()..style = PaintingStyle.fill;
    if (art == _CardArtKind.city) {
      final colors = [
        const Color(0xFFFFA726),
        const Color(0xFF1976D2),
        const Color(0xFF0D47A1),
      ];
      for (var i = 0; i < 6; i++) {
        paint.color = colors[i % colors.length];
        canvas.drawRect(
          Rect.fromLTWH(
            i * size.width / 6,
            size.height * .36,
            size.width / 7,
            size.height * .36,
          ),
          paint,
        );
      }
    } else if (art == _CardArtKind.culture) {
      paint.color = const Color(0xFF7CB342);
      final path = Path()
        ..moveTo(0, size.height * .72)
        ..quadraticBezierTo(
          size.width * .38,
          size.height * .42,
          size.width,
          size.height * .70,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
      paint.color = const Color(0xFFB56A20);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .62, size.height * .48),
          width: size.width * .18,
          height: size.height * .34,
        ),
        paint,
      );
    } else if (art == _CardArtKind.artist) {
      paint.color = const Color(0xFFF8E6D8);
      canvas.drawRect(Offset.zero & size, paint);
      for (final c in [
        const Color(0xFFE6005C),
        const Color(0xFF1473F3),
        const Color(0xFFFFED69),
      ]) {
        paint.color = c.withValues(alpha: .45);
        canvas.drawCircle(
          Offset(
            size.width *
                (.25 +
                    .25 *
                        [
                          const Color(0xFFE6005C),
                          const Color(0xFF1473F3),
                          const Color(0xFFFFED69),
                        ].indexOf(c)),
            size.height * .48,
          ),
          size.width * .10,
          paint,
        );
      }
    } else if (art == _CardArtKind.locked) {
      paint.color = const Color(0xFFE7E7E7);
      canvas.drawRect(Offset.zero & size, paint);
    } else {
      paint.color = Colors.white.withValues(alpha: .85);
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * .12,
          size.height * .42,
          size.width * .24,
          size.height * .30,
        ),
        paint,
      );
      paint.color = const Color(0xFFB65A2A);
      canvas.drawCircle(
        Offset(size.width * .24, size.height * .39),
        size.width * .035,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardScenePainter oldDelegate) =>
      oldDelegate.art != art;
}

class _PackPreviewCard extends StatelessWidget {
  final _DesignPack pack;
  final bool selected;
  final VoidCallback onTap;

  const _PackPreviewCard({
    required this.pack,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFE6005C) : const Color(0xFFE0E0E0),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                _StudentMascotCard(art: pack.art, compact: true),
                if (selected)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFE6005C),
                      child: Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              pack.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              pack.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF707070), fontSize: 11),
            ),
            const SizedBox(height: 10),
            _UnlockPill(label: selected ? 'Selected' : 'Unlocked'),
          ],
        ),
      ),
    );
  }
}

class _DesignChoiceCard extends StatelessWidget {
  final _DesignOption design;
  final bool selected;
  final VoidCallback onTap;

  const _DesignChoiceCard({
    required this.design,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: design.locked ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: design.locked ? .75 : 1,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFE6005C)
                  : const Color(0xFFE0E0E0),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  _StudentMascotCard(art: design.art, compact: true),
                  if (selected)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xFFE6005C),
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  if (design.locked)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xFF555555),
                        child: Icon(Icons.lock, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                design.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              _UnlockPill(label: design.locked ? 'Bound Only' : 'Unlocked'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnlockPill extends StatelessWidget {
  final String label;

  const _UnlockPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final bound = label == 'Bound Only';
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bound ? const Color(0xFFEAF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            bound ? Icons.account_balance : Icons.check_circle,
            color: bound ? const Color(0xFF1473F3) : const Color(0xFF11A64A),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: bound ? const Color(0xFF1473F3) : const Color(0xFF11A64A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _CardPrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE6005C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

class _CardOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _CardOutlineButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6005C)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFE6005C), size: 24),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE6005C),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyCardPreview extends StatelessWidget {
  const _MyCardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 11,
            child: _StudentMascotCard(art: _CardArtKind.school, compact: true),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Cheng Yu-Ting',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE6005C)),
                  ),
                  child: const Text(
                    'Student',
                    style: TextStyle(
                      color: Color(0xFFE6005C),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Balance (Updated just now)',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$292',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                ),
                const Divider(height: 28),
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Color(0xFFEAF4FF),
                      child: Icon(
                        Icons.account_balance,
                        color: Color(0xFF1473F3),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bound to\nNational University',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              backgroundColor: Color(0xFFF0F0F0),
              child: Icon(Icons.edit, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveDesignPill extends StatelessWidget {
  const _ActiveDesignPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF11A64A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_outline, color: Color(0xFF11A64A), size: 22),
          SizedBox(width: 8),
          Text(
            'Custom Design Active',
            style: TextStyle(
              color: Color(0xFF11A64A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfoPanel extends StatelessWidget {
  const _CardInfoPanel();

  @override
  Widget build(BuildContext context) {
    final rows = const [
      _InfoRow(
        Icons.palette_outlined,
        'Applied Pack',
        'National U Mascot Pack',
        Color(0xFFFFEAF3),
        Color(0xFFE6005C),
      ),
      _InfoRow(
        Icons.account_balance,
        'Access',
        'Bound to National University',
        Color(0xFFEAF4FF),
        Color(0xFF1473F3),
      ),
      _InfoRow(
        Icons.schedule,
        'Updated',
        'just now',
        Color(0xFFEAF8ED),
        Color(0xFF11A64A),
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: row.bg,
                      child: Icon(row.icon, color: row.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        row.label,
                        style: const TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;
  final Color color;

  const _InfoRow(this.icon, this.label, this.value, this.bg, this.color);
}

class _MoreDesignsRail extends StatelessWidget {
  const _MoreDesignsRail();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _DesignOption('Campus Life', _CardArtKind.school, false),
      _DesignOption('Taiwan Culture', _CardArtKind.culture, false),
      _DesignOption('Artist Pack', _CardArtKind.artist, false),
      _DesignOption('Adventure', _CardArtKind.city, false),
      _DesignOption('Cozy Time', _CardArtKind.locked, false),
    ];
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 86,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _StudentMascotCard(art: item.art, compact: true),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PackDropdownPill extends StatelessWidget {
  const _PackDropdownPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF777777)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.account_balance, color: Color(0xFF1473F3)),
          SizedBox(width: 12),
          Text(
            'School Spirit × Sanxia Pack',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(width: 12),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class _EditableStudentCard extends StatelessWidget {
  const _EditableStudentCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _StudentMascotCard(art: _CardArtKind.campus, editor: true),
        Positioned(top: 22, right: 142, child: _EditHandle(icon: Icons.close)),
        Positioned(top: 24, right: 70, child: _EditHandle(icon: Icons.refresh)),
        Positioned(
          top: 88,
          right: 74,
          child: _EditHandle(icon: Icons.open_in_full),
        ),
      ],
    );
  }
}

class _EditHandle extends StatelessWidget {
  final IconData icon;

  const _EditHandle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9CC8F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1473F3), size: 24),
    );
  }
}

class _StickerTile extends StatelessWidget {
  final IconData icon;

  const _StickerTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(icon, color: const Color(0xFF0C3568), size: 38),
    );
  }
}

class _EditorDots extends StatelessWidget {
  const _EditorDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF1473F3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _CardBottomNav extends StatelessWidget {
  const _CardBottomNav();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.credit_card, 'My Card'),
      _NavItem(Icons.person_rounded, 'Me'),
      _NavItem(Icons.grid_view_rounded, 'More'),
    ];
    return SafeArea(
      top: false,
      child: Container(
        height: 94,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = index == 1;
            return Expanded(
              child: InkWell(
                onTap: index == 0 ? () => context.go('/') : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[index].icon,
                      color: selected
                          ? const Color(0xFF1473F3)
                          : const Color(0xFFC8C8C8),
                      size: 31,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index].label,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF1473F3)
                            : const Color(0xFF777777),
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}

class _StudentBatteryBadge extends StatelessWidget {
  const _StudentBatteryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        '78',
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
