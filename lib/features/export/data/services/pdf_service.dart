import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../reports/domain/entities/monthly_report.dart';

final class PdfService {
  static const _tag = 'PdfService';

  Future<Result<File>> generateMonthlyReport({
    required MonthlyReport report,
    required String        userName,
    required String        currency,
    required Map<String,double> categoryBreakdown,
  }) async {
    try {
      // Build text report (PDF package optional — fallback to structured text)
      final lines = <String>[
        '═══════════════════════════════════',
        '        تقرير مدبّر المالي',
        '═══════════════════════════════════',
        '',
        'الاسم:    $userName',
        'الشهر:    ${report.monthKey}',
        'العملة:   $currency',
        '',
        '── الملخص ──────────────────────────',
        'الدخل:           ${report.totalIncome.toStringAsFixed(0)} $currency',
        'المصاريف الثابتة: ${report.totalFixed.toStringAsFixed(0)} $currency',
        'المصاريف المتغيرة: ${report.totalVariable.toStringAsFixed(0)} $currency',
        'الإجمالي:        ${report.totalExpenses.toStringAsFixed(0)} $currency',
        'الفائض:          ${report.balance.toStringAsFixed(0)} $currency',
        'نسبة الادخار:    ${report.savingRate.toStringAsFixed(1)}%',
        '',
        '── الشخصية المالية ─────────────────',
        '${report.personaIcon} ${report.personaName}',
        report.personaDesc,
        '',
        '── تفصيل المصاريف ──────────────────',
        ...categoryBreakdown.entries
            .where((e) => e.value > 0)
            .toList()
          ..sort((a,b) => b.value.compareTo(a.value))
          ..map((e) =>
            '  ${e.key.padLeft(16)}: ${e.value.toStringAsFixed(0)} $currency'),
        '',
        '── الأهداف ─────────────────────────',
        ...report.goals.map((g) =>
          '  ${g.type.icon} ${g.name}: '
          '${g.saved.toStringAsFixed(0)}/${g.target.toStringAsFixed(0)} '
          '(${(g.progress * 100).toStringAsFixed(0)}%)'),
        '',
        '═══════════════════════════════════',
        '  مدبّر — تطبيق المصروف العائلي العربي',
        '═══════════════════════════════════',
      ];

      final content = lines.join('\n');
      final dir     = await getApplicationDocumentsDirectory();
      final file    = File('${dir.path}/mudabbir_${report.monthKey}.txt');
      await file.writeAsString(content, encoding: SystemEncoding());

      AppLogger.info(_tag, 'Report saved: ${file.path}');
      return Success(file);
    } catch (e, st) {
      AppLogger.error(_tag, 'generateReport error', e, st);
      return Fail(UnexpectedFailure(e.toString()));
    }
  }
}
