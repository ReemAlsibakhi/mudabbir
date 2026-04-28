import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_chat/presentation/screens/chat_screen.dart';
import '../../features/daily/presentation/screens/daily_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/income/presentation/screens/income_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_notifier.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/ui/widgets/main_shell.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String expenses   = '/expenses';
  static const String goals      = '/goals';
  static const String reports    = '/reports';
  // ── Secondary: push over shell (have back button) ──────
  static const String income     = '/income';
  static const String settings   = '/settings';
  static const String chat       = '/chat';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final isOnboarded = ref.watch(isOnboardedProvider);

  return GoRouter(
    initialLocation: isOnboarded ? AppRoutes.home : AppRoutes.onboarding,
    redirect: (_, state) {
      final onboarded    = ref.read(isOnboardedProvider);
      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !onOnboarding) return AppRoutes.onboarding;
      if (onboarded  &&  onOnboarding) return AppRoutes.home;
      return null;
    },
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Center(child: Text('${state.error}',
        style: const TextStyle(fontFamily:'Cairo', color: Colors.white70))),
    ),
    routes: [
      // Onboarding — no shell, no back
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_,__) => const OnboardingFlow(),
      ),

      // ── Main shell — 4 tabs + FAB ─────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_,__) => const DailyScreen(),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (_,__) => ExpensesScreen(month: DateTime.now()),
          ),
          GoRoute(
            path: AppRoutes.goals,
            builder: (_,__) => const GoalsScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (_,__) => const ReportsScreen(),
          ),
          // ✅ Chat inside shell — FAB becomes ✕ to close
          GoRoute(
            path: AppRoutes.chat,
            builder: (_,__) => const ChatScreen(),
          ),
        ],
      ),

      // ── Secondary routes — pushed on top of shell ─────
      // These have their own AppBar + back button
      GoRoute(
        path: AppRoutes.income,
        builder: (_,__) => IncomeScreen(month: DateTime.now()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_,__) => const SettingsScreen(),
      ),
    ],
  );
});
