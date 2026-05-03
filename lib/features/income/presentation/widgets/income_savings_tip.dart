import '../../../../core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/double_ext.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/ui/widgets/mud_insight_box.dart';
import '../../domain/entities/income.dart';

class IncomeSavingsTip extends StatelessWidget {
  final Income income;
  const IncomeSavingsTip({super.key, required this.income});

  @override
  Widget build(BuildContext context) {
    if (!income.hasIncome) return const SizedBox.shrink();

    final target20     = income.total * 0.20;
    final target20Year = income.total * 0.20 * 12;

    return MudInsightBox(
      type: InsightType.success,
      // ✅ Proper string interpolation — no adjacent concat with variable
      text: '${AppStrings.savingsTip20}${target20.fmt()} ${AppStrings.monthly}\n'
            '= ${target20Year.fmt()} ${AppStrings.yearly}',
    );
  }
}
