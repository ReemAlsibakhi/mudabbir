import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: '/home',     icon: '🌙', label: 'اليوم'),
    (path: '/income',   icon: '💰', label: 'الدخل'),
    (path: '/expenses', icon: '💸', label: 'المصروف'),
    (path: '/goals',    icon: '🎯', label: 'الأهداف'),
    (path: '/reports',  icon: '📈', label: 'التقارير'),
    (path: '/settings', icon: '⚙️', label: 'إعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color:  AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: _tabs.map((t) {
                final active = location == t.path;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(t.path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.icon, style: const TextStyle(fontSize: 17)),
                        const SizedBox(height: 2),
                        Text(t.label,
                          style: AppTextStyles.label.copyWith(
                            color: active ? AppColors.accentAlt : AppColors.textTertiary,
                            letterSpacing: 0,
                          )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
