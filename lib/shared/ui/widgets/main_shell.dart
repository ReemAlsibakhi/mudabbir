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
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _NavBar(location: location),
      floatingActionButton: _CenterFAB(isChatActive: isChatActive),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final String location;
  const _NavBar({required this.location});

  @override
  Widget build(BuildContext context) => BottomAppBar(
    color:       AppColors.surface1,
    elevation:   0,
    notchMargin: 8,
    shape:       const CircularNotchedRectangle(),
    padding:     EdgeInsets.zero,
    height:      64,
    child: Row(
      children: [
        _NavItem(
          tab:      MainShell._tabs[0],
          isActive: location == MainShell._tabs[0].path),
        _NavItem(
          tab:      MainShell._tabs[1],
          isActive: location == MainShell._tabs[1].path),
        const Spacer(),
        const Spacer(),
        _NavItem(
          tab:      MainShell._tabs[2],
          isActive: location == MainShell._tabs[2].path),
        _NavItem(
          tab:      MainShell._tabs[3],
          isActive: location == MainShell._tabs[3].path),
      ],
    ),
  );
}

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
          const SizedBox(height: 3),
          Text(tab.label, style: TextStyle(
            fontFamily:    'Cairo',
            fontSize:      12,
            fontWeight:    FontWeight.w700,
            color:         isActive
                ? AppColors.accentAlt
                : AppColors.textTertiary,
          )),
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

// ── FAB — opens AI Chat OR closes it ──────────────────────
class _CenterFAB extends StatelessWidget {
  final bool isChatActive;
  const _CenterFAB({required this.isChatActive});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      if (isChatActive) {
        // ✅ Close chat → back to home
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.chat);
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 58, height: 58,
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
