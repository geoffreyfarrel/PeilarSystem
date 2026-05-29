import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle.dart';

class FeatureDetailPage extends ConsumerStatefulWidget {
  final String featureId;
  final Map<String, dynamic>? data;

  const FeatureDetailPage({
    super.key,
    required this.featureId,
    this.data,
  });

  @override
  ConsumerState<FeatureDetailPage> createState() => _FeatureDetailPageState();
}

class _FeatureDetailPageState extends ConsumerState<FeatureDetailPage> {
  static const Color ahhBlue = Color(0xFF3D4EB0);
  static const Color ahhLightBlue = Color(0xFFE2E5F4);
  static const Color ahhBackground = Color(0xFFF8F8F8);
  static const Color ahhText = Color(0xFF111111);
  static const Color ahhGrey = Color(0xFF6E6F79);
  static const Color peilarGreen = Color(0xFF515F49);

  Duration laundryCountdown = const Duration(minutes: 23, seconds: 45);
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
    final subtitle = widget.data?['subtitle'] as String? ?? fallbackSubtitle(text);
    final icon = widget.data?['icon'] as IconData? ?? Icons.widgets_rounded;
    final studentOnly = widget.data?['studentOnly'] as bool? ?? false;

    if (widget.featureId == 'laundry-hub') {
      return _AhhMobileScaffold(
        title: title,
        centerTitle: true,
        trailing: const LanguageToggle(),
        onBack: () => context.go('/'),
        child: _LaundryHubAhhFlow(
          language: language,
          countdownText: formatDuration(laundryCountdown),
          countdownFinished: laundryCountdown.inSeconds <= 0,
        ),
      );
    }

    if (widget.featureId == 'digital-easycard') {
      return _AhhMobileScaffold(
        title: title,
        centerTitle: true,
        trailing: const LanguageToggle(),
        onBack: () => context.go('/'),
        child: _DigitalEasyCardAhhStudio(language: language),
      );
    }

    if (widget.featureId == 'secondhand-books') {
      return _AhhMobileScaffold(
        title: title,
        centerTitle: true,
        trailing: const LanguageToggle(),
        onBack: () => context.go('/'),
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
                    onPressed: () => context.go('/'),
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
                  _FeatureHero(
                    title: title,
                    subtitle: subtitle,
                    icon: icon,
                  ),
                  if (studentOnly) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.verified_user,
                      title: text['studentOnlyTitle'] ?? 'Student ID Required',
                      subtitle: text['studentOnlyDesc'] ??
                          'This feature unlocks after Student ID verification.',
                      color: const Color(0xFF4EA3E7),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.touch_app,
                    title: text['clickableDemo'] ?? 'Clickable Demo',
                    subtitle: text['clickableDemoDesc'] ??
                        'This page is a working placeholder for the selected module.',
                    color: const Color(0xFF79926C),
                  ),
                  if (widget.featureId == 'travel-hub' ||
                      widget.featureId == 'tourism-loop' ||
                      widget.featureId == 'bebe-travel') ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.travel_explore,
                      title: text['tourismLoopTitle'] ?? 'Sanxia Tourism Loop',
                      subtitle: text['tourismLoopDesc'] ??
                          'AI recommends local food, heritage sites, and hiking trails.',
                      color: Colors.orange,
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
    if (widget.featureId == 'student-area') return text['studentArea'] ?? 'Student Area';
    if (widget.featureId == 'tts') return text['tts'] ?? 'TTS Support';
    if (widget.featureId == 'tourism-loop') return text['tourismLoop'] ?? 'Tourism Loop';
    if (widget.featureId == 'laundry-hub') return text['laundryHub'] ?? 'Laundry Hub';
    if (widget.featureId == 'digital-easycard') return text['digitalEasyCard'] ?? 'Digital EasyCard';
    if (widget.featureId == 'secondhand-books') return text['secondhandBooks'] ?? 'Student Market';
    return text['feature'] ?? 'Feature';
  }

