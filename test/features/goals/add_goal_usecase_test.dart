import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/goals/domain/entities/goal.dart';
import 'package:mudabbir/features/goals/domain/repositories/goal_repository.dart';
import 'package:mudabbir/features/goals/domain/usecases/add_goal_usecase.dart';
import 'package:mudabbir/features/goals/domain/usecases/add_saving_usecase.dart';

class _FakeGoalRepo implements GoalRepository {
  final List<Goal> goals = [];
  @override List<Goal> getAll()                            => goals;
  @override Stream<List<Goal>> watchAll()                  => const Stream.empty();
  @override Future<Result<void>> save(Goal g) async        { goals.add(g); return const Success(null); }
  @override Future<Result<void>> delete(String id) async   => const Success(null);
  @override Future<Result<void>> addSaving(String id, double amount) async {
    final idx = goals.indexWhere((g) => g.id == id);
    if (idx < 0) return const Fail(NotFoundFailure('not found'));
    goals[idx] = goals[idx].copyWith(saved: goals[idx].saved + amount);
    return const Success(null);
  }
}

void main() {
  late _FakeGoalRepo repo;
  late AddGoalUseCase uc;

  setUp(() { repo = _FakeGoalRepo(); uc = AddGoalUseCase(repo); });

  group('Happy Path', () {
    test('adds goal by duration', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: 'منزل العائلة',
        targetRaw: '200000', mode: GoalInputMode.byDuration,
        durationMonths: 24,
      ));
      expect(r.isSuccess, true);
      expect(repo.goals.first.monthlyTarget, closeTo(200000/24, 1));
    });

    test('adds goal by monthly amount', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.car, name: 'سيارة',
        targetRaw: '60000', mode: GoalInputMode.byMonthlyAmount,
        monthlyAmountRaw: '2000',
      ));
      expect(r.isSuccess, true);
      expect(repo.goals.first.targetMonths, 30);
    });

    test('allows partial savings already accumulated', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.car, name: 'سيارة',
        targetRaw: '60000', savedRaw: '10000',
        mode: GoalInputMode.byDuration, durationMonths: 12,
      ));
      expect(r.isSuccess, true);
      expect(repo.goals.first.saved, 10000.0);
      expect(repo.goals.first.monthlyTarget, closeTo(50000/12, 1));
    });
  });

  group('Unhappy Path', () {
    test('rejects empty name', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: '',
        targetRaw: '100000', mode: GoalInputMode.byDuration,
        durationMonths: 12,
      ));
      expect(r.isFailure, true);
    });

    test('rejects zero target', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: 'هدف',
        targetRaw: '0', mode: GoalInputMode.byDuration,
        durationMonths: 12,
      ));
      expect(r.isFailure, true);
    });
  });

  group('Edge Cases', () {
    test('rejects saved > target', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: 'هدف',
        targetRaw: '100000', savedRaw: '150000',
        mode: GoalInputMode.byDuration, durationMonths: 12,
      ));
      expect(r.isFailure, true);
    });

    test('rejects duration > 600 months (50 years)', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: 'هدف',
        targetRaw: '100000', mode: GoalInputMode.byDuration,
        durationMonths: 601,
      ));
      expect(r.isFailure, true);
    });

    test('rejects if monthly would take > 100 years', () async {
      final r = await uc.call(AddGoalParams(
        type: GoalType.home, name: 'هدف',
        targetRaw: '100000000', mode: GoalInputMode.byMonthlyAmount,
        monthlyAmountRaw: '1',
      ));
      expect(r.isFailure, true);
    });

    test('AddSaving rejects adding to completed goal', () async {
      final addUC = AddGoalUseCase(repo);
      await addUC.call(AddGoalParams(
        type: GoalType.car, name: 'سيارة',
        targetRaw: '1000', savedRaw: '1000',
        mode: GoalInputMode.byDuration, durationMonths: 1,
      ));
      final goal = repo.goals.first;
      final savingUC = AddSavingUseCase(repo);
      final r = await savingUC.call(AddSavingParams(
        goalId: goal.id, amountRaw: '100'));
      expect(r.isFailure, true);
    });

    test('AddSaving rejects non-existent goal', () async {
      final savingUC = AddSavingUseCase(repo);
      final r = await savingUC.call(AddSavingParams(
        goalId: 'fake-id', amountRaw: '500'));
      expect(r.isFailure, true);
      expect(r.failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('Goal Entity', () {
    test('progress clamped 0-1', () {
      final g = Goal(id:'1', type:GoalType.car, name:'test',
        target: 100, saved: 150, createdAt: DateTime.now());
      expect(g.progress, 1.0);
    });

    test('remaining never negative', () {
      final g = Goal(id:'1', type:GoalType.car, name:'test',
        target: 100, saved: 200, createdAt: DateTime.now());
      expect(g.remaining, 0.0);
    });

    test('monthsLeft null when no monthlyTarget', () {
      final g = Goal(id:'1', type:GoalType.car, name:'test',
        target: 1000, saved: 0, createdAt: DateTime.now());
      expect(g.monthsLeft, null);
    });

    test('monthsLeft computed correctly', () {
      final g = Goal(id:'1', type:GoalType.car, name:'test',
        target: 1000, saved: 0, monthlyTarget: 200, createdAt: DateTime.now());
      expect(g.monthsLeft, 5);
    });
  });
}
