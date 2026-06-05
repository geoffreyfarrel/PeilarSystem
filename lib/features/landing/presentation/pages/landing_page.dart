import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';
import '../widgets/bebe_assistant_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/language_toggle.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  static const Color darkHeader = Color(0xFF2F2929);
  static const Color blue = Color(0xFF0079BF);
  static const Color green = Color(0xFF0E9A33);
  static const Color pink = Color(0xFFC6006E);
  static const Color yellow = Color(0xFFEDA944);
  static const Color textDark = Color(0xFF2F2929);
  static const Color textGrey = Color(0xFF646363);

  void openFeature(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool studentOnly = false,
  }) {
    if (id == 'travel-hub') {
      context.go('/ai-itinerary');
      return;
    }

    context.go(
      '/feature/$id',
      extra: {
        'title': title,
        'subtitle': subtitle,
        'icon': icon,
        'studentOnly': studentOnly,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _DarkHeader(text: text, onOpenFeature: openFeature),
                Transform.translate(
                  offset: const Offset(0, -34),
                  child: _MainWhiteSection(
                    text: text,
                    onOpenFeature: openFeature,
                  ),
                ),
              ],
            ),
          ),
          const BebeAssistantButton(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class _DarkHeader extends StatelessWidget {
  final Map<String, String> text;
  final void Function(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool studentOnly,
  })
  onOpenFeature;

  const _DarkHeader({required this.text, required this.onOpenFeature});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 318,
      color: LandingPage.darkHeader,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 16, 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onOpenFeature(
                      context,
                      id: 'notifications',
                      title: 'Notifications',
                      subtitle: 'Campus, payment, shuttle, and service alerts.',
                      icon: Icons.notifications,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 30,
                        ),
                        Positioned(
                          right: -8,
                          top: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: LandingPage.pink,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '47',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text['easyWallet'] ?? 'Easy Wallet',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const LanguageToggle(darkMode: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _AutoPromoCarousel(text: text, onOpenFeature: onOpenFeature),
          ],
        ),
      ),
    );
  }
}

class _AutoPromoCarousel extends StatefulWidget {
  final Map<String, String> text;
  final void Function(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool studentOnly,
  })
  onOpenFeature;

  const _AutoPromoCarousel({required this.text, required this.onOpenFeature});

  @override
  State<_AutoPromoCarousel> createState() => _AutoPromoCarouselState();
}

