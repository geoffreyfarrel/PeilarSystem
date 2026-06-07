import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../digital_easycard/presentation/pages/digital_easycard_page.dart';
import '../providers/language_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/language_toggle.dart';

class FeatureDetailPage extends ConsumerStatefulWidget {
  final String featureId;
  final Map<String, dynamic>? data;

  const FeatureDetailPage({super.key, required this.featureId, this.data});

  @override
  ConsumerState<FeatureDetailPage> createState() => _FeatureDetailPageState();
}

class _FeatureDetailPageState extends ConsumerState<FeatureDetailPage> {
  static const Color ahhBlue = Color(0xFF0079BF);
  static const Color ahhLightBlue = Color(0xFFE3F2FB);
  static const Color ahhBackground = Color(0xFFF7F7F7);
  static const Color ahhText = Color(0xFF2F2929);
  static const Color ahhGrey = Color(0xFF646363);
  static const Color peilarGreen = Color(0xFF0E9A33);

  Duration laundryCountdown = const Duration(minutes: 8, seconds: 24);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || laundryCountdown.inSeconds <= 0) return;
      setState(() {
        laundryCountdown = Duration(seconds: laundryCountdown.inSeconds - 1);
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final language = ref.watch(languageProvider);

    final title = widget.data?['title'] as String? ?? fallbackTitle(text);
    final subtitle =
        widget.data?['subtitle'] as String? ?? fallbackSubtitle(text);
    final icon = widget.data?['icon'] as IconData? ?? Icons.widgets_rounded;
    final studentOnly = widget.data?['studentOnly'] as bool? ?? false;
    final returnToStudentArea =
        widget.data?['returnToStudentArea'] as bool? ?? false;
    final backLocation = returnToStudentArea ? '/feature/student-area' : '/';

    if (widget.featureId == 'laundry-hub') {
      return _ReferenceFeatureScaffold(
        title: 'Laundry',
        boundLabel: 'Student EasyCard',
        onBack: () => context.go(backLocation),
        child: _LaundryReferencePage(
          countdownText: formatDuration(laundryCountdown),
        ),
      );
    }

    if (widget.featureId == 'festivals') {
      return _ReferenceFeatureScaffold(
        title: 'Festival',
        boundLabel: 'Student EasyCard',
        onBack: () => context.go(backLocation),
        child: const _FestivalReferencePage(),
      );
    }

    if (widget.featureId == 'groceries') {
      return _ReferenceFeatureScaffold(
        title: 'Grocery',
        boundLabel: 'Student EasyCard',
        onBack: () => context.go(backLocation),
        child: const _GroceryReferencePage(),
      );
    }

    if (widget.featureId == 'split-bill') {
      return _ReferenceFeatureScaffold(
        title: text['splitBill'] ?? 'Split Bill',
        boundLabel: 'EasyCard',
        onBack: () => context.go(backLocation),
        child: _SplitBillReferencePage(language: language),
      );
    }

    if (widget.featureId == 'forum') {
      return _ReferenceFeatureScaffold(
        title: text['forum'] ?? 'Student Forum',
        boundLabel: 'Student EasyCard',
        onBack: () => context.go(backLocation),
        child: _StudentForumReferencePage(language: language),
      );
    }

    if (widget.featureId == 'student-area') {
      return _StudentAreaReferenceScaffold(
        title: text['studentArea'] ?? 'Student Area',
        onBack: () => context.go('/'),
        child: _StudentAreaReferencePage(language: language),
      );
    }

    if (widget.featureId == 'digital-easycard') {
      return DigitalEasyCardPage(
        language: language,
        onBack: () => context.go('/'),
      );
    }

    if (widget.featureId == 'secondhand-books') {
      return _AhhMobileScaffold(
        title: title,
        centerTitle: true,
        trailing: const LanguageToggle(),
        onBack: () => context.go(backLocation),
        child: _StudentMarketAhhPage(language: language),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(backLocation),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2F2929),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                children: [
                  _FeatureHero(title: title, subtitle: subtitle, icon: icon),
                  if (studentOnly) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.verified_user,
                      title: text['studentOnlyTitle'] ?? 'Student ID Required',
                      subtitle:
                          text['studentOnlyDesc'] ??
                          'This feature unlocks after Student ID verification.',
                      color: const Color(0xFF0079BF),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.touch_app,
                    title: text['clickableDemo'] ?? 'Clickable Demo',
                    subtitle:
                        text['clickableDemoDesc'] ??
                        'This page is a working placeholder for the selected module.',
                    color: const Color(0xFF0E9A33),
                  ),
                  if (widget.featureId == 'travel-hub' ||
                      widget.featureId == 'tourism-loop' ||
                      widget.featureId == 'bebe-travel') ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.travel_explore,
                      title: text['tourismLoopTitle'] ?? 'Sanxia Tourism Loop',
                      subtitle:
                          text['tourismLoopDesc'] ??
                          'AI recommends local food, heritage sites, and hiking trails.',
                      color: const Color(0xFFEDA944),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/ai-itinerary'),
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          text['openAiPlanner'] ?? 'Open AI Planner',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: peilarGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String fallbackTitle(Map<String, String> text) {
    if (widget.featureId == 'student-area') {
      return text['studentArea'] ?? 'Student Area';
    }
    if (widget.featureId == 'tts') return text['tts'] ?? 'TTS Support';
    if (widget.featureId == 'tourism-loop') {
      return text['tourismLoop'] ?? 'Tourism Loop';
    }
    if (widget.featureId == 'laundry-hub') {
      return text['laundryHub'] ?? 'Laundry Hub';
    }
    if (widget.featureId == 'digital-easycard') {
      return text['digitalEasyCard'] ?? 'Digital EasyCard';
    }
    if (widget.featureId == 'secondhand-books') {
      return text['secondhandBooks'] ?? 'Student Market';
    }
    return text['feature'] ?? 'Feature';
  }

  String fallbackSubtitle(Map<String, String> text) {
    if (widget.featureId == 'laundry-hub') {
      return text['laundryHubDesc'] ??
          'Laundry countdown, free machines, QR booking, and reminders.';
    }
    if (widget.featureId == 'digital-easycard') {
      return text['digitalEasyCardDesc'] ??
          'Customize your digital card with artist and university collections.';
    }
    if (widget.featureId == 'secondhand-books') {
      return text['secondhandBooksDesc'] ??
          'Verified student marketplace for books, clothes, furniture, and dorm life.';
    }
    return text['featureSubtitle'] ??
        'This module is prepared as a clickable prototype.';
  }
}

class _AhhMobileScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final VoidCallback onBack;
  final bool centerTitle;

  const _AhhMobileScaffold({
    required this.title,
    required this.child,
    required this.onBack,
    this.trailing,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
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
                  _AhhIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: centerTitle
                          ? TextAlign.center
                          : TextAlign.start,
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
                  SizedBox(
                    width: 48,
                    child: trailing ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _AhhIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AhhIconButton({required this.icon, required this.onTap});

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

class _AhhPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const _AhhPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D4EB0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _LaundryHubAhhFlow extends StatefulWidget {
  final AppLanguage language;
  final String countdownText;
  final bool countdownFinished;

  const _LaundryHubAhhFlow({
    required this.language,
    required this.countdownText,
    required this.countdownFinished,
  });

  @override
  State<_LaundryHubAhhFlow> createState() => _LaundryHubAhhFlowState();
}

class _LaundryHubAhhFlowState extends State<_LaundryHubAhhFlow> {
  int step = 0;
  int selectedMachine = 1;

  bool get isZh => widget.language == AppLanguage.zh;

  void next() {
    setState(() {
      step = math.min(step + 1, 5);
    });
  }

  void reset() {
    setState(() {
      step = 1;
      selectedMachine = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _LaundryWelcomeScreen(onStart: next, isZh: isZh);
      case 1:
        return _LaundryLocationScreen(onConfirm: next, isZh: isZh);
      case 2:
        return _LaundryMachineScreen(
          isZh: isZh,
          selectedMachine: selectedMachine,
          onMachineTap: (number) => setState(() => selectedMachine = number),
          onNext: next,
        );
      case 3:
        return _LaundryScanScreen(isZh: isZh, onNext: next);
      case 4:
        return _LaundryPaymentScreen(isZh: isZh, onNext: next);
      default:
        return _LaundryStartedScreen(
          isZh: isZh,
          countdownText: widget.countdownText,
          selectedMachine: selectedMachine,
          onNewOrder: reset,
        );
    }
  }
}

class _LaundryWelcomeScreen extends StatelessWidget {
  final bool isZh;
  final VoidCallback onStart;

  const _LaundryWelcomeScreen({required this.isZh, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 40, 34, 34),
      child: Column(
        children: [
          Text(
            isZh ? '歡迎使用！' : 'Welcome!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isZh ? '三步驟完成校園洗衣。' : 'Laundry experience in 3 easy steps.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF646363),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FB),
              borderRadius: BorderRadius.circular(42),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 170,
                  height: 210,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.local_laundry_service, size: 92, color: Color(0xFF0079BF)),
                Positioned(
                  right: 44,
                  top: 54,
                  child: _FloatingIconBadge(icon: Icons.qr_code_scanner),
                ),
                Positioned(
                  left: 48,
                  bottom: 58,
                  child: _FloatingIconBadge(icon: Icons.timer),
                ),
              ],
            ),
          ),
          const Spacer(),
          _AhhPrimaryButton(
            label: isZh ? '開始使用' : 'Get Started',
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _FloatingIconBadge extends StatelessWidget {
  final IconData icon;

  const _FloatingIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF0079BF), size: 26),
    );
  }
}

class _LaundryLocationScreen extends StatelessWidget {
  final bool isZh;
  final VoidCallback onConfirm;

  const _LaundryLocationScreen({required this.isZh, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 0, 34, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AhhSearchBar(hint: isZh ? '搜尋洗衣地點...' : 'Search location...'),
          const SizedBox(height: 24),
          Text(
            isZh ? '常用地點' : 'Saved locations',
            style: const TextStyle(
              color: Color(0xFF646363),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          _SavedLocationCard(
            title: isZh ? '學校宿舍' : 'Institute',
            subtitle: isZh ? '北大宿舍洗衣間 A 棟' : 'NTPU Dorm Laundry, Building A',
            icon: Icons.school,
          ),
          const SizedBox(height: 8),
          _SavedLocationCard(
            title: isZh ? '住處附近' : 'Home',
            subtitle: isZh ? '三峽北大特區洗衣店' : 'Sanxia Beida District Laundry',
            icon: Icons.home,
          ),
          const SizedBox(height: 26),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _SimpleMapPainter()),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0079BF),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_laundry_service,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            isZh ? '北大宿舍 A 棟' : 'NTPU Dorm A',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isZh ? '確認地點' : 'Confirm location',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Text(
              isZh ? '北大宿舍洗衣間 A 棟' : 'NTPU Dorm Laundry, Building A',
              style: const TextStyle(
                color: Color(0xFF646363),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AhhPrimaryButton(
            label: isZh ? '確認地點' : 'Confirm location',
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}

class _AhhSearchBar extends StatelessWidget {
  final String hint;

  const _AhhSearchBar({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0079BF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFE3F2FB), size: 24),
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(
              color: Color(0xFFE3F2FB),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLocationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SavedLocationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0079BF), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF646363),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF646363)),
        ],
      ),
    );
  }
}

