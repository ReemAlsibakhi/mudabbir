import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: AppRoutes.home,     icon: '🌙', label: 'اليوم'),
    (path: AppRoutes.expenses, icon: '💸', label: 'المصروف'),
    (path: AppRoutes.goals,    icon: '🎯', label: 'الأهداف'),
    (path: AppRoutes.reports,  icon: '📊', label: 'التقارير'),
  ];

  @override
  Widget build(BuildContext context) {
    final location  = GoRouterState.of(context).matchedLocation;
    final leftTabs  = _tabs.sublist(0, 2);
    final rightTabs = _tabs.sublist(2, 4);

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _NavBar(
        location:  location,
        leftTabs:  leftTabs,
        rightTabs: rightTabs,
      ),
      floatingActionButton: _FAB(),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final String location;
  final List leftTabs, rightTabs;
  const _NavBar({
    required this.location,
    required this.leftTabs,
    required this.rightTabs,
  });

  @override
  Widget build(BuildContext context) => BottomAppBar(
    color:     AppColors.surface1,
    elevation: 0,
    notchMargin: 8,
    shape:     const CircularNotchedRectangle(),
    padding:   EdgeInsets.zero,
    height:    64,
    child: Row(
      children: [
        ...leftTabs.map((t) => _NavItem(
          tab: t, isActive: location == t.path as String)),
        const Spacer(),
        const Spacer(),
        ...rightTabs.map((t) => _NavItem(
          tab: t, isActive: location == t.path as String)),
      ],
    ),
  );
}

// ── Nav Item ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final dynamic tab;
  final bool    isActive;
  const _NavItem({required this.tab, required this.isActive});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(tab.path as String);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale:    isActive ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              tab.icon as String,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tab.label as String,
            style: TextStyle(
              fontFamily:  'Cairo',
              fontSize:    12,
              fontWeight:  FontWeight.w700,
              color:       isActive
                  ? AppColors.accentAlt
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width:  isActive ? 18 : 0,
            height: 3,
            decoration: BoxDecoration(
              gradient:     isActive ? AppColors.primary : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Central FAB ───────────────────────────────────────────
class _FAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      // Navigate to expenses and open add sheet
      context.go(AppRoutes.expenses);
    },
    child: Container(
      width:  58,
      height: 58,
      decoration: BoxDecoration(
        gradient:     AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:      AppColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
    ),
  );
}
