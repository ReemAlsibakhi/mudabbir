import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    (path: AppRoutes.home,     icon: '🌙', label: 'اليوم'),
    (path: AppRoutes.income,   icon: '💰', label: 'الدخل'),
    (path: AppRoutes.expenses, icon: '💸', label: 'مصروف'),
    (path: AppRoutes.goals,    icon: '🎯', label: 'أهداف'),
    (path: AppRoutes.reports,  icon: '📈', label: 'تقارير'),
    (path: AppRoutes.settings, icon: '⚙️', label: 'إعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:  AppColors.surface1.withOpacity(0.97),
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: _tabs.map((t) {
                final active = location == t.path ||
                    (location == '/' && t.path == AppRoutes.home);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(t.path),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Active background pill
                        if (active)
                          Positioned(
                            top: 6, bottom: 6,
                            child: Container(
                              width: 48,
                              decoration: BoxDecoration(
                                color:        AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        // Content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t.icon,
                              style: TextStyle(
                                fontSize: 17,
                                // Slight opacity for inactive
                              )),
                            const SizedBox(height: 2),
                            Text(t.label,
                              style: AppTextStyles.label.copyWith(
                                color: active
                                    ? AppColors.accentAlt
                                    : AppColors.textTertiary.withOpacity(0.8),
                                letterSpacing: 0,
                                fontSize: 9,
                              )),
                          ],
                        ),
                        // Active top indicator
                        if (active)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 20, height: 2.5,
                              decoration: BoxDecoration(
                                gradient:     AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
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
