import '../../../../core/constants/app_strings.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../reports/domain/entities/monthly_report.dart';

final class PdfService {
  static const _tag = 'PdfService';

  Future<Result<File>> generateMonthlyReport({
    required MonthlyReport      report,
    required String             userName,
    required String             currency,
    required Map<String,double> categoryBreakdown,
  }) async {
    try {
      // ── Sort categories ───────────────────────────────
      final sortedCats = categoryBreakdown.entries
          .where((e) => e.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // ── Build category lines (String list) ───────────
      final catLines = sortedCats
          .map((e) => '  ${e.key.padLeft(16)}: ${e.value.toStringAsFixed(0)} $currency')
          .toList();

      // ── Build goal lines ─────────────────────────────
      final goalLines = report.goals
          .map((g) =>
            '  ${g.type.icon} ${g.name}: '
            '${g.saved.toStringAsFixed(0)}/${g.target.toStringAsFixed(0)} '
            '(${(g.progress * 100).toStringAsFixed(0)}%)')
          .toList();

      // ── Assemble report ───────────────────────────────
      final lines = <String>[
        '═══════════════════════════════════',
        AppStrings.pdfTitle,
        '═══════════════════════════════════',
        '',
        'الاسم:    $userName',
        'الشهر:    ${report.monthKey}',
        'العملة:   $currency',
        '',
        AppStrings.pdfSummaryHeader,
        'الدخل:              ${report.totalIncome.toStringAsFixed(0)} $currency',
        'المصاريف الثابتة:   ${report.totalFixed.toStringAsFixed(0)} $currency',
        'المصاريف المتغيرة:  ${report.totalVariable.toStringAsFixed(0)} $currency',
        'الإجمالي:           ${report.totalExpenses.toStringAsFixed(0)} $currency',
        'الفائض:             ${report.balance.toStringAsFixed(0)} $currency',
        'نسبة الادخار:       ${report.savingRate.toStringAsFixed(1)}%',
        '',
        AppStrings.pdfPersonaHeader,
        '${report.personaIcon} ${report.personaName}',
        report.personaDesc,
        '',
        AppStrings.pdfBreakHeader,
        ...catLines,
        '',
        AppStrings.pdfGoalsHeader,
        ...goalLines,
        '',
        '═══════════════════════════════════',
        AppStrings.pdfAppFooter,
        '═══════════════════════════════════',
      ];

      final content = lines.join('\n');
      final dir     = await getApplicationDocumentsDirectory();
      final file    = File('${dir.path}/mudabbir_${report.monthKey}.txt');
      await file.writeAsString(content);

      AppLogger.info(_tag, 'Report saved: ${file.path}');
      return Success(file);
    } catch (e, st) {
      AppLogger.error(_tag, 'generateReport error', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }
}
