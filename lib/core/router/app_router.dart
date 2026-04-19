import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/providers/onboarding_notifier.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow.dart';
import '../../shared/ui/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isOnboarded = ref.watch(isOnboardedProvider);
  return GoRouter(
    initialLocation: isOnboarded ? '/home' : '/onboarding',
    redirect: (ctx, state) {
      final onboarded = ref.read(isOnboardedProvider);
      final onOnboarding = state.matchedLocation.startsWith('/onboarding');
      if (!onboarded && !onOnboarding) return '/onboarding';
      if (onboarded  &&  onOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path:    '/onboarding',
        builder: (_, __) => const OnboardingFlow(),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home',     builder: (_, __) => const _Daily()),
          GoRoute(path: '/income',   builder: (_, __) => const _Income()),
          GoRoute(path: '/expenses', builder: (_, __) => const _Expenses()),
          GoRoute(path: '/goals',    builder: (_, __) => const _Goals()),
          GoRoute(path: '/reports',  builder: (_, __) => const _Reports()),
          GoRoute(path: '/settings', builder: (_, __) => const _Settings()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('404: ${state.error}',
        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white))),
    ),
  );
});

// Placeholder builders — point to real screens
class _Daily    extends StatelessWidget { const _Daily();    @override Widget build(_) => const Placeholder(); }
class _Income   extends StatelessWidget { const _Income();   @override Widget build(_) => const Placeholder(); }
class _Expenses extends StatelessWidget { const _Expenses(); @override Widget build(_) => const Placeholder(); }
class _Goals    extends StatelessWidget { const _Goals();    @override Widget build(_) => const Placeholder(); }
class _Reports  extends StatelessWidget { const _Reports();  @override Widget build(_) => const Placeholder(); }
class _Settings extends StatelessWidget { const _Settings(); @override Widget build(_) => const Placeholder(); }
