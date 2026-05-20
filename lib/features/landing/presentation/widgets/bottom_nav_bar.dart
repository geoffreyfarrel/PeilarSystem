import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/language_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(appTextProvider);

    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: text['home'] ?? 'Home',
              selected: true,
              onTap: () => context.go('/'),
            ),
            _NavItem(
              icon: Icons.credit_card,
              label: text['easyCard'] ?? 'EasyCard',
              selected: false,
              onTap: () => openFeature(
                context,
                id: 'easy-card',
                title: text['easyCard'] ?? 'EasyCard',
                subtitle: 'Digital EasyCard and Peilar Card binding.',
                icon: Icons.credit_card,
              ),
            ),
            _CenterRideCodeItem(
              label: text['rideCode'] ?? 'Ride Code',
              onTap: () => openFeature(
                context,
                id: 'ride-code',
                title: text['rideCode'] ?? 'Ride Code',
                subtitle: 'Transit QR code for MRT, shuttle, and buses.',
                icon: Icons.train,
              ),
            ),

            // FIXED: Profile / Me opens student login & bind page.
            _NavItem(
              icon: Icons.person,
              label: text['me'] ?? 'Me',
              selected: false,
              onTap: () => context.go('/student-bind'),
            ),

            _NavItem(
              icon: Icons.grid_view_rounded,
              label: text['more'] ?? 'More',
              selected: false,
              onTap: () => openFeature(
                context,
                id: 'more',
                title: text['more'] ?? 'More',
                subtitle: 'More Peilar x NTPU mini-app features.',
                icon: Icons.grid_view_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF4EA3E7) : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFF287DBD) : Colors.grey.shade500,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterRideCodeItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CenterRideCodeItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF4EA3E7),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4EA3E7).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.train,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF287DBD),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}