class _AutoPromoCarouselState extends State<_AutoPromoCarousel> {
  late final PageController controller;
  Timer? timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.84);
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !controller.hasClients) return;
      final nextIndex = (currentIndex + 1) % 3;
      controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = [
      _PromoData(
        id: 'digital-easycard',
        title: widget.text['digitalEasyCard'] ?? 'Digital EasyCard',
        subtitle:
            widget.text['digitalEasyCardDesc'] ??
            'Artist and university collections',
        largeText: 'UT',
        icon: Icons.style,
        background: const Color(0xFFFCE4F0),
      ),
      _PromoData(
        id: 'laundry-hub',
        title: widget.text['laundryHub'] ?? 'Laundry Hub',
        subtitle:
            widget.text['laundryHubDesc'] ?? 'QR booking and machine status',
        largeText: '11',
        icon: Icons.local_laundry_service,
        background: const Color(0xFFE5F5EB),
      ),
      _PromoData(
        id: 'tax-campaign',
        title: widget.text['promoTax'] ?? 'House Tax',
        subtitle: widget.text['promoCashback'] ?? 'Maximum Cashback',
        largeText: '800',
        icon: Icons.home_work,
        background: const Color(0xFFEDA944),
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _PromoCard(
                background: banner.background,
                title: banner.title,
                subtitle: banner.subtitle,
                largeText: banner.largeText,
                imageIcon: banner.icon,
                onTap: () => widget.onOpenFeature(
                  context,
                  id: banner.id,
                  title: banner.title,
                  subtitle: banner.subtitle,
                  icon: banner.icon,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final active = index == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 5,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoData {
  final String id;
  final String title;
  final String subtitle;
  final String largeText;
  final IconData icon;
  final Color background;

  const _PromoData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.largeText,
    required this.icon,
    required this.background,
  });
}

class _PromoCard extends StatelessWidget {
  final Color background;
  final String title;
  final String subtitle;
  final String largeText;
  final IconData imageIcon;
  final VoidCallback onTap;

  const _PromoCard({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.largeText,
    required this.imageIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                right: 18,
                top: 16,
                child: Icon(
                  imageIcon,
                  size: 64,
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                left: 20,
                top: 24,
                right: 16,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF2F2929), fontSize: 29, fontWeight: FontWeight.w900),
                ),
              ),
              Positioned(
                left: 22,
                top: 66,
                right: 18,
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF2F2929), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 10,
                child: Text(
                  largeText,
                  style: const TextStyle(color: Color(0xFFC6006E), fontSize: 48, fontWeight: FontWeight.w900, height: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainWhiteSection extends StatelessWidget {
  final Map<String, String> text;
  final void Function(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    bool studentOnly,
  })
  onOpenFeature;

  const _MainWhiteSection({required this.text, required this.onOpenFeature});

  @override
  Widget build(BuildContext context) {
    final mainActions = [
      _FeatureSpec(
        id: 'scan-transfer',
        label: text['scanTransfer'] ?? 'Scan / Transfer',
        subtitle: 'Scan QR codes or transfer to users and merchants.',
        icon: Icons.qr_code_scanner,
        color: LandingPage.pink,
      ),
      _FeatureSpec(
        id: 'payment-code',
        label: text['paymentCode'] ?? 'Payment Code',
        subtitle: 'Generate payment code for quick checkout.',
        icon: Icons.qr_code_2,
        color: const Color(0xFFEDA944),
      ),
      _FeatureSpec(
        id: 'receive',
        label: text['receive'] ?? 'Receive',
        subtitle: 'Receive money from friends or local merchants.',
        icon: Icons.payments_outlined,
        color: LandingPage.green,
      ),
      _FeatureSpec(
        id: 'top-up',
        label: text['topUp'] ?? 'EasyCard Top-up',
        subtitle: 'Top up your EasyCard or Peilar Card.',
        icon: Icons.credit_card,
        color: LandingPage.blue,
        badge: '嗶',
      ),
    ];

    final studentFeatures = [
      _FeatureSpec(
        id: 'attendance',
        label: text['attendance'] ?? 'Attendance Checker',
        subtitle: text['attendanceDesc'] ?? 'Check class attendance.',
        icon: Icons.assignment_turned_in,
        color: LandingPage.blue,
        studentOnly: true,
      ),
      _FeatureSpec(
        id: 'secondhand-books',
        label: text['secondhandBooks'] ?? 'Secondhand Books',
        subtitle:
            text['secondhandBooksDesc'] ??
            'Verified student market for textbooks, dorm furniture, clothes, and daily campus items.',
        icon: Icons.menu_book,
        color: LandingPage.pink,
        studentOnly: true,
      ),
      _FeatureSpec(
        id: 'forum',
        label: text['forum'] ?? 'Student Forum',
        subtitle: text['forumDesc'] ?? 'Verified campus discussion.',
        icon: Icons.forum,
        color: const Color(0xFF0E9A33),
        studentOnly: true,
      ),
    ];

    final newFeatures = [
      _FeatureSpec(
        id: 'digital-easycard',
        label: text['digitalEasyCard'] ?? 'Digital EasyCard',
        subtitle:
            text['digitalEasyCardDesc'] ??
            'Customize your virtual card with artist and university collections.',
        icon: Icons.style,
        color: const Color(0xFF0079BF),
      ),
      _FeatureSpec(
        id: 'qr',
        label: text['qr'] ?? 'QR',
        subtitle: 'Universal QR transactions and payments.',
        icon: Icons.qr_code,
        color: const Color(0xFF0079BF),
      ),
      _FeatureSpec(
        id: 'travel-hub',
        label: text['travelHub'] ?? 'Travel Hub',
        subtitle: 'Tourism, transit, and itinerary support.',
        icon: Icons.luggage,
        color: const Color(0xFFEDA944),
      ),
      _FeatureSpec(
        id: 'split-bill',
        label: text['splitBill'] ?? 'Split Bill',
        subtitle: 'Split payment with friends.',
        icon: Icons.receipt_long,
        color: const Color(0xFF646363),
      ),
      _FeatureSpec(
        id: 'festivals',
        label: text['festivals'] ?? 'Festivals',
        subtitle: 'Sanxia event dates, locations, and prices.',
        icon: Icons.celebration,
        color: const Color(0xFFEDA944),
      ),
      _FeatureSpec(
        id: 'laundry-hub',
        label: text['laundryHub'] ?? 'Laundry Hub',
        subtitle:
            text['laundryHubDesc'] ?? 'Laundry status and IoT notifications.',
        icon: Icons.local_laundry_service,
        color: LandingPage.blue,
      ),
      _FeatureSpec(
        id: 'groceries',
        label: text['groceries'] ?? 'Groceries',
        subtitle: '7-Eleven, FamilyMart, and local shopping.',
        icon: Icons.store,
        color: const Color(0xFF646363),
      ),
    ];

    final serviceItems = [
      _FeatureSpec(
        id: 'friday',
        label: text['friday'] ?? 'Friday +2%',
        subtitle: 'Friday cashback and reward campaign.',
        icon: Icons.fastfood,
        color: LandingPage.pink,
      ),
      _FeatureSpec(
        id: 'coupons',
        label: text['coupons'] ?? 'Coupons',
        subtitle: 'Claim and use EasyWallet coupons.',
        icon: Icons.confirmation_number,
        color: LandingPage.pink,
      ),
      _FeatureSpec(
        id: 'card-carrier',
        label: text['cardCarrier'] ?? 'Card Carrier',
        subtitle: 'Connect carrier and receipt records.',
        icon: Icons.credit_score,
        color: LandingPage.green,
      ),
      _FeatureSpec(
        id: 'voucher',
        label: text['voucher'] ?? 'Vouchers',
        subtitle: 'Use local merchant vouchers.',
        icon: Icons.local_activity,
        color: LandingPage.pink,
      ),
      _FeatureSpec(
        id: 'insurance',
        label: text['insurance'] ?? 'Insurance',
        subtitle: 'Insurance zone and student safety support.',
        icon: Icons.beach_access,
        color: LandingPage.green,
      ),
      _FeatureSpec(
        id: 'finance',
        label: text['finance'] ?? 'Finance',
        subtitle: 'Financial service and budget tools.',
        icon: Icons.account_balance,
        color: LandingPage.yellow,
      ),
      _FeatureSpec(
        id: 'registration',
        label: text['registration'] ?? 'Card Registration',
        subtitle: 'Register EasyCard and Peilar Card.',
        icon: Icons.edit_note,
        color: LandingPage.green,
      ),
      _FeatureSpec(
        id: 'accepted-places',
        label: text['acceptedPlaces'] ?? 'Accepted Places',
        subtitle: 'Find merchants that accept EasyWallet.',
        icon: Icons.storefront,
        color: LandingPage.blue,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: mainActions.map((item) {
                return _MainActionButton(
                  item: item,
                  onTap: () {
                    if (item.id == 'scan-transfer') {
                      context.go('/qr-scanner');
                    } else {
                      onOpenFeature(
                        context,
                        id: item.id,
                        title: item.label,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        studentOnly: item.studentOnly,
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          _YellowTaxBanner(
            text: text,
            onTap: () => onOpenFeature(
              context,
              id: 'tax-campaign',
              title: text['promoTax'] ?? 'House Tax',
              subtitle: text['promoCashback'] ?? 'Maximum Cashback',
              icon: Icons.home,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              children: [
                _SectionTitle(
                  title: text['studentArea'] ?? 'Student Area',
                  subtitle:
                      text['studentOnlyNote'] ??
                      'Only accessible after Student ID binding',
                  actionLabel: text['seeAll'] ?? 'See all',
                  onActionTap: () => onOpenFeature(
                    context,
                    id: 'student-area',
                    title: text['studentArea'] ?? 'Student Area',
                    subtitle:
                        text['studentOnlyNote'] ??
                        'Only accessible after Student ID binding',
                    icon: Icons.school,
                    studentOnly: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: studentFeatures.map((item) {
                      return Expanded(
                        child: _StudentFeatureCard(
                          item: item,
                          onTap: () {
                            if (item.id == 'secondhand-books') {
                              context.go('/secondhand');
                            } else {
                              onOpenFeature(
                                context,
                                id: item.id,
                                title: item.label,
                                subtitle: item.subtitle,
                                icon: item.icon,
                                studentOnly: item.studentOnly,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              children: [
                _FeaturePagesPanel(
                  pages: [newFeatures, serviceItems],
                  onFeatureTap: (item) => onOpenFeature(
                    context,
                    id: item.id,
                    title: item.label,
                    subtitle: item.subtitle,
                    icon: item.icon,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _NewsTicker(
            text: text,
            onTap: () => onOpenFeature(
              context,
              id: 'news',
              title: 'News',
              subtitle: text['news'] ?? 'Service announcements.',
              icon: Icons.campaign,
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _FeatureSpec {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final bool studentOnly;

  const _FeatureSpec({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    this.studentOnly = false,
  });
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: LandingPage.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (onActionTap == null)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(999),
              child: Row(
                children: [
                  Text(
                    actionLabel ?? 'See all',
                    style: const TextStyle(
                      color: LandingPage.pink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    color: LandingPage.pink,
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  final _FeatureSpec item;
  final VoidCallback onTap;

  const _MainActionButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.13),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: item.color, size: 32),
                ),
                if (item.badge != null)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFF0079BF), shape: BoxShape.circle),
                      child: Text(item.badge!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: LandingPage.textDark,
                fontSize: 15,
                height: 1.22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YellowTaxBanner extends StatelessWidget {
  final Map<String, String> text;
  final VoidCallback onTap;

  const _YellowTaxBanner({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 92,
        margin: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: LandingPage.yellow,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 15,
              child: Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LandingPage.blue, width: 3),
                ),
                child: const Icon(
                  Icons.phone_iphone,
                  color: LandingPage.blue,
                  size: 30,
                ),
              ),
            ),
            const Positioned(
              left: 80,
              top: 12,
              child: Text('2026 / 4/28 - 5/31', style: TextStyle(color: Color(0xFF646363), fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            Positioned(
              left: 80,
              top: 35,
              child: Text(
                text['promoTax'] ?? 'House Tax',
                style: const TextStyle(color: Color(0xFF0079BF), fontSize: 26, fontWeight: FontWeight.w900, height: 1),
              ),
            ),
            Positioned(
              left: 80,
              bottom: 12,
              child: Text(
                text['promoCashback'] ?? 'Maximum Cashback',
                style: const TextStyle(color: Color(0xFF0079BF), fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const Positioned(
              right: 86,
              top: 12,
              child: Text(
                '800',
                style: TextStyle(
                  color: LandingPage.pink,
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
            const Positioned(
              right: 40,
              bottom: 18,
              child: Text(
                '元',
                style: TextStyle(
                  color: LandingPage.pink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: const Icon(Icons.home, color: Color(0xFF0079BF), size: 34),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentFeatureCard extends StatelessWidget {
  final _FeatureSpec item;
  final VoidCallback onTap;

  const _StudentFeatureCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F5EB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE7D7)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: item.color, size: 34),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LandingPage.textGrey,
                  fontSize: 13,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniFeatureCard extends StatelessWidget {
  final _FeatureSpec item;
  final VoidCallback onTap;

  const _MiniFeatureCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 38),
          const SizedBox(height: 10),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LandingPage.textGrey,
              fontSize: 14,
              height: 1.18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePagesPanel extends StatefulWidget {
  final List<List<_FeatureSpec>> pages;
  final ValueChanged<_FeatureSpec> onFeatureTap;

  const _FeaturePagesPanel({required this.pages, required this.onFeatureTap});

  @override
  State<_FeaturePagesPanel> createState() => _FeaturePagesPanelState();
}

class _FeaturePagesPanelState extends State<_FeaturePagesPanel> {
  late final PageController controller;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const rowHeight = 112.0;
    const rowGap = 30.0;
    const columnGap = 14.0;

    return Column(
      children: [
        SizedBox(
          height: rowHeight * 2 + rowGap,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.pages.length,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, pageIndex) {
              final items = widget.pages[pageIndex];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth = (constraints.maxWidth - columnGap * 3) / 4;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: rowGap,
                    crossAxisSpacing: columnGap,
                    childAspectRatio: cellWidth / rowHeight,
                    children: items.map((item) {
                      return _MiniFeatureCard(
                        item: item,
                        onTap: () => widget.onFeatureTap(item),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _PageDots(count: widget.pages.length, activeIndex: currentPage),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _PageDots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 14,
          height: active ? 5 : 4,
          decoration: BoxDecoration(
            color: active ? Colors.grey.shade700 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _NewsTicker extends StatelessWidget {
  final Map<String, String> text;
  final VoidCallback onTap;

  const _NewsTicker({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text['news'] ?? '',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
