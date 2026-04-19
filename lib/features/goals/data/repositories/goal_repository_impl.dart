import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/data/models/goal_model.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

final class GoalRepositoryImpl implements GoalRepository {
  static const _tag = 'GoalRepo';
  Box<GoalModel> get _box => Hive.box<GoalModel>(AppConstants.goalsBox);

  @override
  Stream<List<Goal>> watchAll() => Stream.multi((c) {
    c.add(_getAll());
    final sub = _box.watch().listen(
      (_) { if (!c.isClosed) c.add(_getAll()); },
      onError: (e, st) {
        AppLogger.error(_tag, 'stream error', e, st as StackTrace);
        if (!c.isClosed) c.add([]);
      },
    );
    c.onCancel = sub.cancel;
  });

  @override
  List<Goal> getAll() => _getAll();

  List<Goal> _getAll() {
    try {
      return _box.values.map(_fromModel).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      AppLogger.error(_tag, 'getAll error', e);
      return [];
    }
  }

  @override
  Future<Result<void>> save(Goal g) => Result.guard(() => _box.put(g.id, _toModel(g)));

  @override
  Future<Result<void>> delete(String id) => Result.guard(() async {
    if (!_box.containsKey(id)) {
      AppLogger.warn(_tag, 'delete on non-existent: $id');
      return;
    }
    await _box.delete(id);
  });

  @override
  Future<Result<void>> addSaving(String id, double amount) => Result.guard(() async {
    final model = _box.get(id);
    if (model == null) throw const NotFoundFailure('الهدف غير موجود');

    final newSaved = (model.saved + amount).clamp(0.0, model.target);
    model
      ..saved     = newSaved
      ..completed = newSaved >= model.target;
    await model.save();
    AppLogger.info(_tag, 'addSaving $id += $amount → saved=${model.saved}');
  });

  // ── Mappers ───────────────────────────────────────────

  Goal _fromModel(GoalModel m) {
    try {
      return Goal(
        id:            m.id,
        type:          GoalType.fromString(m.type),
        name:          m.name.isNotEmpty ? m.name : '—',
        target:        m.target.clamp(0, double.infinity),
        saved:         m.saved.clamp(0, m.target),
        monthlyTarget: m.monthlyTarget.clamp(0, double.infinity),
        targetMonths:  m.targetMonths,
        createdAt:     m.createdAt,
        completed:     m.completed,
      );
    } catch (e) {
      AppLogger.error(_tag, 'fromModel error ${m.id}', e);
      return Goal(
        id: m.id, type: GoalType.other, name: m.name,
        target: m.target, createdAt: m.createdAt,
      );
    }
  }

  GoalModel _toModel(Goal g) => GoalModel(
    id: g.id, type: g.type.name, name: g.name,
    target: g.target, saved: g.saved, monthlyTarget: g.monthlyTarget,
    targetMonths: g.targetMonths, createdAt: g.createdAt, completed: g.completed,
  );
}
