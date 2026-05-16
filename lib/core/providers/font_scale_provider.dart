import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

// ══════════════════════════════════════════════════════════
// FontScale — 3 levels the user picks in Settings
//
// Applied via textScaler in main.dart — scales ALL Text()
// in the entire app automatically. No widget changes needed.
// ══════════════════════════════════════════════════════════

enum FontScale {
  small(  factor: 0.85, label: 'صغير'),
  medium( factor: 1.00, label: 'متوسط'),
  large(  factor: 1.20, label: 'كبير');

  final double factor;
  final String label;
  const FontScale({required this.factor, required this.label});
}

// ── Provider ──────────────────────────────────────────────

final fontScaleProvider =
    StateNotifierProvider<FontScaleNotifier, FontScale>(
  (_) => FontScaleNotifier(),
);

// ── Notifier ──────────────────────────────────────────────

final class FontScaleNotifier extends StateNotifier<FontScale> {
  static const _tag = 'FontScaleNotifier';
  static const _key = 'font_scale';

  Box get _box => Hive.box(AppConstants.settingsBox);

  FontScaleNotifier() : super(FontScale.medium) {
    _load();
  }

  void _load() {
    try {
      final saved = _box.get(_key) as String?;
      final scale = FontScale.values.firstWhere(
        (s) => s.name == saved,
        orElse: () => FontScale.medium,
      );
      state = scale;
    } catch (e) {
      AppLogger.error(_tag, 'load', e);
    }
  }

  Future<void> set(FontScale scale) async {
    try {
      state = scale;
      await _box.put(_key, scale.name);
      AppLogger.info(_tag, 'Font scale → ${scale.label}');
    } catch (e) {
      AppLogger.error(_tag, 'set', e);
    }
  }
}
