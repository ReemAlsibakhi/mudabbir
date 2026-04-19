import '../../../../core/errors/result.dart';
import '../entities/streak.dart';

abstract interface class StreakRepository {
  Streak               get();
  Future<Result<void>> save(Streak streak);
  Future<Result<void>> reset();
}
