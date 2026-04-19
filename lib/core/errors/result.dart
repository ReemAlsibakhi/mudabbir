// ═══════════════════════════════════════════════════════════
// Result<T> — Explicit error handling without exceptions
// ═══════════════════════════════════════════════════════════

sealed class Result<T> {
  const Result();

  /// Wrap a Future that might throw
  static Future<Result<T>> guard<T>(Future<T> Function() fn) async {
    try {
      return Success(await fn());
    } on Failure catch (f) {
      return Fail(f);
    } catch (e) {
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  /// Wrap a sync operation
  static Result<T> guardSync<T>(T Function() fn) {
    try {
      return Success(fn());
    } on Failure catch (f) {
      return Fail(f);
    } catch (e) {
      return Fail(UnexpectedFailure(e.toString()));
    }
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Fail<T>;

  T? get valueOrNull    => switch (this) { Success(:final value) => value, _ => null };
  Failure? get failureOrNull => switch (this) { Fail(:final failure) => failure, _ => null };

  /// Transform success value
  Result<R> map<R>(R Function(T) transform) => switch (this) {
    Success(:final value) => Result.guardSync(() => transform(value)),
    Fail(:final failure)  => Fail(failure),
  };

  /// Execute on success
  Future<Result<T>> onSuccess(Future<void> Function(T) fn) async {
    if (this case Success(:final value)) await fn(value);
    return this;
  }

  /// Execute on failure
  Result<T> onFailure(void Function(Failure) fn) {
    if (this case Fail(:final failure)) fn(failure);
    return this;
  }
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Fail<T> extends Result<T> {
  final Failure failure;
  const Fail(this.failure);
}

// ── Failures ──────────────────────────────────────────────

sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

final class ValidationFailure  extends Failure { const ValidationFailure(super.message); }
final class StorageFailure     extends Failure { const StorageFailure(super.message); }
final class NotFoundFailure    extends Failure { const NotFoundFailure(super.message); }
final class PermissionFailure  extends Failure { const PermissionFailure(super.message); }
final class UnexpectedFailure  extends Failure { const UnexpectedFailure(super.message); }
