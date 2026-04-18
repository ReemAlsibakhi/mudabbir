import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/goal.dart';

const _uuid = Uuid();

final goalsProvider = Provider<List<Goal>>((ref) {
  final box = Hive.box<Goal>(AppConstants.goalsBox);
  return box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final goalsActionsProvider = Provider((ref) => GoalsActions(ref));

class GoalsActions {
  final Ref _ref;
  GoalsActions(this._ref);

  Box<Goal> get _box => Hive.box<Goal>(AppConstants.goalsBox);

  Future<void> addGoal({
    required String type,
    required String name,
    required double target,
    double saved = 0,
    double monthlyTarget = 0,
    int? targetMonths,
    String? deadline,
  }) async {
    final id = _uuid.v4();
    final goal = Goal(
      id: id,
      type: type,
      name: name,
      target: target,
      saved: saved,
      monthlyTarget: monthlyTarget,
      targetMonths: targetMonths,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await _box.put(id, goal);
  }

  Future<void> addToGoal(String id, double amount) async {
    final goal = _box.get(id);
    if (goal == null) return;
    goal.saved = (goal.saved + amount).clamp(0, goal.target);
    if (goal.saved >= goal.target) goal.completed = true;
    await goal.save();
  }

  Future<void> deleteGoal(String id) async => await _box.delete(id);
}
