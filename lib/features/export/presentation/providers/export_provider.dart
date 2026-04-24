import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/logger.dart';
import '../../../reports/domain/entities/monthly_report.dart';
import '../../data/services/pdf_service.dart';

final pdfServiceProvider = Provider((_) => PdfService());

enum ExportStatus { idle, exporting, done, error }

final class ExportState {
  final ExportStatus status;
  final File?        file;
  final String?      error;
  const ExportState({this.status = ExportStatus.idle, this.file, this.error});
}

final exportNotifierProvider =
    StateNotifierProvider.autoDispose<ExportNotifier, ExportState>(
  (ref) => ExportNotifier(ref.watch(pdfServiceProvider)),
);

final class ExportNotifier extends StateNotifier<ExportState> {
  final PdfService _svc;
  ExportNotifier(this._svc) : super(const ExportState());

  Future<void> export({
    required MonthlyReport      report,
    required String             userName,
    required String             currency,
    required Map<String,double> categories,
  }) async {
    if (!mounted) return;
    state = const ExportState(status: ExportStatus.exporting);

    final result = await _svc.generateMonthlyReport(
      report: report, userName: userName,
      currency: currency, categoryBreakdown: categories,
    );

    if (!mounted) return;
    state = result.isSuccess
        ? ExportState(status: ExportStatus.done,  file: result.valueOrNull)
        : ExportState(status: ExportStatus.error, error: result.failureOrNull?.message);
  }

  void reset() => state = const ExportState();
}
