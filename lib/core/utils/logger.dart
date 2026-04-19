// ═══════════════════════════════════════════════════════════
// AppLogger — Structured logging (replace with logger pkg)
// ═══════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void info(String tag, String msg) {
    if (kDebugMode) debugPrint('ℹ️  [$tag] $msg');
  }

  static void warn(String tag, String msg) {
    if (kDebugMode) debugPrint('⚠️  [$tag] $msg');
  }

  static void error(String tag, String msg, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('🔴 [$tag] $msg');
      if (error != null) debugPrint('   Error: $error');
      if (st != null)    debugPrint('   Stack: $st');
    }
  }

  static void debug(String tag, String msg) {
    if (kDebugMode) debugPrint('🐛 [$tag] $msg');
  }
}
