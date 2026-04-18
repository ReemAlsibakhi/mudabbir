import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'income — سيتم بناؤه في الجلسة التالية',
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