class _SimpleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final minorRoad = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final green = Paint()
      ..color = const Color(0xFFC9DDC0).withValues(alpha: 0.65);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE2E2E2),
    );
    canvas.drawCircle(Offset(size.width * .18, size.height * .22), 70, green);
    canvas.drawCircle(Offset(size.width * .82, size.height * .74), 88, green);
    canvas.drawLine(
      Offset(-20, size.height * .24),
      Offset(size.width + 20, size.height * .58),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .18, -20),
      Offset(size.width * .68, size.height + 20),
      road,
    );
    canvas.drawLine(
      Offset(-20, size.height * .78),
      Offset(size.width + 20, size.height * .32),
      minorRoad,
    );
    canvas.drawLine(
      Offset(size.width * .75, -20),
      Offset(size.width * .26, size.height + 20),
      minorRoad,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LaundryMachineScreen extends StatelessWidget {
  final bool isZh;
  final int selectedMachine;
  final ValueChanged<int> onMachineTap;
  final VoidCallback onNext;

  const _LaundryMachineScreen({
    required this.isZh,
    required this.selectedMachine,
    required this.onMachineTap,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final machines = [
      _MachineSpec(1, '7 Kg', true),
      _MachineSpec(4, '7 Kg', true),
      _MachineSpec(5, '8 Kg', true),
      _MachineSpec(8, '6 Kg', true),
      _MachineSpec(9, '7 Kg', true),
      _MachineSpec(10, '8 Kg', true),
      _MachineSpec(11, '7 Kg', true),
      _MachineSpec(2, '15m left', false),
      _MachineSpec(3, '20m left', false),
      _MachineSpec(6, '35m left', false),
      _MachineSpec(7, '37m left', false),
      _MachineSpec(12, '40m left', false),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(34, 0, 34, 0),
          child: Column(
            children: [
              Row(
                children: [
                  _StatusChip(
                    icon: Icons.check_circle_outline,
                    label: isZh ? '營業中' : 'Open',
                  ),
                  const SizedBox(width: 18),
                  Container(width: 1, height: 22, color: const Color(0xFF646363)),
                  const SizedBox(width: 18),
                  _StatusChip(
                    icon: Icons.local_laundry_service,
                    label: isZh ? '11 台可用' : '11 machines available',
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isZh ? '可用洗衣機' : 'Available washing machines',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(34, 0, 34, 16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 1.02,
            ),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];
              return _MachineCard(
                machine: machine,
                selected: machine.number == selectedMachine,
                onTap: machine.available
                    ? () => onMachineTap(machine.number)
                    : null,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(34, 0, 34, 22),
          child: _AhhPrimaryButton(
            label: isZh ? '掃描機台 QR' : 'Scan machine QR',
            icon: Icons.qr_code_scanner,
            onPressed: onNext,
          ),
        ),
        _LaundryBottomNav(isZh: isZh, selectedIndex: 0),
      ],
    );
  }
}

class _MachineSpec {
  final int number;
  final String detail;
  final bool available;

  const _MachineSpec(this.number, this.detail, this.available);
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22.75,
          height: 22.75,
          decoration: BoxDecoration(
            color: const Color(0x19008000),
            borderRadius: BorderRadius.circular(4.33),
          ),
          child: Icon(icon, color: const Color(0xFF0079BF), size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF646363),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _MachineCard extends StatelessWidget {
  final _MachineSpec machine;
  final bool selected;
  final VoidCallback? onTap;

  const _MachineCard({
    required this.machine,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF0079BF) : const Color(0xFFF7F7F7);
    final textColor = selected ? Colors.white : Colors.black;
    final detailColor = selected ? const Color(0xFFFFF3DC) : const Color(0xFF646363);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.08),
      child: Opacity(
        opacity: machine.available ? 1 : 0.72,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.08),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WasherIcon(selected: selected),
              const SizedBox(height: 8),
              Text(
                'No. ${machine.number}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                machine.detail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: detailColor,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WasherIcon extends StatelessWidget {
  final bool selected;

  const _WasherIcon({required this.selected});

  @override
  Widget build(BuildContext context) {
    final dotColor = const Color(0xFF0079BF);
    return Container(
      width: 31.18,
      height: 33.37,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FB),
        borderRadius: BorderRadius.circular(41.28),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  width: 2.9,
                  height: 2.78,
                  margin: const EdgeInsets.symmetric(horizontal: 0.72),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            child: Icon(
              selected ? Icons.check : Icons.local_laundry_service,
              size: selected ? 15 : 13,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}

class _LaundryBottomNav extends StatelessWidget {
  final bool isZh;
  final int selectedIndex;

  const _LaundryBottomNav({required this.isZh, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, isZh ? '首頁' : 'Home'),
      _NavItem(Icons.history_rounded, isZh ? '紀錄' : 'Orders'),
      _NavItem(Icons.notifications_rounded, isZh ? '通知' : 'Alerts'),
      _NavItem(Icons.person_rounded, isZh ? '我的' : 'Me'),
    ];

    return Container(
      height: 112.7,
      decoration: BoxDecoration(
        color: const Color(0xFF0079BF),
        borderRadius: BorderRadius.circular(26.26),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final selected = index == selectedIndex;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13.13,
                  vertical: 8.75,
                ),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(109.41),
                ),
                child: Row(
                  children: [
                    Icon(
                      items[index].icon,
                      color: selected ? const Color(0xFF0079BF) : Colors.white,
                      size: 24,
                    ),
                    if (selected) ...[
                      const SizedBox(width: 7),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          color: Color(0xFF0079BF),
                          fontSize: 13.13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
          const Spacer(),
          Container(
            width: 147.71,
            height: 5.47,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(109.41),
            ),
          ),
          const SizedBox(height: 9),
        ],
      ),
    );
  }
}

class _LaundryScanScreen extends StatelessWidget {
  final bool isZh;
  final VoidCallback onNext;

  const _LaundryScanScreen({required this.isZh, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 0, 34, 34),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Text(
            isZh ? '掃描 QR 碼' : 'Scan QR code',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isZh ? '請掃描洗衣機上的 QR code' : 'Please scan the machine QR code',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF646363),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 86),
          Container(
            width: 245,
            height: 245,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(165, 165),
                  painter: _QrMockPainter(),
                ),
                Container(
                  width: 245,
                  height: 61,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5784E6), Color(0x00D9D9D9)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),
          Text(
            isZh ? '掃描中...' : 'Scanning code...',
            style: const TextStyle(
              color: Color(0xFF646363),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Center(
            child: InkWell(
              onTap: onNext,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0079BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QrMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cell = size.width / 11;
    final filled = <Offset>[
      const Offset(0, 0),
      const Offset(1, 0),
      const Offset(2, 0),
      const Offset(4, 0),
      const Offset(8, 0),
      const Offset(9, 0),
      const Offset(10, 0),
      const Offset(0, 1),
      const Offset(2, 1),
      const Offset(5, 1),
      const Offset(8, 1),
      const Offset(10, 1),
      const Offset(0, 2),
      const Offset(1, 2),
      const Offset(2, 2),
      const Offset(6, 2),
      const Offset(8, 2),
      const Offset(9, 2),
      const Offset(10, 2),
      const Offset(3, 3),
      const Offset(5, 3),
      const Offset(7, 3),
      const Offset(1, 4),
      const Offset(4, 4),
      const Offset(5, 4),
      const Offset(9, 4),
      const Offset(0, 5),
      const Offset(2, 5),
      const Offset(6, 5),
      const Offset(7, 5),
      const Offset(10, 5),
      const Offset(3, 6),
      const Offset(4, 6),
      const Offset(8, 6),
      const Offset(0, 8),
      const Offset(1, 8),
      const Offset(2, 8),
      const Offset(5, 8),
      const Offset(8, 8),
      const Offset(9, 8),
      const Offset(10, 8),
      const Offset(0, 9),
      const Offset(2, 9),
      const Offset(6, 9),
      const Offset(8, 9),
      const Offset(10, 9),
      const Offset(0, 10),
      const Offset(1, 10),
      const Offset(2, 10),
      const Offset(4, 10),
      const Offset(7, 10),
      const Offset(8, 10),
      const Offset(9, 10),
      const Offset(10, 10),
    ];
    for (final offset in filled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            offset.dx * cell,
            offset.dy * cell,
            cell * .82,
            cell * .82,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LaundryPaymentScreen extends StatelessWidget {
  final bool isZh;
  final VoidCallback onNext;

  const _LaundryPaymentScreen({required this.isZh, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(34, 28, 34, 34),
      children: [
        _PaymentInfoCard(
          icon: Icons.confirmation_number,
          title: isZh ? '優惠券' : 'Coupons',
          subtitle: isZh ? '目前無可用優惠券' : '0 coupons available',
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF646363)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FB).withValues(alpha: 0.4),
          ),
          child: Column(
            children: [
              _PaymentMethodCard(
                title: 'Easy Wallet',
                subtitle: 'student@ntpu.edu.tw',
                amount: 'NT\$ 35',
                icon: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),
              _PaymentMethodCard(
                title: 'EasyCard',
                subtitle: isZh ? '數位悠遊卡' : 'Digital EasyCard',
                amount: 'NT\$ 35',
                icon: Icons.credit_card,
                outlined: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _AhhPrimaryButton(
          label: isZh ? '前往付款' : 'Proceed to pay',
          onPressed: onNext,
        ),
        const SizedBox(height: 58),
        Center(
          child: Container(
            width: 146,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FB).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: Colors.black, size: 22),
                SizedBox(width: 8),
                Text(
                  '90s left',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PaymentInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0079BF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF646363),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final bool outlined;

  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: outlined ? Colors.white : const Color(0xFFE3F2FB),
              borderRadius: BorderRadius.circular(8),
              border: outlined ? Border.all(color: const Color(0xFFE3F2FB)) : null,
            ),
            child: Icon(icon, color: const Color(0xFF0079BF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF646363),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF0079BF),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LaundryStartedScreen extends StatelessWidget {
  final bool isZh;
  final String countdownText;
  final int selectedMachine;
  final VoidCallback onNewOrder;

  const _LaundryStartedScreen({
    required this.isZh,
    required this.countdownText,
    required this.selectedMachine,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 46, 34, 34),
      child: Column(
        children: [
          Text(
            isZh ? '洗衣開始！' : 'Laundry started!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isZh ? '完成時我們會通知你。' : 'We will notify when it is done!',
            style: const TextStyle(
              color: Color(0xFF646363),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 86),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 0.72,
                    strokeWidth: 18,
                    backgroundColor: const Color(0xFFF5F5F5),
                    color: const Color(0xFF0079BF),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Completed',
                      style: TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '72%',
                      style: TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      countdownText,
                      style: const TextStyle(
                        color: Color(0xFF646363),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),
          _PaymentInfoCard(
            icon: Icons.local_laundry_service,
            title: 'Machine No. $selectedMachine',
            subtitle: isZh ? '北大宿舍 A 棟' : 'NTPU Dorm A',
            trailing: const Icon(Icons.notifications_active, color: Color(0xFF0079BF)),
          ),
          const Spacer(),
          _AhhPrimaryButton(
            label: isZh ? '建立新訂單' : 'Place New order',
            onPressed: onNewOrder,
          ),
        ],
      ),
    );
  }
}

class _MarketCategory {
  final IconData icon;
  final String label;

  const _MarketCategory(this.icon, this.label);
}

class _StudentMarketAhhPage extends StatefulWidget {
  final AppLanguage language;

  const _StudentMarketAhhPage({required this.language});

  @override
  State<_StudentMarketAhhPage> createState() => _StudentMarketAhhPageState();
}

class _StudentMarketAhhPageState extends State<_StudentMarketAhhPage> {
  int selectedCategory = 0;

  bool get isZh => widget.language == AppLanguage.zh;

  @override
  Widget build(BuildContext context) {
    final categories = [
      _MarketCategory(Icons.menu_book, isZh ? '二手書' : 'Books'),
      _MarketCategory(Icons.checkroom, isZh ? '衣服' : 'Clothes'),
      _MarketCategory(Icons.chair, isZh ? '家具' : 'Furniture'),
      _MarketCategory(Icons.devices_other, isZh ? '電子用品' : 'Electronics'),
      _MarketCategory(Icons.kitchen, isZh ? '宿舍用品' : 'Dorm Items'),
      _MarketCategory(Icons.watch, isZh ? '飾品' : 'Accessories'),
      _MarketCategory(Icons.shopping_bag, isZh ? '包包' : 'Bags'),
      _MarketCategory(Icons.sports_basketball, isZh ? '運動用品' : 'Sports'),
    ];
    final listings = [
      _MarketListing(
        'Calculus 12e',
        isZh ? '微積分課本，八成新' : 'Textbook, good condition',
        'NT\$ 380',
        Icons.menu_book,
      ),
      _MarketListing(
        'Dorm Desk Lamp',
        isZh ? '宿舍檯燈，可面交' : 'Desk lamp, campus pickup',
        'NT\$ 150',
        Icons.lightbulb,
      ),
      _MarketListing(
        'IKEA Chair',
        isZh ? '椅子，宿舍可用' : 'Chair for dorm room',
        'NT\$ 420',
        Icons.chair,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
      children: [
        _AhhSearchBar(
          hint: isZh ? '搜尋課本、宿舍用品...' : 'Search books, dorm items...',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0079BF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.verified_user, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isZh ? '學生安全交易' : 'Student-safe exchange',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isZh
                          ? '需綁定學生證，建議校內面交。'
                          : 'Student ID required. Campus pickup recommended.',
                      style: const TextStyle(
                        color: Color(0xFF646363),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isZh ? '分類' : 'Categories',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDADADA)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(categories.length, (index) {
              final item = categories[index];
              return _MarketCategoryRow(
                icon: item.icon,
                label: item.label,
                selected: selectedCategory == index,
                isLast: index == categories.length - 1,
                onTap: () => setState(() => selectedCategory = index),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                isZh ? '推薦物品' : 'Recommended items',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              isZh ? '查看全部' : 'See all',
              style: const TextStyle(
                color: Color(0xFF0079BF),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...listings.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MarketListingCard(listing: listing),
          ),
        ),
        const SizedBox(height: 12),
        _AhhPrimaryButton(
          label: isZh ? '刊登物品' : 'Post an item',
          icon: Icons.add,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _MarketCategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  const _MarketCategoryRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2FB) : Colors.white,
          border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFDADADA))),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF0079BF) : const Color(0xFF2F2929), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF0079BF) : const Color(0xFF2F2929),
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF646363), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MarketListing {
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;

  const _MarketListing(this.title, this.subtitle, this.price, this.icon);
}

class _MarketListingCard extends StatelessWidget {
  final _MarketListing listing;

  const _MarketListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(listing.icon, color: const Color(0xFF0079BF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  listing.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF646363),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            listing.price,
            style: const TextStyle(
              color: Color(0xFF0079BF),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFeatureScaffold extends StatelessWidget {
  final String title;
  final String boundLabel;
  final Widget child;
  final VoidCallback onBack;

  const _ReferenceFeatureScaffold({
    required this.title,
    required this.boundLabel,
    required this.child,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 38,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 18, 0),
                      child: Row(
                        children: const [
                          Text(
                            '9:41',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.signal_cellular_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 7),
                          Icon(Icons.wifi, color: Colors.white, size: 18),
                          SizedBox(width: 7),
                          _BatteryBadge(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 72,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 18,
                          top: 11,
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 6,
                          child: _BoundCard(label: boundLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class _BatteryBadge extends StatelessWidget {
  const _BatteryBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        '100',
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BoundCard extends StatelessWidget {
  final String label;

  const _BoundCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0A84FF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Color(0xFF0A84FF), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bound:',
                  style: TextStyle(
                    color: Color(0xFF0A84FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _StudentAreaReferenceScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onBack;

  const _StudentAreaReferenceScaffold({
    required this.title,
    required this.child,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 22, 0),
                      child: Row(
                        children: const [
                          Text(
                            '17:44',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.signal_cellular_alt,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 7),
                          Icon(Icons.wifi, color: Colors.white, size: 19),
                          SizedBox(width: 7),
                          _StudentBatteryBadge(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 86,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 18,
                          top: 18,
                          child: IconButton(
                            onPressed: onBack,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 26,
                          top: 22,
                          child: IconButton(
                            onPressed: () => context.go('/qr-scanner'),
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
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

class _StudentAreaReferencePage extends StatelessWidget {
  final AppLanguage language;

  const _StudentAreaReferencePage({required this.language});

  bool get isZh => language == AppLanguage.zh;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StudentAreaItem(
        icon: Icons.menu_book_outlined,
        label: isZh ? '二手書' : 'Second-hand\nBooks',
        color: const Color(0xFFD81B60),
        background: const Color(0xFFFFEAF3),
        onTap: () =>
            context.go('/secondhand', extra: {'returnToStudentArea': true}),
      ),
      _StudentAreaItem(
        icon: Icons.local_laundry_service_outlined,
        label: isZh ? '洗衣' : 'Laundry',
        color: const Color(0xFF1473F3),
        background: const Color(0xFFEAF2FF),
        onTap: () => context.go(
          '/feature/laundry-hub',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.celebration_outlined,
        label: isZh ? '節慶活動' : 'Festival',
        color: const Color(0xFFF29900),
        background: const Color(0xFFFFF2DE),
        onTap: () => context.go(
          '/feature/festivals',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.shopping_basket_outlined,
        label: isZh ? '超商購物' : 'Groceries',
        color: const Color(0xFF12A229),
        background: const Color(0xFFEAF8ED),
        onTap: () => context.go(
          '/feature/groceries',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.fastfood_outlined,
        label: isZh ? '學生餐廳' : 'Cafeteria',
        color: const Color(0xFFD81B60),
        background: const Color(0xFFFFEAF3),
        onTap: () => context.go(
          '/feature/cafeteria',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.wallet_outlined,
        label: isZh ? '加值' : 'Top Up',
        color: const Color(0xFF1473F3),
        background: const Color(0xFFEAF2FF),
        onTap: () =>
            context.go('/feature/top-up', extra: {'returnToStudentArea': true}),
      ),
      _StudentAreaItem(
        icon: Icons.event_available_outlined,
        label: isZh ? '校園活動' : 'Campus Events',
        color: const Color(0xFFF29900),
        background: const Color(0xFFFFF2DE),
        onTap: () => context.go(
          '/feature/campus-events',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.account_balance_outlined,
        label: isZh ? '校園服務' : 'Campus Services',
        color: const Color(0xFF12A229),
        background: const Color(0xFFEAF8ED),
        onTap: () => context.go(
          '/feature/campus-services',
          extra: {'returnToStudentArea': true},
        ),
      ),
      _StudentAreaItem(
        icon: Icons.directions_bus_outlined,
        label: isZh ? '交通' : 'Transport',
        color: const Color(0xFFD81B60),
        background: const Color(0xFFFFEAF3),
        onTap: () => context.go(
          '/feature/transport',
          extra: {'returnToStudentArea': true},
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      children: [
        _StudentEasyCardPreview(isZh: isZh),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 26,
              crossAxisSpacing: 12,
              childAspectRatio: .86,
            ),
            itemBuilder: (context, index) =>
                _StudentAreaTile(item: items[index]),
          ),
        ),
      ],
    );
  }
}

class _StudentEasyCardPreview extends StatelessWidget {
  final bool isZh;

  const _StudentEasyCardPreview({required this.isZh});

  static const double _rightW = 185;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 278,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .13),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Blue gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003D86), Color(0xFF0C74C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(painter: const _CampusLinePainter()),
            ),
          ),
          // White right panel
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: _rightW,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(120)),
              ),
            ),
          ),
          // Left (blue) content — right-bounded so it never enters the white panel
          Positioned(
            left: 18,
            right: _rightW,
            top: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.school_outlined, color: Colors.white, size: 24),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isZh ? '國立大學' : 'NTPU',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'NATIONAL UNIVERSITY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xAAFFFFFF),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  isZh ? '王小明' : 'WANG,\nXIAO-MING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isZh ? 'WANG, XIAO-MING' : 'Student',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _MiniPill(label: isZh ? '學生' : 'Student', color: const Color(0xFF1976D2)),
                    _MiniPill(
                      label: isZh ? '已綁定' : 'Bound',
                      color: const Color(0xFF32B56D),
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isZh ? '學生證號' : 'Student ID',
                  style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 10),
                ),
                const SizedBox(height: 2),
                const Text(
                  'A12345678',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          // Right (white) content — fully within the white panel
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: _rightW,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 22, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.blur_circular, color: Color(0xFFE6005C), size: 36),
                      const SizedBox(width: 6),
                      Text(
                        isZh ? '悠遊卡' : 'EasyCard',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Balance (NT\$)',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        '1,250',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Color(0xFF777777), size: 22),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6005C),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isZh ? '加值' : 'Top Up',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _MiniPill({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StudentAreaItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _StudentAreaItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });
}

class _StudentAreaTile extends StatelessWidget {
  final _StudentAreaItem item;

  const _StudentAreaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 62,
            alignment: Alignment.center,
            child: Icon(item.icon, color: item.color, size: 42),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusLinePainter extends CustomPainter {
  const _CampusLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final ground = size.height - 54;
    canvas.drawRect(
      Rect.fromLTWH(size.width * .42, ground - 62, 56, 62),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * .58, ground - 86, 80, 86),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .35, ground),
      Offset(size.width * .90, ground),
      paint,
    );
    canvas.drawCircle(Offset(size.width * .68, ground - 88), 34, paint);
    canvas.drawArc(
      Rect.fromLTWH(size.width * .28, ground - 92, 56, 56),
      math.pi,
      math.pi,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .28, ground - 64),
      Offset(size.width * .36, ground - 96),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .44, ground - 64),
      Offset(size.width * .36, ground - 96),
      paint,
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * .60 + i * 18, ground - 82),
        Offset(size.width * .60 + i * 18, ground),
        paint,
      );
    }
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (.22 + i * .16), ground - 118 - i * 10),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FestivalReferencePage extends StatelessWidget {
  const _FestivalReferencePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: const [
        _FestivalHero(),
        SizedBox(height: 16),
        _StudentBenefitBanner(
          title: 'Using Your Student Benefits',
          subtitle:
              'We are using your bound Student EasyCard and EasyCard offers to find discounted festival tickets, transport, and food deals made for students like you.',
        ),
        SizedBox(height: 18),
        _ReferenceSectionHeader(
          icon: Icons.calendar_month_outlined,
          title: 'Recommended Festivals',
        ),
        SizedBox(height: 10),
        _FestivalCards(),
        SizedBox(height: 18),
        _ReferenceSectionHeader(
          icon: Icons.favorite_border_rounded,
          title: 'Student Picks',
        ),
        SizedBox(height: 10),
        _PickGrid(
          items: [
            _PickSpec(Icons.star_border_rounded, 'Best food\nfestivals'),
            _PickSpec(Icons.directions_bus_rounded, 'EasyCard\ntransport'),
            _PickSpec(Icons.confirmation_number_outlined, 'Weekend\nevents'),
            _PickSpec(Icons.apartment_rounded, 'Campus\nspecials'),
          ],
        ),
        SizedBox(height: 18),
        _ReferenceSectionHeader(
          icon: Icons.credit_card,
          title: 'Your Benefits',
          showSeeAll: false,
        ),
        SizedBox(height: 10),
        _BenefitRail(
          items: [
            _BenefitSpec(
              Icons.sell_outlined,
              'Student Discounts',
              'Up to 30% off on\nevent tickets',
            ),
            _BenefitSpec(
              Icons.directions_bus_rounded,
              'EasyCard Perks',
              'Save on transport\nand enjoy ride deals',
            ),
            _BenefitSpec(
              Icons.ramen_dining_outlined,
              'Food & Merch Deals',
              'Exclusive offers at\nfestival booths',
            ),
          ],
        ),
        SizedBox(height: 18),
        _PinkCta(label: 'View Festival Deals', icon: Icons.chevron_right),
      ],
    );
  }
}

class _FestivalHero extends StatelessWidget {
  const _FestivalHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B0D04), Color(0xFF8C4B17)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _FestivalLightsPainter())),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sanxia Festivals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Culture. Food. Fun.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Discover local festivals in Sanxia, New Taipei.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore Now',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const _HeroThumb(icon: Icons.celebration_rounded, color: Color(0xFFFF7043)),
                    const SizedBox(width: 6),
                    const _HeroThumb(icon: Icons.storefront_rounded, color: Color(0xFFFFC04D)),
                    const SizedBox(width: 6),
                    const _HeroThumb(icon: Icons.light_mode_rounded, color: Color(0xFFFF9800)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroThumb extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _HeroThumb({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _FestivalLightsPainter extends CustomPainter {
  const _FestivalLightsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (var row = 0; row < 3; row++) {
      final y = 18.0 + row * 22;
      canvas.drawLine(Offset(90, y), Offset(size.width + 24, y - 20), line);
      for (var i = 0; i < 9; i++) {
        final x = 112.0 + i * 36;
        glow.color = const Color(0xFFFFB333).withValues(alpha: 0.75);
        canvas.drawCircle(Offset(x, y - i * 2), 5, glow);
        canvas.drawCircle(
          Offset(x, y - i * 2),
          3,
          Paint()..color = const Color(0xFFFFC857),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StudentBenefitBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StudentBenefitBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB9D8FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCFE3FF)),
            ),
            child: const Icon(
              Icons.sell_outlined,
              color: Color(0xFF1473F3),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1473F3),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    height: 1.28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.wallet_outlined, color: Color(0xFF4C91F6), size: 46),
        ],
      ),
    );
  }
}

class _ReferenceSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showSeeAll;

  const _ReferenceSectionHeader({
    required this.icon,
    required this.title,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showSeeAll)
          const Text(
            'See all',
            style: TextStyle(
              color: Color(0xFFE6005C),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (showSeeAll) const SizedBox(width: 4),
        if (showSeeAll)
          const Icon(Icons.chevron_right, color: Color(0xFFE6005C), size: 22),
      ],
    );
  }
}

class _FestivalCards extends StatelessWidget {
  const _FestivalCards();

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FestivalCardSpec(
        'Sanxia Lantern Festival',
        'Feb 12 - Feb 23, 2026',
        'Sanxia Old Street',
        '15% OFF',
        Icons.light_mode_rounded,
        Color(0xFFFF9800),
      ),
      _FestivalCardSpec(
        'Qingshui祖師文化祭',
        'Apr 04 - Apr 06, 2026',
        'Qingshui Zushi Temple',
        '20% OFF',
        Icons.temple_buddhist_rounded,
        Color(0xFF009688),
      ),
      _FestivalCardSpec(
        '三峽夜市美食節',
        'May 16 - May 18, 2026',
        'Sanxia Night Market',
        '10% OFF',
        Icons.storefront_rounded,
        Color(0xFFFF7043),
      ),
    ];
    return Row(
      children: cards
          .map(
            (card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FestivalCard(card: card),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FestivalCardSpec {
  final String title;
  final String date;
  final String place;
  final String badge;
  final IconData icon;
  final Color color;

  const _FestivalCardSpec(
    this.title,
    this.date,
    this.place,
    this.badge,
    this.icon,
    this.color,
  );
}

class _FestivalCard extends StatelessWidget {
  final _FestivalCardSpec card;

  const _FestivalCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 76,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, card.color]),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6005C),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  card.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                _MetaLine(
                  icon: Icons.calendar_today_outlined,
                  label: card.date,
                ),
                const SizedBox(height: 4),
                _MetaLine(icon: Icons.location_on_outlined, label: card.place),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    _TinyPill('Student ticket', true),
                    SizedBox(width: 4),
                    _TinyPill('EasyCard accepted', false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF555555)),
          ),
        ),
      ],
    );
  }
}

class _TinyPill extends StatelessWidget {
  final String label;
  final bool pink;

  const _TinyPill(this.label, this.pink);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pink ? const Color(0xFFFFF1F6) : const Color(0xFFEFF8EE),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: pink ? const Color(0xFFFF8FBA) : const Color(0xFFB8DDB8),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: pink ? const Color(0xFFE6005C) : const Color(0xFF266B2C),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PickSpec {
  final IconData icon;
  final String label;

  const _PickSpec(this.icon, this.label);
}

class _PickGrid extends StatelessWidget {
  final List<_PickSpec> items;

  const _PickGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < items.length - 1 ? 8 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE1E1E1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: const Color(0xFFE6005C), size: 26),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BenefitSpec {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitSpec(this.icon, this.title, this.subtitle);
}

class _BenefitRail extends StatelessWidget {
  final List<_BenefitSpec> items;

  const _BenefitRail({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : const Border(left: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: const Color(0xFFE6005C), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.25,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PinkCta extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PinkCta({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE6005C),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}

class _SplitBillReferencePage extends StatefulWidget {
  final AppLanguage language;

  const _SplitBillReferencePage({required this.language});

  @override
  State<_SplitBillReferencePage> createState() =>
      _SplitBillReferencePageState();
}

class _SplitBillReferencePageState extends State<_SplitBillReferencePage> {
  static const Color pink = Color(0xFFE52D88);
  static const Color blue = Color(0xFF4EA3E7);
  static const Color green = Color(0xFF53A657);
  static const Color yellow = Color(0xFFFFED69);
  static const Color dark = Color(0xFF282828);

  final Map<String, double> shares = {
    'Ming': 0.32,
    'Yu': 0.24,
    'Chen': 0.21,
    'Lin': 0.23,
  };

  bool get isZh => widget.language == AppLanguage.zh;

  @override
  Widget build(BuildContext context) {
    final total = 3927.73;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        _SplitTotalCard(isZh: isZh, total: total, selectedCount: shares.length),
        const SizedBox(height: 18),
        _SplitSectionHeader(
          icon: Icons.people_alt_outlined,
          title: isZh ? '附近好友' : 'Nearby Friends',
          action: isZh ? '查看全部' : 'See all',
        ),
        const SizedBox(height: 10),
        _NearbyFriendRow(isZh: isZh),
        const SizedBox(height: 20),
        _SplitSectionHeader(
          icon: Icons.receipt_long_outlined,
          title: isZh ? '今日帳單' : 'Today Activity',
          action: isZh ? '明細' : 'Details',
        ),
        const SizedBox(height: 10),
        _SplitRestaurantCard(isZh: isZh),
        const SizedBox(height: 18),
        _SplitSectionHeader(
          icon: Icons.tune,
          title: isZh ? '誰要分帳' : 'Who is sharing the bill',
          action: isZh ? '新增' : 'Add',
        ),
        const SizedBox(height: 10),
        ...shares.entries.map((entry) {
          return _ShareSliderRow(
            name: entry.key,
            percent: entry.value,
            total: total,
            onChanged: (value) => setState(() => shares[entry.key] = value),
          );
        }),
        const SizedBox(height: 18),
        _SplitSummaryCard(isZh: isZh, total: total, shares: shares),
        const SizedBox(height: 18),
        _SplitPrimaryButton(label: isZh ? '送出分帳邀請' : 'Send Split Request'),
      ],
    );
  }
}

class _SplitTotalCard extends StatelessWidget {
  final bool isZh;
  final double total;
  final int selectedCount;

  const _SplitTotalCard({
    required this.isZh,
    required this.total,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isZh ? '總金額' : 'Total Bill',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'NT\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: _SplitBillReferencePageState.dark,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MiniAvatar(color: _SplitBillReferencePageState.pink),
                    _MiniAvatar(color: _SplitBillReferencePageState.blue),
                    _MiniAvatar(color: _SplitBillReferencePageState.green),
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _SplitBillReferencePageState.yellow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '+$selectedCount',
                        style: const TextStyle(
                          color: _SplitBillReferencePageState.dark,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(52),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  color: _SplitBillReferencePageState.dark,
                  size: 44,
                ),
                Positioned(
                  right: 10,
                  bottom: 14,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: _SplitBillReferencePageState.pink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
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

class _MiniAvatar extends StatelessWidget {
  final Color color;

  const _MiniAvatar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.person, color: color, size: 16),
    );
  }
}

class _SplitSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String action;

  const _SplitSectionHeader({
    required this.icon,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _SplitBillReferencePageState.dark, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: _SplitBillReferencePageState.pink,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _NearbyFriendRow extends StatelessWidget {
  final bool isZh;

  const _NearbyFriendRow({required this.isZh});

  @override
  Widget build(BuildContext context) {
    final friends = [
      ('Justin', _SplitBillReferencePageState.blue),
      ('Druid', _SplitBillReferencePageState.yellow),
      ('Fleece', _SplitBillReferencePageState.green),
      ('Ursula', _SplitBillReferencePageState.pink),
    ];
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Container(
            width: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: friend.$2.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: friend.$2.withValues(alpha: .35)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniAvatar(color: friend.$2),
                const SizedBox(height: 8),
                Text(
                  friend.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.add_circle_outline, color: friend.$2, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudentForumReferencePage extends StatefulWidget {
  final AppLanguage language;

  const _StudentForumReferencePage({required this.language});

  @override
  State<_StudentForumReferencePage> createState() =>
      _StudentForumReferencePageState();
}

class _StudentForumReferencePageState
    extends State<_StudentForumReferencePage> {
  static const Color pink = Color(0xFFE52D88);
  static const Color blue = Color(0xFF4EA3E7);
  static const Color green = Color(0xFF53A657);
  static const Color yellow = Color(0xFFFFED69);

  bool allowDm = true;
  bool showOnWall = true;
  int selectedBoard = 1;

  bool get isZh => widget.language == AppLanguage.zh;

  @override
  Widget build(BuildContext context) {
    final boards = [
      _ForumBoardSpec('NTPU', isZh ? '北大' : 'NTPU', blue, 128),
      _ForumBoardSpec('Food', isZh ? '美食' : 'Food', yellow, 86),
      _ForumBoardSpec('Chat', isZh ? '閒聊' : 'Chat', green, 214),
      _ForumBoardSpec('Mood', isZh ? '心情' : 'Mood', pink, 77),
    ];
    final topics = isZh
        ? ['#北大生活', '#三峽美食', '#選課', '#租屋', '#實習']
        : ['#NTPU life', '#Sanxia food', '#Courses', '#Housing', '#Internship'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
      children: [
        _ForumSearchBar(
          hint: isZh ? '搜尋看板、文章或話題' : 'Search boards, posts, topics',
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                isZh ? '搜尋看板' : 'Browse Boards',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _ForumIconButton(icon: Icons.edit_rounded, color: pink),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(boards.length, (index) {
          final board = boards[index];
          return _ForumBoardTile(
            board: board,
            enabled: index < 3,
            selected: selectedBoard == index,
            onTap: () => setState(() => selectedBoard = index),
            isZh: isZh,
          );
        }),
        const SizedBox(height: 18),
        _ForumComposerCard(
          isZh: isZh,
          allowDm: allowDm,
          showOnWall: showOnWall,
          onDmChanged: (value) => setState(() => allowDm = value),
          onWallChanged: (value) => setState(() => showOnWall = value),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics
              .map((topic) => _ForumTopicChip(label: topic))
              .toList(),
        ),
        const SizedBox(height: 18),
        _ForumPostCard(
          board: isZh ? '北大' : 'NTPU',
          title: isZh
              ? '有人今天也在三峽老街讀書嗎？'
              : 'Anyone studying near Sanxia Old Street today?',
          body: isZh
              ? '想找安靜的咖啡廳，悠遊卡有學生優惠更好。'
              : 'Looking for a quiet cafe, preferably with an EasyCard student deal.',
          color: blue,
          likes: 328,
        ),
        _ForumPostCard(
          board: isZh ? '美食' : 'Food',
          title: isZh ? '北大附近晚餐推薦' : 'Dinner spots near NTPU',
          body: isZh
              ? '整理幾間平價店，適合分帳和用悠遊付。'
              : 'A few affordable places that work well for split bill and EasyCard Pay.',
          color: green,
          likes: 146,
        ),
      ],
    );
  }
}

class _ForumSearchBar extends StatelessWidget {
  final String hint;

  const _ForumSearchBar({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF777777)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ForumIconButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ForumBoardSpec {
  final String iconText;
  final String name;
  final Color color;
  final int posts;

  const _ForumBoardSpec(this.iconText, this.name, this.color, this.posts);
}

class _ForumBoardTile extends StatelessWidget {
  final _ForumBoardSpec board;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;
  final bool isZh;

  const _ForumBoardTile({
    required this.board,
    required this.enabled,
    required this.selected,
    required this.onTap,
    required this.isZh,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? board.color.withValues(alpha: .08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? board.color : const Color(0xFFE4E4E4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: board.color.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: Text(
                board.iconText.substring(0, 1),
                style: TextStyle(
                  color: board.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          board.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (enabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9B9B9B),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isZh ? '開放私訊' : 'DM open',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isZh
                        ? '${board.posts} 篇文章 · 學生限定'
                        : '${board.posts} posts · verified students',
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right_rounded,
              color: selected ? board.color : const Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumComposerCard extends StatelessWidget {
  final bool isZh;
  final bool allowDm;
  final bool showOnWall;
  final ValueChanged<bool> onDmChanged;
  final ValueChanged<bool> onWallChanged;

  const _ForumComposerCard({
    required this.isZh,
    required this.allowDm,
    required this.showOnWall,
    required this.onDmChanged,
    required this.onWallChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isZh ? '發文設定' : 'Post Settings',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _StudentForumReferencePageState.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isZh ? '發布' : 'Publish',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ForumSwitchRow(
            title: isZh ? '接受私訊' : 'Allow direct messages',
            subtitle: isZh ? '綁定學生身份文章限定' : 'Student identity verified posts',
            value: allowDm,
            onChanged: onDmChanged,
            color: _StudentForumReferencePageState.blue,
          ),
          _ForumSwitchRow(
            title: isZh ? '顯示於個人牆' : 'Show on profile wall',
            subtitle: isZh ? '開啟後仍可在個人牆隱藏文章' : 'You can still hide it later',
            value: showOnWall,
            onChanged: onWallChanged,
            color: _StudentForumReferencePageState.green,
          ),
        ],
      ),
    );
  }
}

class _ForumSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _ForumSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }
}

class _ForumTopicChip extends StatelessWidget {
  final String label;

  const _ForumTopicChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  final String board;
  final String title;
  final String body;
  final Color color;
  final int likes;

  const _ForumPostCard({
    required this.board,
    required this.title,
    required this.body,
    required this.color,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school_rounded, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                board,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Color(0xFF777777)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border, color: color, size: 19),
              const SizedBox(width: 5),
              Text(
                '$likes',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF777777),
                size: 18,
              ),
              const SizedBox(width: 5),
              const Text('24', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitRestaurantCard extends StatelessWidget {
  final bool isZh;

  const _SplitRestaurantCard({required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: _SplitBillReferencePageState.yellow.withValues(alpha: .32),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.ramen_dining_rounded,
              color: _SplitBillReferencePageState.pink,
              size: 42,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isZh ? '三峽老街聚餐' : 'Sanxia Dinner',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isZh ? '金牛角、飲料與小吃分帳' : 'Pastry, drinks, and snacks',
                  style: const TextStyle(color: Color(0xFF666666)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'NT\$3,927.73',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF999999)),
        ],
      ),
    );
  }
}

class _ShareSliderRow extends StatelessWidget {
  final String name;
  final double percent;
  final double total;
  final ValueChanged<double> onChanged;

  const _ShareSliderRow({
    required this.name,
    required this.percent,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final amount = total * percent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          _MiniAvatar(color: _SplitBillReferencePageState.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'NT\$${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    activeTrackColor: _SplitBillReferencePageState.pink,
                    inactiveTrackColor: const Color(0xFFEDEDED),
                    thumbColor: _SplitBillReferencePageState.yellow,
                  ),
                  child: Slider(
                    min: .05,
                    max: .65,
                    value: percent,
                    onChanged: onChanged,
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

class _SplitSummaryCard extends StatelessWidget {
  final bool isZh;
  final double total;
  final Map<String, double> shares;

  const _SplitSummaryCard({
    required this.isZh,
    required this.total,
    required this.shares,
  });

  @override
  Widget build(BuildContext context) {
    final average = total / shares.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _SplitBillReferencePageState.blue.withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.credit_card_rounded,
            color: _SplitBillReferencePageState.blue,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isZh
                  ? '每人平均約 NT\$${average.toStringAsFixed(0)}，可用悠遊付送出請款。'
                  : 'Average NT\$${average.toStringAsFixed(0)} each. Send requests with EasyCard Pay.',
              style: const TextStyle(
                color: _SplitBillReferencePageState.dark,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitPrimaryButton extends StatelessWidget {
  final String label;

  const _SplitPrimaryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _SplitBillReferencePageState.pink,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _SplitBillReferencePageState.pink.withValues(alpha: .26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.send_rounded, color: Colors.white, size: 21),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LaundryReferencePage extends StatelessWidget {
  final String countdownText;

  const _LaundryReferencePage({required this.countdownText});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: [
        const _LaundryLocationCard(),
        const SizedBox(height: 16),
        _LaundryTimerCard(countdownText: countdownText),
        const SizedBox(height: 14),
        const _ReferenceSectionHeader(
          icon: Icons.local_laundry_service_outlined,
          title: 'Machines',
        ),
        const SizedBox(height: 10),
        _LaundryMachineGrid(countdownText: countdownText),
        const SizedBox(height: 18),
        const _ReferenceSectionHeader(
          icon: Icons.credit_card,
          title: 'Pay & Start',
          showSeeAll: false,
        ),
        const SizedBox(height: 10),
        const _PaymentSplitCard(),
        const SizedBox(height: 16),
        const _LaundryEffortlessBanner(),
        const SizedBox(height: 16),
        const _PinkCta(
          label: 'Set Reminder & Pay',
          icon: Icons.notifications_none_rounded,
        ),
      ],
    );
  }
}

class _LaundryLocationCard extends StatelessWidget {
  const _LaundryLocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Row(
        children: const [
          Icon(Icons.location_on_outlined, color: Color(0xFF126AEF), size: 42),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NTPU Dorm Laundry Room A',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  '2 machines free  •  1 finishing soon',
                  style: TextStyle(fontSize: 15, color: Color(0xFF444444)),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 28),
        ],
      ),
    );
  }
}

class _LaundryTimerCard extends StatelessWidget {
  final String countdownText;

  const _LaundryTimerCard({required this.countdownText});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDE0FF)),
      ),
      child: Row(
        children: [
          const _LaundryWasherBadge(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Washing machine 03',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const _StatusPill(
                      label: 'In use',
                      color: Color(0xFFE6005C),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      countdownText,
                      style: const TextStyle(
                        color: Color(0xFFE6005C),
                        fontSize: 34,
                        height: .95,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'left',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: .72,
                    minHeight: 7,
                    backgroundColor: Color(0xFFDDEAFF),
                    color: Color(0xFFE6005C),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF1473F3),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Reminder before cycle ends',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444444),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFFE6005C),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LaundryWasherBadge extends StatelessWidget {
  const _LaundryWasherBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCDE0FF)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1473F3), width: 2),
            ),
          ),
          Positioned(
            top: 29,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1473F3), width: 2),
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF1473F3),
                size: 14,
              ),
            ),
          ),
          const Positioned(
            top: 22,
            child: Icon(Icons.more_horiz, color: Color(0xFF1473F3), size: 22),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LaundryMachineGrid extends StatelessWidget {
  final String countdownText;

  const _LaundryMachineGrid({required this.countdownText});

  @override
  Widget build(BuildContext context) {
    final machines = [
      _LaundryMachineSpec('01', 'Washer', 'Free', 'Available', Colors.green),
      _LaundryMachineSpec('02', 'Washer', 'Free', 'Available', Colors.green),
      _LaundryMachineSpec(
        '03',
        'Washer',
        'In use',
        '$countdownText remaining',
        const Color(0xFFE6005C),
      ),
      _LaundryMachineSpec(
        '04',
        'Dryer',
        'Finishing soon',
        '03:12 remaining',
        Colors.orange,
      ),
      _LaundryMachineSpec(
        '05',
        'Washer',
        'In use',
        '15:47 remaining',
        const Color(0xFFE6005C),
      ),
      _LaundryMachineSpec('06', 'Dryer', 'Free', 'Available', Colors.green),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: machines.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) =>
          _LaundryMachineTile(spec: machines[index]),
    );
  }
}

class _LaundryMachineSpec {
  final String number;
  final String type;
  final String status;
  final String detail;
  final Color color;

  const _LaundryMachineSpec(
    this.number,
    this.type,
    this.status,
    this.detail,
    this.color,
  );
}

class _LaundryMachineTile extends StatelessWidget {
  final _LaundryMachineSpec spec;

  const _LaundryMachineTile({required this.spec});

  @override
  Widget build(BuildContext context) {
    final selected = spec.status != 'Free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? spec.color.withValues(alpha: .04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? spec.color.withValues(alpha: .65)
              : const Color(0xFFE1E1E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            spec.type == 'Dryer'
                ? Icons.dry_cleaning_outlined
                : Icons.local_laundry_service_outlined,
            color: spec.color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            spec.number,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          Text(spec.type, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 3),
          _StatusPill(label: spec.status, color: spec.color),
          const SizedBox(height: 3),
          Text(
            spec.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: Color(0xFF444444)),
          ),
        ],
      ),
    );
  }
}

class _PaymentSplitCard extends StatelessWidget {
  const _PaymentSplitCard();

  @override
  Widget build(BuildContext context) {
    return _BenefitRail(
      items: const [
        _BenefitSpec(
          Icons.wallet_outlined,
          'Pay with EasyCard',
          'Tap your EasyCard\nto the reader.',
        ),
        _BenefitSpec(
          Icons.qr_code,
          'Pay with QR Code',
          'Scan once\nto start machine.',
        ),
      ],
    );
  }
}

class _LaundryEffortlessBanner extends StatelessWidget {
  const _LaundryEffortlessBanner();

  @override
  Widget build(BuildContext context) {
    return const _StudentBenefitBanner(
      title: 'Laundry made effortless',
      subtitle:
          'No need to recheck every time. Live availability updates. Reminders before your laundry ends.',
    );
  }
}

class _GroceryReferencePage extends StatelessWidget {
  const _GroceryReferencePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: const [
        _StudentBenefitBanner(
          title: 'Using Your Student Benefits',
          subtitle:
              'We highlight convenience-store and drugstore promotions you can enjoy when paying with EasyCard. Look for these deals and save more every day.',
        ),
        SizedBox(height: 22),
        _ReferenceSectionHeader(
          icon: Icons.sell_outlined,
          title: 'Featured Promotions',
        ),
        SizedBox(height: 10),
        _GroceryPromoCards(),
        SizedBox(height: 20),
        _ReferenceSectionHeader(
          icon: Icons.location_on_outlined,
          title: 'Best Near You',
        ),
        SizedBox(height: 10),
        _PickGrid(
          items: [
            _PickSpec(Icons.local_cafe_outlined, 'Drinks\nCool drinks\n& more'),
            _PickSpec(Icons.cookie_outlined, 'Snacks\nChips, cookies\n& more'),
            _PickSpec(
              Icons.soap_outlined,
              'Toiletries\nDaily care\nessentials',
            ),
            _PickSpec(
              Icons.ramen_dining_outlined,
              'Instant Meals\nQuick & easy\nmeals',
            ),
          ],
        ),
        SizedBox(height: 20),
        _ReferenceSectionHeader(
          icon: Icons.credit_card,
          title: 'Pay & Save',
          showSeeAll: false,
        ),
        SizedBox(height: 10),
        _BenefitRail(
          items: [
            _BenefitSpec(
              Icons.contactless_outlined,
              'EasyCard Pay',
              'Tap to pay and enjoy\nexclusive promotions.',
            ),
            _BenefitSpec(
              Icons.qr_code,
              'QR Coupon',
              'Scan to unlock coupons\nat checkout.',
            ),
            _BenefitSpec(
              Icons.school_outlined,
              'Student Special',
              'More student-only\ndeals, every day.',
            ),
          ],
        ),
        SizedBox(height: 18),
        _PinkCta(label: 'View Grocery Deals', icon: Icons.chevron_right),
      ],
    );
  }
}

class _GroceryPromoCards extends StatelessWidget {
  const _GroceryPromoCards();

  @override
  Widget build(BuildContext context) {
    final promos = [
      _GroceryPromoSpec(
        '7-Eleven',
        'Buy 1 Get 1 on selected drinks',
        '買一送一 / Buy 1 Get 1',
        Icons.local_cafe_outlined,
        Color(0xFFDFF6E5),
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=500&q=80',
      ),
      _GroceryPromoSpec(
        'FamilyMart',
        'Extra 10% off with EasyCard',
        'EasyCard extra 10% off',
        Icons.fastfood_outlined,
        Color(0xFFDDEEFF),
        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=500&q=80',
      ),
      _GroceryPromoSpec(
        'Cosmed',
        'Member + EasyCard combo',
        'Member + EasyCard combo',
        Icons.spa_outlined,
        Color(0xFFFFECD8),
        'https://images.unsplash.com/photo-1556228578-8c89e6adf883?auto=format&fit=crop&w=500&q=80',
      ),
    ];
    return Row(
      children: promos
          .map(
            (promo) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _GroceryPromoCard(promo: promo),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GroceryPromoSpec {
  final String store;
  final String subtitle;
  final String deal;
  final IconData icon;
  final Color color;
  final String imageUrl;

  const _GroceryPromoSpec(
    this.store,
    this.subtitle,
    this.deal,
    this.icon,
    this.color,
    this.imageUrl,
  );
}

class _GroceryPromoCard extends StatelessWidget {
  final _GroceryPromoSpec promo;

  const _GroceryPromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 252,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            promo.store,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            promo.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: promo.color,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                promo.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    promo.icon,
                    color: const Color(0xFFE6005C),
                    size: 54,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6005C)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sell_outlined,
                  color: Color(0xFFE6005C),
                  size: 15,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    promo.deal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE6005C),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Valid until May 31, 2026',
              style: TextStyle(color: Color(0xFF666666), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _FeatureHero({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E9A33), Color(0xFF0E9A33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0E9A33), size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
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
  }
}
