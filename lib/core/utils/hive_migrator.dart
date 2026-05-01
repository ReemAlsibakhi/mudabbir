// ═══════════════════════════════════════════════════════════
// HiveMigrator — schema versioning for safe app updates
//
// HOW TO ADD A MIGRATION:
//   1. Bump _kCurrentVersion
//   2. Add a case to _runMigrations()
//   3. Document what changed and why
//
// Run in bootstrap.dart AFTER opening all boxes.
// ═══════════════════════════════════════════════════════════

import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import 'logger.dart';

abstract final class HiveMigrator {
  static const _tag        = 'HiveMigrator';
  static const _versionKey = 'hive_schema_version';
  static const _kCurrentVersion = 1;

  static Future<void> run() async {
    final box     = Hive.box(AppConstants.settingsBox);
    final current = box.get(_versionKey, defaultValue: 0) as int;

    if (current >= _kCurrentVersion) {
      AppLogger.info(_tag, 'Schema v$current — no migration needed');
      return;
    }

    AppLogger.info(_tag, 'Migrating v$current → v$_kCurrentVersion');

    for (var v = current + 1; v <= _kCurrentVersion; v++) {
      await _runMigration(v, box);
    }

    await box.put(_versionKey, _kCurrentVersion);
    AppLogger.info(_tag, 'Migration complete → v$_kCurrentVersion');
  }

  static Future<void> _runMigration(int version, Box settingsBox) async {
    switch (version) {
      case 1:
        // v1 — initial schema (no-op; establishes version baseline)
        // All existing installs start at v0 (unversioned) and migrate here.
        // Future migrations should add transformations here.
        AppLogger.info(_tag, 'v1: baseline migration (no-op)');

      // case 2:
      //   // v2 — added 'currency' field to UserModel
      //   // For users upgrading from v1, default currency = 'SAR'
      //   final userBox = Hive.box<UserModel>(AppConstants.userBox);
      //   for (final key in userBox.keys) {
      //     final user = userBox.get(key);
      //     if (user != null && user.currency.isEmpty) {
      //       await userBox.put(key, user.copyWith(currency: 'SAR'));
      //     }
      //   }

      default:
        AppLogger.warn(_tag, 'Unknown migration version: $version');
    }
  }
}
