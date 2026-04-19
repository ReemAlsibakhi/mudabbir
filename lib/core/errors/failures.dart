// ═══════════════════════════════════════════════════
// Failures — تعريف الأخطاء بشكل موحد
// ═══════════════════════════════════════════════════

sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class StorageFailure    extends Failure { const StorageFailure(super.message); }
final class ValidationFailure extends Failure { const ValidationFailure(super.message); }
final class NotFoundFailure   extends Failure { const NotFoundFailure(super.message); }
