import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/goals/domain/entities/goal.dart';
import 'package:mudabbir/features/goals/domain/repositories/goal_repository.dart';
import 'package:mudabbir/features/goals/domain/usecases/add_goal_usecase.dart';
import 'package:mudabbir/features/goals/domain/usecases/add_saving_usecase.dart';
import 'package:mudabbir/features/goals/presentation/providers/goals_notifier.dart';
import 'package:mudabbir/features/goals/presentation/providers/goals_state.dart';

class _FakeGoalRepo implements GoalRepository {
  final List<Goal> _goals = [];

  @override Stream<List<Goal>> watchAll() => Stream.value(List.from(_goals));
  @override List<Goal> getAll()            => List.from(_goals);

  @override Future<Result<void>> save(Goal g) async {
    _goals.add(g); return const Success(null);
  }
  @override Future<Result<void>> delete(String id) async {
    _goals.removeWhere((g) => g.id == id); return const Success(null);
  }
  @override Future<Result<void>> addSaving(String id, double amount) async {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i == -1) return const Fail(NotFoundFailure('not found'));
    _goals[i] = _goals[i].copyWith(saved: _goals[i].saved + amount);
    return const Success(null);
  }
}

ProviderContainer _container(_FakeGoalRepo repo) {
  final addUC    = AddGoalUseCase(repo);
  final saveUC   = AddSavingUseCase(repo);
  return ProviderContainer(overrides: [
    goalRepoProvider.overrideWithValue(repo),
    addGoalUseCaseProvider.overrideWithValue(addUC),
    addSavingUseCaseProvider.overrideWithValue(saveUC),
  ]);
}

void main() {
  late _FakeGoalRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo      = _FakeGoalRepo();
    container = _container(repo);
    addTearDown(container.dispose);
  });

  test('initial state is GoalsLoading', () {
    expect(container.read(goalsNotifierProvider), isA<GoalsLoading>());
  });

  test('addGoal returns null on success', () async {
    await Future.delayed(Duration.zero);
    final error = await container.read(goalsNotifierProvider.notifier).addGoal(
      const AddGoalParams(
        type: GoalType.home, name: 'منزل', targetRaw: '100000',
        mode: GoalInputMode.byDuration, durationMonths: 24,
      ),
    );
    expect(error, isNull);
    expect(repo.getAll().length, 1);
  });

  test('addGoal returns error on empty name', () async {
    await Future.delayed(Duration.zero);
    final error = await container.read(goalsNotifierProvider.notifier).addGoal(
      const AddGoalParams(
        type: GoalType.car, name: '', targetRaw: '50000',
        mode: GoalInputMode.byDuration, durationMonths: 12,
      ),
    );
    expect(error, isNotNull);
  });

  test('addGoal rejects saved > target', () async {
    await Future.delayed(Duration.zero);
    final error = await container.read(goalsNotifierProvider.notifier).addGoal(
      const AddGoalParams(
        type: GoalType.other, name: 'test', targetRaw: '1000',
        savedRaw: '5000', mode: GoalInputMode.byDuration, durationMonths: 6,
      ),
    );
    expect(error, isNotNull);
  });
}
