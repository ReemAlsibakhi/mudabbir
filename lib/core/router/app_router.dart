import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai_chat/presentation/screens/chat_screen.dart';
import '../../features/daily/presentation/screens/daily_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/income/presentation/screens/income_screen.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/presentation/providers/onboarding_notifier.dart';
import '../../features/onboarding/presentation/providers/onboarding_state.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/ui/widgets/main_shell.dart';

// ════════════════════════════════════════════════════════════
// AppRoutes — all named paths
// ════════════════════════════════════════════════════════════
abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home       = '/home';
  static const String expenses   = '/expenses';
  static const String goals      = '/goals';
  static const String reports    = '/reports';
  static const String income     = '/income';
  static const String settings   = '/settings';
  static const String chat       = '/chat';
}

// ════════════════════════════════════════════════════════════
// RouterNotifier — bridges Riverpod → GoRouter
//
// GoRouter uses refreshListenable to know when to re-evaluate
// its redirect function. This notifier listens to the
// onboardingNotifierProvider and fires notifyListeners() when
// onboarding completes, forcing the router to re-run redirect
// with FRESH data from Hive (not cached).
// ════════════════════════════════════════════════════════════
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<OnboardingState>(
      onboardingNotifierProvider,
      (_, next) {
        if (next.step == OnboardingStep.done) {
          // Onboarding just completed → tell GoRouter to re-check redirect
          notifyListeners();
        }
      },
    );
  }
}

final _routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

// ════════════════════════════════════════════════════════════
// appRouterProvider
// ════════════════════════════════════════════════════════════
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation:   AppRoutes.onboarding,
    refreshListenable: notifier,

    redirect: (context, routerState) {
      // ✅ KEY FIX: read DIRECTLY from Hive every time — never cached
      // This is safe because isOnboarded() is a simple synchronous Hive read
      final isOnboarded  = OnboardingRepositoryImpl().isOnboarded();
      final onOnboarding = routerState.matchedLocation == AppRoutes.onboarding;

      if (!isOnboarded && !onOnboarding) return AppRoutes.onboarding;
      if (isOnboarded  &&  onOnboarding) return AppRoutes.home;
      return null;
    },

    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Center(
        child: Text(
          state.error?.message ?? 'خطأ في التنقل',
          style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70),
        ),
      ),
    ),

    routes: [
      // Onboarding — outside shell, no back button
      GoRoute(
        path:    AppRoutes.onboarding,
        builder: (_,__) => const OnboardingFlow(),
      ),

      // ── Main shell — bottom nav always visible ──────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home,
            builder: (_,__) => const DailyScreen()),
          GoRoute(path: AppRoutes.expenses,
            builder: (_,__) => ExpensesScreen(month: DateTime.now())),
          GoRoute(path: AppRoutes.goals,
            builder: (_,__) => const GoalsScreen()),
          GoRoute(path: AppRoutes.reports,
            builder: (_,__) => const ReportsScreen()),
          GoRoute(path: AppRoutes.chat,
            builder: (_,__) => const ChatScreen()),
        ],
      ),

      // ── Secondary screens — Navigator.push from shell ───
      GoRoute(path: AppRoutes.income,
        builder: (_,__) => IncomeScreen(month: DateTime.now())),
      GoRoute(path: AppRoutes.settings,
        builder: (_,__) => const SettingsScreen()),
    ],
  );
});
