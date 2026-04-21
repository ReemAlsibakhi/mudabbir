// ═══════════════════════════════════════════════════════════
// ExportPdfUseCase — Generate monthly report PDF
// ═══════════════════════════════════════════════════════════

import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';

final class ExportPdfUseCase {
  static const _tag = 'ExportPDF';

  Future<Result<String>> call({
    required String monthKey,
    required String userName,
    required double totalIncome,
    required double totalExpenses,
    required double balance,
    required double savingRate,
    required Map<String, double> categoryBreakdown,
  }) async {
    try {
      // Build PDF content
      final lines = <String>[
        'تقرير مدبّر المالي',
        'الاسم: $userName',
        'الشهر: $monthKey',
        '─────────────────',
        'الدخل:   ${totalIncome.toStringAsFixed(0)} ريال',
        'المصروف: ${totalExpenses.toStringAsFixed(0)} ريال',
        'الفائض:  ${balance.toStringAsFixed(0)} ريال',
        'الادخار: ${savingRate.toStringAsFixed(1)}%',
        '─────────────────',
        'التفصيل:',
        ...categoryBreakdown.entries
            .where((e) => e.value > 0)
            .map((e) => '  ${e.key}: ${e.value.toStringAsFixed(0)} ريال'),
      ];

      AppLogger.info(_tag, 'PDF generated for $monthKey');
      // Returns content string — actual PDF bytes built in service
      return Success(lines.join('\n'));
    } catch (e, st) {
      AppLogger.error(_tag, 'PDF generation error', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }
}
