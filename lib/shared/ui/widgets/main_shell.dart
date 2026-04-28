import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: AppRoutes.home,     icon: '🌙', label: 'اليوم'),
    (path: AppRoutes.expenses, icon: '💸', label: 'مصروف'),
    (path: AppRoutes.goals,    icon: '🎯', label: 'أهداف'),
    (path: AppRoutes.reports,  icon: '📊', label: 'تقارير'),
  ];

  @override
  Widget build(BuildContext context) {
    final location     = GoRouterState.of(context).matchedLocation;
    final isChatActive = location == AppRoutes.chat;

    return Scaffold(
      backgroundColor:              AppColors.bg,
      // ✅ extendBody: false — body does NOT go behind BottomAppBar
      extendBody:                   false,
      body:                         child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:          _NavBar(location: location),
      floatingActionButton:         _CenterFAB(isChatActive: isChatActive),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final String location;
  const _NavBar({required this.location});

  @override
  Widget build(BuildContext context) => BottomAppBar(
    color:           AppColors.surface1,
    elevation:       0,
    notchMargin:     8,
    shape:           const CircularNotchedRectangle(),
    // ✅ NO height parameter — let SafeArea determine total height
    padding:         EdgeInsets.zero,
    child: SafeArea(
      // ✅ SafeArea wraps ONLY the bottom
      // Adds home-indicator / chin padding automatically
      // Works correctly on every device: notch iPhones, flat Androids, etc.
      top:  false,
      left: false,
      right: false,
      child: SizedBox(
        // ✅ Fixed 60px for the visible nav items only
        height: 60,
        child: Row(
          children: [
            _NavItem(tab: MainShell._tabs[0],
              isActive: location == MainShell._tabs[0].path),
            _NavItem(tab: MainShell._tabs[1],
              isActive: location == MainShell._tabs[1].path),
            const Spacer(),
            const Spacer(),
            _NavItem(tab: MainShell._tabs[2],
              isActive: location == MainShell._tabs[2].path),
            _NavItem(tab: MainShell._tabs[3],
              isActive: location == MainShell._tabs[3].path),
          ],
        ),
      ),
    ),
  );
}

// ── Nav Item ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final ({String path, String icon, String label}) tab;
  final bool isActive;
  const _NavItem({required this.tab, required this.isActive});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go(tab.path);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale:    isActive ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(tab.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 2),
          Text(tab.label, style: TextStyle(
            fontFamily: 'Cairo',
            fontSize:   12,
            fontWeight: FontWeight.w700,
            color:      isActive ? AppColors.accentAlt : AppColors.textTertiary,
          )),
          const SizedBox(height: 2),
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

// ── FAB ──────────────────────────────────────────────────
class _CenterFAB extends StatelessWidget {
  final bool isChatActive;
  const _CenterFAB({required this.isChatActive});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      context.go(isChatActive ? AppRoutes.home : AppRoutes.chat);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56, height: 56,
      decoration: BoxDecoration(
        gradient: isChatActive
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
            : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color:      (isChatActive
              ? const Color(0xFF8B5CF6)
              : AppColors.accent).withOpacity(0.4),
          blurRadius: 20,
          offset:     const Offset(0, 6),
        )],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isChatActive ? '✕' : '🤖',
            key:   ValueKey(isChatActive),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    ),
  );
}
