import 'core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'core/providers/font_scale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Bootstrap.init();
  runApp(const ProviderScope(child: MudabbirApp()));
}

class MudabbirApp extends ConsumerWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);        // ✅ watches theme
    final scale     = ref.watch(fontScaleProvider).factor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        title:                      AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme:      AppTheme.light,   // light mode
        darkTheme:  AppTheme.dark,    // dark mode
        themeMode:  themeMode,        // ✅ switches based on user choice
        routerConfig: router,

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

        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              // ✅ Update AppColors based on active theme
              child: _ThemeColorScope(isDark: isDark, child: child!),
            ),
          );
        },
      ),
    );
  }
}

// ── Passes isDark down the tree via InheritedWidget ──────────
class _ThemeColorScope extends InheritedWidget {
  final bool isDark;
  const _ThemeColorScope({required this.isDark, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ThemeColorScope>()?.isDark ?? true;

  @override
  bool updateShouldNotify(_ThemeColorScope old) => isDark != old.isDark;
}
