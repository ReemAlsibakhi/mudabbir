// ═══════════════════════════════════════════════════════════
// AppRouter — GoRouter with typed routes + redirect guard
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/daily/presentation/screens/daily_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/income/presentation/screens/income_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_notifier.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/ui/widgets/main_shell.dart';

// ── Route paths ───────────────────────────────────────────
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String income     = '/income';
  static const String expenses   = '/expenses';
  static const String goals      = '/goals';
  static const String reports    = '/reports';
  static const String settings   = '/settings';
}

// ── Router provider ───────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final isOnboarded = ref.watch(isOnboardedProvider);

  return GoRouter(
    initialLocation: isOnboarded ? AppRoutes.home : AppRoutes.onboarding,
    debugLogDiagnostics: false,

    redirect: (ctx, state) {
      final onboarded   = ref.read(isOnboardedProvider);
      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Edge: not onboarded but trying to access main app → redirect
      if (!onboarded && !onOnboarding) return AppRoutes.onboarding;

      // Edge: already onboarded but on onboarding page → redirect to home
      if (onboarded && onOnboarding) return AppRoutes.home;

      return null; // no redirect needed
    },

    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFF080E1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('خطأ: ${state.error}',
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70)),
          ],
        ),
      ),
    ),

    routes: [
      // ── Onboarding (no shell) ──────────────────────────
      GoRoute(
        path:    AppRoutes.onboarding,
        builder: (_, __) => const OnboardingFlow(),
      ),

      // ── Main app (with bottom nav shell) ──────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path:    AppRoutes.home,
            builder: (_, __) => const DailyScreen(),
          ),
          GoRoute(
            path:    AppRoutes.income,
            builder: (_, __) => IncomeScreen(month: DateTime.now()),
          ),
          GoRoute(
            path:    AppRoutes.expenses,
            builder: (_, __) => ExpensesScreen(month: DateTime.now()),
          ),
          GoRoute(
            path:    AppRoutes.goals,
            builder: (_, __) => const GoalsScreen(),
          ),
          GoRoute(
            path:    AppRoutes.reports,
            builder: (_, __) => const ReportsScreen(),
          ),
          GoRoute(
            path:    AppRoutes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