  String fallbackSubtitle(Map<String, String> text) {
    if (widget.featureId == 'laundry-hub') {
      return text['laundryHubDesc'] ?? 'Laundry countdown, free machines, QR booking, and reminders.';
    }
    if (widget.featureId == 'digital-easycard') {
      return text['digitalEasyCardDesc'] ?? 'Customize your digital card with artist and university collections.';
    }
    if (widget.featureId == 'secondhand-books') {
      return text['secondhandBooksDesc'] ??
          'Verified student marketplace for books, clothes, furniture, and dorm life.';
    }
    return text['featureSubtitle'] ?? 'This module is prepared as a clickable prototype.';
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
                      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 48, child: trailing ?? const SizedBox.shrink()),
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

class _FakeStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 32, right: 18, top: 8),
      child: const Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          Icon(Icons.signal_cellular_alt, size: 17),
          SizedBox(width: 6),
          Icon(Icons.wifi, size: 17),
          SizedBox(width: 6),
          Icon(Icons.battery_full, size: 19),
        ],
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
  final bool soft;
  final IconData? icon;

  const _AhhPrimaryButton({
    required this.label,
    required this.onPressed,
    this.soft = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = soft ? const Color(0xFF3D4EB0) : Colors.white;
    final background = soft ? const Color(0xFFE2E5F4) : const Color(0xFF3D4EB0);

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: soft ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
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
              color: Color(0xFF6E6F79),
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
              color: const Color(0xFFE2E5F4),
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
                const Icon(Icons.local_laundry_service, size: 92, color: Color(0xFF3D4EB0)),
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
          _AhhPrimaryButton(label: isZh ? '開始使用' : 'Get Started', onPressed: onStart),
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
      child: Icon(icon, color: const Color(0xFF3D4EB0), size: 26),
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
              color: Color(0xFF6E6F79),
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
                            color: const Color(0xFF3D4EB0),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.local_laundry_service, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              const Icon(Icons.location_on_outlined, color: Colors.black, size: 24),
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
                color: Color(0xFF6E6F79),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AhhPrimaryButton(label: isZh ? '確認地點' : 'Confirm location', onPressed: onConfirm),
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
        color: const Color(0xFF3D4EB0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFFE2E5F4), size: 24),
          const SizedBox(width: 8),
          Text(
            hint,
            style: const TextStyle(
              color: Color(0xFFE2E5F4),
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

  const _SavedLocationCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3D4EB0), size: 24),
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
                    color: Color(0xFF6E6F79),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6E6F79)),
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
    final green = Paint()..color = const Color(0xFFC9DDC0).withValues(alpha: 0.65);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFE2E2E2));
    canvas.drawCircle(Offset(size.width * .18, size.height * .22), 70, green);
    canvas.drawCircle(Offset(size.width * .82, size.height * .74), 88, green);
    canvas.drawLine(Offset(-20, size.height * .24), Offset(size.width + 20, size.height * .58), road);
    canvas.drawLine(Offset(size.width * .18, -20), Offset(size.width * .68, size.height + 20), road);
    canvas.drawLine(Offset(-20, size.height * .78), Offset(size.width + 20, size.height * .32), minorRoad);
    canvas.drawLine(Offset(size.width * .75, -20), Offset(size.width * .26, size.height + 20), minorRoad);
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
                  _StatusChip(icon: Icons.check_circle_outline, label: isZh ? '營業中' : 'Open'),
                  const SizedBox(width: 18),
                  Container(width: 1, height: 22, color: const Color(0xFF6E6F79)),
                  const SizedBox(width: 18),
                  _StatusChip(icon: Icons.local_laundry_service, label: isZh ? '11 台可用' : '11 machines available'),
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
                onTap: machine.available ? () => onMachineTap(machine.number) : null,
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
          child: Icon(icon, color: const Color(0xFF3D4EB0), size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E6F79),
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

  const _MachineCard({required this.machine, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF3D4EB0) : const Color(0xFFF8F8F8);
    final textColor = selected ? Colors.white : Colors.black;
    final detailColor = selected ? const Color(0xFFF8F3EA) : const Color(0xFF6E6F79);

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
    final dotColor = const Color(0xFF3D4EB0);
    return Container(
      width: 31.18,
      height: 33.37,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5F4),
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
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
        color: const Color(0xFF3D4EB0),
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
                padding: const EdgeInsets.symmetric(horizontal: 13.13, vertical: 8.75),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(109.41),
                ),
                child: Row(
                  children: [
                    Icon(
                      items[index].icon,
                      color: selected ? const Color(0xFF3D4EB0) : Colors.white,
                      size: 24,
                    ),
                    if (selected) ...[
                      const SizedBox(width: 7),
                      Text(
                        items[index].label,
                        style: const TextStyle(
                          color: Color(0xFF3D4EB0),
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
              color: Color(0xFF6E6F79),
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
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(165, 165), painter: _QrMockPainter()),
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
              color: Color(0xFF6E6F79),
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
                  color: const Color(0xFF3D4EB0),
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
      const Offset(0, 0), const Offset(1, 0), const Offset(2, 0), const Offset(4, 0), const Offset(8, 0), const Offset(9, 0), const Offset(10, 0),
      const Offset(0, 1), const Offset(2, 1), const Offset(5, 1), const Offset(8, 1), const Offset(10, 1),
      const Offset(0, 2), const Offset(1, 2), const Offset(2, 2), const Offset(6, 2), const Offset(8, 2), const Offset(9, 2), const Offset(10, 2),
      const Offset(3, 3), const Offset(5, 3), const Offset(7, 3),
      const Offset(1, 4), const Offset(4, 4), const Offset(5, 4), const Offset(9, 4),
      const Offset(0, 5), const Offset(2, 5), const Offset(6, 5), const Offset(7, 5), const Offset(10, 5),
      const Offset(3, 6), const Offset(4, 6), const Offset(8, 6),
      const Offset(0, 8), const Offset(1, 8), const Offset(2, 8), const Offset(5, 8), const Offset(8, 8), const Offset(9, 8), const Offset(10, 8),
      const Offset(0, 9), const Offset(2, 9), const Offset(6, 9), const Offset(8, 9), const Offset(10, 9),
      const Offset(0, 10), const Offset(1, 10), const Offset(2, 10), const Offset(4, 10), const Offset(7, 10), const Offset(8, 10), const Offset(9, 10), const Offset(10, 10),
    ];
    for (final offset in filled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx * cell, offset.dy * cell, cell * .82, cell * .82),
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
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF6E6F79)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E5F4).withValues(alpha: 0.4),
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
        _AhhPrimaryButton(label: isZh ? '前往付款' : 'Proceed to pay', onPressed: onNext),
        const SizedBox(height: 58),
        Center(
          child: Container(
            width: 146,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5F4).withValues(alpha: 0.4),
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF3D4EB0)),
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
                    color: Color(0xFF6E6F79),
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
              color: outlined ? Colors.white : const Color(0xFFE2E5F4),
              borderRadius: BorderRadius.circular(8),
              border: outlined ? Border.all(color: const Color(0xFFE2E5F4)) : null,
            ),
            child: Icon(icon, color: const Color(0xFF3D4EB0)),
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
                    color: Color(0xFF6E6F79),
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
              color: Color(0xFF3D4EB0),
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
              color: Color(0xFF6E6F79),
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
                    color: const Color(0xFF3D4EB0),
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
                        color: Color(0xFF6E6F79),
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
            trailing: const Icon(Icons.notifications_active, color: Color(0xFF3D4EB0)),
          ),
          const Spacer(),
          _AhhPrimaryButton(label: isZh ? '建立新訂單' : 'Place New order', onPressed: onNewOrder),
        ],
      ),
    );
  }
}

