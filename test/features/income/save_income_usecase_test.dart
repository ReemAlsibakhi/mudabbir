import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/income/domain/entities/income.dart';
import 'package:mudabbir/features/income/domain/repositories/income_repository.dart';
import 'package:mudabbir/features/income/domain/usecases/save_income_usecase.dart';

class _FakeRepo implements IncomeRepository {
  Income? saved;
  @override Income getByMonth(String k)               => saved ?? Income.empty(k);
  @override Stream<Income> watchByMonth(String k)     => const Stream.empty();
  @override Future<Result<void>> save(Income i) async  { saved = i; return const Success(null); }
  @override List<Income> getLastMonths(String k, {int count=3}) => [];
}

class _FailingRepo extends _FakeRepo {
  @override Future<Result<void>> save(Income i) async =>
      const Fail(StorageFailure('Disk full'));
}

void main() {
  late _FakeRepo repo;
  late SaveIncomeUseCase uc;

  setUp(() { repo = _FakeRepo(); uc = SaveIncomeUseCase(repo); });

  group('Happy Path', () {
    test('saves valid income', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '8000'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 8000.0);
    });

    test('saves dual income', () async {
      final r = await uc.call(SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '10000',
        secondaryRaw: '7000', extraRaw: '500',
      ));
      expect(r.isSuccess, true);
      expect(repo.saved?.total, 17500.0);
    });

    test('empty secondary treated as zero', () async {
      final r = await uc.call(SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '5000', secondaryRaw: ''));
      expect(r.isSuccess, true);
      expect(repo.saved?.secondary, 0.0);
    });
  });

  group('Unhappy Path', () {
    test('fails on empty monthKey', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '', primaryRaw: '5000'));
      expect(r.isFailure, true);
      expect(r.failureOrNull, isA<ValidationFailure>());
    });

    test('fails on letters in amount', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: 'abc'));
      expect(r.isFailure, true);
    });

    test('fails on negative income', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '-500'));
      expect(r.isFailure, true);
    });

    test('propagates storage failure', () async {
      final r = await SaveIncomeUseCase(_FailingRepo()).call(
        SaveIncomeParams(monthKey: '2025-04', primaryRaw: '5000'));
      expect(r.isFailure, true);
      expect(r.failureOrNull, isA<StorageFailure>());
    });
  });

  group('Edge Cases', () {
    test('normalizes Arabic digits ١٢٣٤', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '١٢٣٤'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 1234.0);
    });

    test('handles Arabic decimal separator ٫', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '1234٫5'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 1234.5);
    });

    test('strips thousands comma', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '1,500'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 1500.0);
    });

    test('rejects income above 10 million', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025-04', primaryRaw: '15000000'));
      expect(r.isFailure, true);
    });

    test('all zeros is valid (clearing income)', () async {
      final r = await uc.call(SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '0', secondaryRaw: '0', extraRaw: '0'));
      expect(r.isSuccess, true);
    });

    test('malformed monthKey format rejected', () async {
      final r = await uc.call(SaveIncomeParams(monthKey: '2025/04', primaryRaw: '5000'));
      expect(r.isFailure, true);
    });
  });

  group('Income Entity', () {
    test('savingRate = 0 when income is 0 (no division by zero)', () {
      expect(Income.empty('2025-04').savingRate(1000), 0.0);
    });

    test('savingRate clamped to -100 on heavy deficit', () {
      final i = Income(monthKey: '2025-04', primary: 100, updatedAt: DateTime.now());
      expect(i.savingRate(500), -100.0);
    });

    test('copyWith clamps negative to 0', () {
      expect(Income.empty('2025-04').copyWith(primary: -100).primary, 0.0);
    });

    test('balance is correct', () {
      final i = Income(monthKey: '2025-04', primary: 5000, updatedAt: DateTime.now());
      expect(i.balance(3000), 2000.0);
    });

    test('isDeficit when expenses exceed income', () {
      final i = Income(monthKey: '2025-04', primary: 1000, updatedAt: DateTime.now());
      expect(i.isDeficit(2000), true);
    });
  });
}
