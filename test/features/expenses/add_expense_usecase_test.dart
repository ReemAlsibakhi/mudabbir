import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/expenses/domain/entities/expense.dart';
import 'package:mudabbir/features/expenses/domain/repositories/expense_repository.dart';
import 'package:mudabbir/features/expenses/domain/usecases/add_expense_usecase.dart';

class _FakeRepo implements ExpenseRepository {
  final List<Expense> added = [];
  @override Future<Result<void>> add(Expense e) async      { added.add(e); return const Success(null); }
  @override Future<Result<void>> delete(String id) async   => const Success(null);
  @override double totalByMonth(String k)                  => added.fold(0, (s, e) => s + e.amount);
  @override Stream<List<Expense>> watchByMonth(String k)   => const Stream.empty();
  @override List<Expense> getByDate(String m, String d)    => [];
  @override Stream<List<FixedExpense>> watchFixed()        => const Stream.empty();
  @override Future<Result<void>> addFixed(FixedExpense e) async => const Success(null);
  @override Future<Result<void>> deleteFixed(String id) async   => const Success(null);
  @override double totalFixed()                            => 0;
  @override List<FixedExpense> allActive()                 => [];
}

void main() {
  late _FakeRepo repo;
  late AddExpenseUseCase uc;
  final today = DateTime.now();

  setUp(() { repo = _FakeRepo(); uc = AddExpenseUseCase(repo); });

  group('Happy Path', () {
    test('adds valid expense', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'بقالة',
        amountRaw: '150', date: today,
      ));
      expect(r.isSuccess, true);
      expect(repo.added.length, 1);
      expect(repo.added.first.amount, 150.0);
    });

    test('uses category name when description empty', () async {
      await uc.call(AddExpenseParams(
        categoryId: 'food', name: '',
        amountRaw: '50', date: today,
      ));
      expect(repo.added.first.name, 'food');
    });
  });

  group('Unhappy Path', () {
    test('rejects zero amount', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '0', date: today));
      expect(r.isFailure, true);
    });

    test('rejects negative amount', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '-50', date: today));
      expect(r.isFailure, true);
    });

    test('rejects empty amount', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '', date: today));
      expect(r.isFailure, true);
    });

    test('rejects empty categoryId', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: '', name: 'test', amountRaw: '50', date: today));
      expect(r.isFailure, true);
    });
  });

  group('Edge Cases', () {
    test('rejects future date (+2 days)', () async {
      final future = today.add(const Duration(days: 2));
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '50', date: future));
      expect(r.isFailure, true);
    });

    test('rejects date older than 90 days', () async {
      final old = today.subtract(const Duration(days: 91));
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '50', date: old));
      expect(r.isFailure, true);
    });

    test('accepts today (boundary)', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '50', date: today));
      expect(r.isSuccess, true);
    });

    test('accepts 89 days ago (boundary)', () async {
      final old = today.subtract(const Duration(days: 89));
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '50', date: old));
      expect(r.isSuccess, true);
    });

    test('normalizes Arabic digits', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '١٥٠', date: today));
      expect(r.isSuccess, true);
      expect(repo.added.first.amount, 150.0);
    });

    test('rejects amount above 10M', () async {
      final r = await uc.call(AddExpenseParams(
        categoryId: 'food', name: 'test', amountRaw: '15000000', date: today));
      expect(r.isFailure, true);
    });
  });
}
