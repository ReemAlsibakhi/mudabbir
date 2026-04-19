import '../../../../core/errors/result.dart';
import '../entities/goal.dart';

abstract interface class GoalRepository {
  Stream<List<Goal>>   watchAll();
  List<Goal>           getAll();
  Future<Result<void>> save(Goal goal);
  Future<Result<void>> delete(String id);
  Future<Result<void>> addSaving(String id, double amount);
}
