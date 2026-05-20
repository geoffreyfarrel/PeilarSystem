import 'dart:async';
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
  static const Color darkGreen = Color(0xFF515F49);
  static const Color green = Color(0xFF79926C);
  static const Color blue = Color(0xFF4EA3E7);

  Duration laundryCountdown = const Duration(minutes: 23, seconds: 45);
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (laundryCountdown.inSeconds <= 0) {
        return;
      }

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
    final isLaundry = widget.featureId == 'laundry-hub';

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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [darkGreen, green],
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
                          child: Icon(
                            icon,
                            color: darkGreen,
                            size: 42,
                          ),
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
                  ),

                  if (isLaundry) ...[
                    const SizedBox(height: 18),
                    _LaundryHubDemo(
                      language: language,
                      countdownText: formatDuration(laundryCountdown),
                      countdownFinished: laundryCountdown.inSeconds <= 0,
                      onNotifyTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              language == AppLanguage.zh
                                  ? '已開啟洗衣完成提醒'
                                  : 'Laundry finish reminder enabled',
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    if (studentOnly) ...[
                      const SizedBox(height: 16),
                      _InfoCard(
                        icon: Icons.school,
                        title: text['studentOnlyTitle'] ?? 'Student Area',
                        subtitle: text['studentOnlyDesc'] ??
                            'This feature is unlocked after Student ID verification.',
                        color: blue,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.touch_app,
                      title: text['clickableDemo'] ?? 'Clickable Demo',
                      subtitle: text['clickableDemoDesc'] ??
                          'This page is a working placeholder for the selected module.',
                      color: green,
                    ),
                    const SizedBox(height: 16),
                    if (widget.featureId == 'tts')
                      _InfoCard(
                        icon: Icons.volume_up,
                        title: text['ttsDemoTitle'] ?? 'Concise TTS',
                        subtitle: text['ttsDemoDesc'] ??
                            'Example voice output: Shuttle arrives in 4 minutes.',
                        color: Colors.deepPurple,
                      ),
                    if (widget.featureId == 'travel-hub' ||
                        widget.featureId == 'tourism-loop' ||
                        widget.featureId == 'bebe-travel') ...[
                      _InfoCard(
                        icon: Icons.travel_explore,
                        title: text['tourismLoopTitle'] ?? 'Sanxia Tourism Loop',
                        subtitle: text['tourismLoopDesc'] ??
                            'AI recommends local food, heritage sites, and trails.',
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
                            backgroundColor: darkGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return text['feature'] ?? 'Feature';
  }

  String fallbackSubtitle(Map<String, String> text) {
    if (widget.featureId == 'laundry-hub') {
      return 'Laundry countdown, free machines, and nearby availability.';
    }

    return text['featureSubtitle'] ??
        'This module is prepared as a clickable prototype.';
  }
}

class _LaundryHubDemo extends StatelessWidget {
  final AppLanguage language;
  final String countdownText;
  final bool countdownFinished;
  final VoidCallback onNotifyTap;

  const _LaundryHubDemo({
    required this.language,
    required this.countdownText,
    required this.countdownFinished,
    required this.onNotifyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isZh = language == AppLanguage.zh;

    final machines = [
      _LaundryMachine(
        name: isZh ? '宿舍 A 棟 01' : 'Dorm A Machine 01',
        status: countdownFinished
            ? (isZh ? '已完成' : 'Finished')
            : (isZh ? '使用中' : 'In Use'),
        detail: countdownFinished
            ? (isZh ? '請盡快取衣' : 'Please pick up your clothes')
            : (isZh ? '剩餘 $countdownText' : '$countdownText remaining'),
        color: countdownFinished ? Colors.orange : Colors.blue,
        icon: Icons.timer,
      ),
      _LaundryMachine(
        name: isZh ? '宿舍 A 棟 02' : 'Dorm A Machine 02',
        status: isZh ? '空閒' : 'Free',
        detail: isZh ? '現在可使用' : 'Available now',
        color: Colors.green,
        icon: Icons.check_circle,
      ),
      _LaundryMachine(
        name: isZh ? '宿舍 B 棟 03' : 'Dorm B Machine 03',
        status: isZh ? '排隊中' : 'Queue',
        detail: isZh ? '前方 2 人' : '2 people waiting',
        color: Colors.purple,
        icon: Icons.people,
      ),
    ];

    final areas = [
      _AreaStatus(
        name: isZh ? '北大宿舍區' : 'NTPU Dorm Area',
        free: 4,
        total: 8,
      ),
      _AreaStatus(
        name: isZh ? '三峽老街周邊' : 'Sanxia Old Street Area',
        free: 2,
        total: 5,
      ),
      _AreaStatus(
        name: isZh ? '捷運站周邊' : 'MRT Station Area',
        free: 6,
        total: 10,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnnouncementCard(
          title: isZh ? '洗衣公告' : 'Laundry Announcement',
          message: countdownFinished
              ? (isZh
                  ? '你的洗衣已完成，請盡快取出衣物。'
                  : 'Your laundry is finished. Please pick it up soon.')
              : (isZh
                  ? '你目前有一台洗衣機正在運轉，剩餘 $countdownText。'
                  : 'One of your machines is running. $countdownText remaining.'),
          onNotifyTap: onNotifyTap,
          buttonText: isZh ? '開啟提醒' : 'Notify Me',
        ),
        const SizedBox(height: 18),
        Text(
          isZh ? '我的洗衣狀態' : 'My Laundry Status',
          style: const TextStyle(
            color: Color(0xFF2F2929),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...machines.map((machine) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LaundryMachineCard(machine: machine),
          );
        }),
        const SizedBox(height: 12),
        Text(
          isZh ? '附近可用洗衣機' : 'Nearby Availability',
          style: const TextStyle(
            color: Color(0xFF2F2929),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...areas.map((area) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AreaAvailabilityCard(area: area),
          );
        }),
      ],
    );
  }
}

class _LaundryMachine {
  final String name;
  final String status;
  final String detail;
  final Color color;
  final IconData icon;

  const _LaundryMachine({
    required this.name,
    required this.status,
    required this.detail,
    required this.color,
    required this.icon,
  });
}

class _AreaStatus {
  final String name;
  final int free;
  final int total;

  const _AreaStatus({
    required this.name,
    required this.free,
    required this.total,
  });
}

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onNotifyTap;

  const _AnnouncementCard({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onNotifyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4EA3E7).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign, color: Color(0xFF4EA3E7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF287DBD),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onNotifyTap,
              icon: const Icon(Icons.notifications_active),
              label: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4EA3E7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaundryMachineCard extends StatelessWidget {
  final _LaundryMachine machine;

  const _LaundryMachineCard({
    required this.machine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: machine.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: machine.color.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: machine.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(machine.icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    color: Color(0xFF2F2929),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  machine.detail,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            machine.status,
            style: TextStyle(
              color: machine.color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaAvailabilityCard extends StatelessWidget {
  final _AreaStatus area;

  const _AreaAvailabilityCard({
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = area.free / area.total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            area.name,
            style: const TextStyle(
              color: Color(0xFF2F2929),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF53A657),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${area.free}/${area.total} available',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w700,
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