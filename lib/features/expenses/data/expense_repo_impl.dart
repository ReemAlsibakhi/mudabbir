import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/fixed_expense.dart';
import '../domain/expense_entity.dart';
import '../domain/expense_repository.dart';

const _uuid = Uuid();

final class ExpenseRepoImpl implements ExpenseRepository {
  Box<Expense>      get _box   => Hive.box<Expense>(AppConstants.dailyExpensesBox);
  Box<FixedExpense> get _fBox  => Hive.box<FixedExpense>(AppConstants.fixedExpensesBox);

  @override
  Stream<List<ExpenseEntity>> watchByMonth(String monthKey) => Stream.multi((c) {
    c.add(_byMonth(monthKey));
    final sub = _box.watch().listen((_) => c.add(_byMonth(monthKey)));
    c.onCancel = sub.cancel;
  });

  List<ExpenseEntity> _byMonth(String key) =>
      _box.values.where((e) => e.monthKey == key).map(_map).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<void> add(ExpenseEntity e) async {
    final id = e.id.isEmpty ? _uuid.v4() : e.id;
    await _box.put(id, Expense(
      id: id, categoryId: e.categoryId, name: e.name,
      amount: e.amount, date: e.date, monthKey: e.monthKey,
      createdAt: e.createdAt,
    ));
  }

  @override Future<void> delete(String id) => _box.delete(id);

  @override double totalByMonth(String k) =>
      _box.values.where((e) => e.monthKey == k).fold(0, (s, e) => s + e.amount);

  @override
  Stream<List<FixedExpenseEntity>> watchFixed() => Stream.multi((c) {
    c.add(_allFixed());
    final sub = _fBox.watch().listen((_) => c.add(_allFixed()));
    c.onCancel = sub.cancel;
  });

  List<FixedExpenseEntity> _allFixed() =>
      _fBox.values.where((e) => e.active).map(_mapFixed).toList();

  @override
  Future<void> addFixed(FixedExpenseEntity e) async {
    final id = e.id.isEmpty ? _uuid.v4() : e.id;
    await _fBox.put(id, FixedExpense(
      id: id, categoryId: e.categoryId, name: e.name,
      amount: e.amount, active: e.active, createdAt: DateTime.now(),
      dueDayOfMonth: e.dueDayOfMonth,
    ));
  }

  @override Future<void> deleteFixed(String id) => _fBox.delete(id);

  @override double totalFixed() =>
      _fBox.values.where((e) => e.active).fold(0, (s, e) => s + e.amount);

  ExpenseEntity _map(Expense m) => ExpenseEntity(
    id: m.id, categoryId: m.categoryId, name: m.name,
    amount: m.amount, date: m.date, monthKey: m.monthKey,
    createdAt: m.createdAt,
  );

  FixedExpenseEntity _mapFixed(FixedExpense m) => FixedExpenseEntity(
    id: m.id, categoryId: m.categoryId, name: m.name,
    amount: m.amount, active: m.active, dueDayOfMonth: m.dueDayOfMonth,
  );
}
