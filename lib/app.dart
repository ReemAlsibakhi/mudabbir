import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/country_screen.dart';
import 'features/onboarding/screens/life_stage_screen.dart';
import 'features/onboarding/screens/setup_screen.dart';
import 'features/daily/screens/daily_screen.dart';
import 'features/income/screens/income_screen.dart';
import 'features/expenses/screens/expenses_screen.dart';
import 'features/goals/screens/goals_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'shared/widgets/main_scaffold.dart';
import 'data/providers/user_provider.dart';

class MudabbirApp extends ConsumerWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return MaterialApp(
      title: 'مدبّر',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,

      // دعم العربية
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('ar', 'AE'),
        Locale('ar', 'EG'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: userState.when(
        loading: () => const _SplashScreen(),
        error: (_, __) => const OnboardingScreen(),
        data: (user) {
          if (user == null || !user.setupComplete) {
            return const OnboardingScreen();
          }
          return const MainScaffold();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'مدبّر',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0EA5E9),
          ),
        ),
      ),
    );
  }
}
