import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/arabic_parser.dart';
import '../../../../core/utils/logger.dart';
import '../entities/income.dart';
import '../repositories/income_repository.dart';

final class SaveIncomeParams extends Equatable {
  final String monthKey;
  final String primaryRaw;
  final String secondaryRaw;
  final String extraRaw;

  const SaveIncomeParams({
    required this.monthKey,
    required this.primaryRaw,
    this.secondaryRaw = '',
    this.extraRaw     = '',
  });

  @override
  List<Object?> get props => [monthKey, primaryRaw, secondaryRaw, extraRaw];
}

final class SaveIncomeUseCase {
  final IncomeRepository _repo;
  const SaveIncomeUseCase(this._repo);

  Future<Result<Income>> call(SaveIncomeParams p) async {
    // Validate monthKey format
    if (p.monthKey.isEmpty)
      return const Fail(ValidationFailure(AppStrings.fieldRequired));
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(p.monthKey))
      return const Fail(ValidationFailure(AppStrings.fieldRequired));

    // Parse all amounts — shared util handles Arabic digits, edge cases
    final primary   = ArabicParser.parseOptionalAmount(p.primaryRaw);
    final secondary = ArabicParser.parseOptionalAmount(p.secondaryRaw);
    final extra     = ArabicParser.parseOptionalAmount(p.extraRaw);

    if (primary.isFailure)   return Fail(primary.failureOrNull!);
    if (secondary.isFailure) return Fail(secondary.failureOrNull!);
    if (extra.isFailure)     return Fail(extra.failureOrNull!);

    final total = primary.valueOrNull! + secondary.valueOrNull! + extra.valueOrNull!;
    if (total > 10000000)
      return const Fail(ValidationFailure(AppStrings.amountTooLarge));

    final income = Income(
      monthKey:  p.monthKey,
      primary:   primary.valueOrNull!,
      secondary: secondary.valueOrNull!,
      extra:     extra.valueOrNull!,
      updatedAt: DateTime.now(),
    );

    AppLogger.info('SaveIncome', '${p.monthKey}: total=$total');
    final result = await _repo.save(income);
    return result.isSuccess ? Success(income) : Fail(result.failureOrNull!);
  }
}
