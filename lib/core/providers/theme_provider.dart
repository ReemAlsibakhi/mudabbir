import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

// ══════════════════════════════════════════════════════════
// ThemeProvider — user-selected theme mode
// Stored in Hive, persists across restarts
// Default: dark (Arabic apps convention)
// ══════════════════════════════════════════════════════════

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (_) => ThemeNotifier(),
);

final class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _tag = 'ThemeNotifier';
  static const _key = 'theme_mode';

  Box get _box => Hive.box(AppConstants.settingsBox);

  ThemeNotifier() : super(ThemeMode.dark) { _load(); }

  void _load() {
    try {
      final saved = _box.get(_key) as String?;
      state = switch (saved) {
        'light'  => ThemeMode.light,
        'system' => ThemeMode.system,
        _        => ThemeMode.dark,
      };
    } catch (e) {
      AppLogger.error(_tag, 'load', e);
    }
  }

  Future<void> set(ThemeMode mode) async {
    try {
      state = mode;
      await _box.put(_key, mode.name);
      AppLogger.info(_tag, 'Theme → ${mode.name}');
    } catch (e) {
      AppLogger.error(_tag, 'set', e);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}
