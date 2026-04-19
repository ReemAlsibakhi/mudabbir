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

final appRouterProvider = Provider<GoRouter>((ref) {
  final isOnboarded = ref.watch(isOnboardedProvider);

  return GoRouter(
    initialLocation: isOnboarded ? '/home' : '/onboarding',
    redirect: (_, state) {
      final onboarded    = ref.read(isOnboardedProvider);
      final onOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboarded && !onOnboarding) return '/onboarding';
      if (onboarded  &&  onOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFlow()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',     builder: (_, __) => const DailyScreen()),
          GoRoute(path: '/income',   builder: (_, __) => IncomeScreen(month: DateTime.now())),
          GoRoute(path: '/expenses', builder: (_, __) => ExpensesScreen(month: DateTime.now())),
          GoRoute(path: '/goals',    builder: (_, __) => const GoalsScreen()),
          GoRoute(path: '/reports',  builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('خطأ: ${state.error}',
        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white))),
    ),
  );
});
