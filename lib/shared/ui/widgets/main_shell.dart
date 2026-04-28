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
    final bottomPad    = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // ✅ body extends behind our custom nav bar
      extendBody: true,
      body: child,
      bottomNavigationBar: _NavBar(
        location:   location,
        bottomPad:  bottomPad,
        isChatActive: isChatActive,
      ),
    );
  }
}

// ── Custom Nav Bar — no BottomAppBar, no internal padding ─
class _NavBar extends StatelessWidget {
  final String location;
  final double bottomPad;
  final bool   isChatActive;

  const _NavBar({
    required this.location,
    required this.bottomPad,
    required this.isChatActive,
  });

  @override
  Widget build(BuildContext context) {
    const navH = 58.0; // nav row height
    final fabW = 64.0; // FAB zone width

    return Container(
      // No margin — fills full width
      decoration: BoxDecoration(
        color:  AppColors.surface1,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      // Total height = nav + device bottom padding
      height: navH + bottomPad,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Tab row ──────────────────────────────────
          SizedBox(
            height: navH,
            child: Row(
              children: [
                _NavItem(tab: MainShell._tabs[0],
                  isActive: location == MainShell._tabs[0].path),
                _NavItem(tab: MainShell._tabs[1],
                  isActive: location == MainShell._tabs[1].path),
                // Center gap for FAB
                SizedBox(width: fabW),
                _NavItem(tab: MainShell._tabs[2],
                  isActive: location == MainShell._tabs[2].path),
                _NavItem(tab: MainShell._tabs[3],
                  isActive: location == MainShell._tabs[3].path),
              ],
            ),
          ),
          // ── Central FAB ───────────────────────────────
          Positioned(
            top: -20, // rises above nav bar
            child: _CenterFAB(isChatActive: isChatActive),
          ),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────
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
        mainAxisSize:      MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          AnimatedScale(
            scale:    isActive ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Text(tab.icon,
              style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(height: 2),
          Text(tab.label, style: TextStyle(
            fontFamily: 'Cairo',
            fontSize:   11,
            fontWeight: FontWeight.w700,
            color:      isActive
                ? AppColors.accentAlt
                : AppColors.textTertiary,
          )),
          const SizedBox(height: 3),
          // Active indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:  isActive ? 16 : 0,
            height: 2.5,
            decoration: BoxDecoration(
              gradient:     isActive ? AppColors.primary : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
  );
}

// ── Central FAB ───────────────────────────────────────────
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
      duration: const Duration(milliseconds: 250),
      width: 54, height: 54,
      decoration: BoxDecoration(
        gradient: isChatActive
            ? const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
            : AppColors.primary,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [BoxShadow(
          color:      (isChatActive
              ? const Color(0xFF8B5CF6)
              : AppColors.accent).withOpacity(0.4),
          blurRadius: 18,
          offset:     const Offset(0, 5),
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