class _DigitalEasyCardAhhStudio extends StatefulWidget {
  final AppLanguage language;

  const _DigitalEasyCardAhhStudio({required this.language});

  @override
  State<_DigitalEasyCardAhhStudio> createState() => _DigitalEasyCardAhhStudioState();
}

class _DigitalEasyCardAhhStudioState extends State<_DigitalEasyCardAhhStudio> {
  int selectedTab = 0;
  int selectedDesign = 0;

  bool get isZh => widget.language == AppLanguage.zh;

  @override
  Widget build(BuildContext context) {
    final tabs = isZh ? ['藝術家', '大學', '限定'] : ['Artists', 'University', 'Limited'];
    final designs = [
      _CardDesign('NTPU 2026', isZh ? '北大年度款' : 'University yearly design', const [Color(0xFF1E293B), Color(0xFF3D4EB0)], Icons.school, true),
      _CardDesign('Sanxia Ink', isZh ? '台灣藝術家合作' : 'Taiwan artist collab', const [Color(0xFF141414), Color(0xFFE52D88)], Icons.brush, false),
      _CardDesign('Cherry Rail', isZh ? '期間限定' : 'Limited release', const [Color(0xFF7C2D12), Color(0xFFFFED69)], Icons.confirmation_number, true),
      _CardDesign('Dorm Life', isZh ? '宿舍生活款' : 'Campus dorm series', const [Color(0xFF065F46), Color(0xFF53A657)], Icons.apartment, false),
    ];
    final current = designs[selectedDesign];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
      children: [
        Text(
          isZh ? '像 UT 一樣選擇你的卡面' : 'Choose your card face like UT collections',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6E6F79),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 22),
        _EasyCardPreview(design: current, isZh: isZh),
        const SizedBox(height: 22),
        Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedTab == index;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => selectedTab = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 44,
                  margin: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF3D4EB0) : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF6E6F79),
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
          itemCount: designs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            return _EasyCardDesignTile(
              design: designs[index],
              selected: selectedDesign == index,
              onTap: () => setState(() => selectedDesign = index),
            );
          },
        ),
        const SizedBox(height: 20),
        _AhhPrimaryButton(label: isZh ? '套用卡面' : 'Apply design', icon: Icons.nfc, onPressed: () {}),
      ],
    );
  }
}

