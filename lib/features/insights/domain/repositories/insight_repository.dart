import '../entities/insight.dart';

// ══════════════════════════════════════════════════════════
// InsightRepository — manages dismissed insight IDs
// ══════════════════════════════════════════════════════════

abstract interface class InsightRepository {
  /// IDs dismissed by the user (cleared at midnight)
  Set<String> getDismissedIds();

  /// Mark an insight as dismissed for today
  Future<void> dismiss(String id);

  /// Clear all dismissals (called at app start on new day)
  Future<void> clearIfNewDay();
}
