import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';
import 'package:mudabbir/features/income/domain/entities/income.dart';
import 'package:mudabbir/features/income/domain/repositories/income_repository.dart';
import 'package:mudabbir/features/income/domain/usecases/save_income_usecase.dart';

class _FakeIncomeRepo implements IncomeRepository {
  Income? saved;
  @override Future<Result<void>> save(Income i) async { saved = i; return const Success(null); }
  @override Income getByMonth(String k) => Income.empty(k);
  @override Stream<Income> watchByMonth(String k) => const Stream.empty();
  @override List<Income> getLastMonths(String k, {int count = 3}) => [];
}

void main() {
  late _FakeIncomeRepo repo;
  late SaveIncomeUseCase uc;

  setUp(() { repo = _FakeIncomeRepo(); uc = SaveIncomeUseCase(repo); });

  group('Happy path', () {
    test('saves valid income', () async {
      final r = await uc(const SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '8000'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 8000.0);
    });

    test('empty secondary = 0', () async {
      await uc(const SaveIncomeParams(monthKey: '2025-04', primaryRaw: '5000'));
      expect(repo.saved?.secondary, 0.0);
    });

    test('parses Arabic digits', () async {
      final r = await uc(const SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '٨٠٠٠'));
      expect(r.isSuccess, true);
      expect(repo.saved?.primary, 8000.0);
    });
  });

  group('Validation', () {
    test('rejects empty monthKey', () async {
      expect((await uc(const SaveIncomeParams(monthKey: '', primaryRaw: '5000'))).isFailure, true);
    });

    test('rejects bad monthKey format', () async {
      expect((await uc(const SaveIncomeParams(monthKey: '2025/04', primaryRaw: '5000'))).isFailure, true);
    });

    test('rejects negative primary', () async {
      expect((await uc(const SaveIncomeParams(monthKey: '2025-04', primaryRaw: '-100'))).isFailure, true);
    });

    test('rejects total above 10M', () async {
      expect((await uc(const SaveIncomeParams(
        monthKey: '2025-04', primaryRaw: '6000000',
        secondaryRaw: '5000000'))).isFailure, true);
    });
  });
}