class _CardDesign {
  final String name;
  final String subtitle;
  final List<Color> colors;
  final IconData icon;
  final bool limited;

  const _CardDesign(this.name, this.subtitle, this.colors, this.icon, this.limited);
}

class _EasyCardPreview extends StatelessWidget {
  final _CardDesign design;
  final bool isZh;

  const _EasyCardPreview({required this.design, required this.isZh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
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
              _MiniActionPill(icon: Icons.qr_code, label: 'QR'),
              const SizedBox(width: 8),
              _MiniActionPill(icon: Icons.nfc, label: 'NFC'),
              const SizedBox(width: 8),
              _MiniActionPill(icon: Icons.download_done, label: isZh ? '已選擇' : 'Selected'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniActionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3D4EB0), size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3D4EB0),
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

class _EasyCardDesignTile extends StatelessWidget {
  final _CardDesign design;
  final bool selected;
  final VoidCallback onTap;

  const _EasyCardDesignTile({required this.design, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2E5F4) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF3D4EB0) : Colors.transparent, width: 1.2),
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
                  const Icon(Icons.lock_clock, color: Color(0xFFE52D88), size: 16),
              ],
            ),
            Text(
              design.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6E6F79),
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
      _MarketListing('Calculus 12e', isZh ? '微積分課本，八成新' : 'Textbook, good condition', 'NT\$ 380', Icons.menu_book),
      _MarketListing('Dorm Desk Lamp', isZh ? '宿舍檯燈，可面交' : 'Desk lamp, campus pickup', 'NT\$ 150', Icons.lightbulb),
      _MarketListing('IKEA Chair', isZh ? '椅子，宿舍可用' : 'Chair for dorm room', 'NT\$ 420', Icons.chair),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
      children: [
        _AhhSearchBar(hint: isZh ? '搜尋課本、宿舍用品...' : 'Search books, dorm items...'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E5F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D4EB0),
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
                      isZh ? '需綁定學生證，建議校內面交。' : 'Student ID required. Campus pickup recommended.',
                      style: const TextStyle(
                        color: Color(0xFF6E6F79),
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
                color: Color(0xFF3D4EB0),
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
        _AhhPrimaryButton(label: isZh ? '刊登物品' : 'Post an item', icon: Icons.add, onPressed: () {}),
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
          color: selected ? const Color(0xFFE2E5F4) : Colors.white,
          border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFDADADA))),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF3D4EB0) : const Color(0xFF363636), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF3D4EB0) : const Color(0xFF363636),
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6E6F79), size: 18),
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(listing.icon, color: const Color(0xFF3D4EB0)),
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
                    color: Color(0xFF6E6F79),
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
              color: Color(0xFF3D4EB0),
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
          colors: [Color(0xFF515F49), Color(0xFF79926C)],
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
            child: Icon(icon, color: const Color(0xFF515F49), size: 42),
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
