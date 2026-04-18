import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'daily — سيتم بناؤه في الجلسة التالية',
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
