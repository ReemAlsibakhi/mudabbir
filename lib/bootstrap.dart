import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'shared/data/models/expense_model.dart';
import 'shared/data/models/fixed_expense_model.dart';
import 'shared/data/models/goal_model.dart';
import 'shared/data/models/user_model.dart';

abstract final class Bootstrap {
  static Future<void> init() async {
    AppLogger.info('Bootstrap', 'Initializing...');
    await Future.wait([_initHive(), _initSystemUI()]);
    tz.initializeTimeZones();
    AppLogger.info('Bootstrap', 'Ready ✅');
  }

  static Future<void> _initHive() async {
    await Hive.initFlutter();
    _safe(UserModelAdapter());
    _safe(ExpenseModelAdapter());
    _safe(FixedExpenseModelAdapter());
    _safe(GoalModelAdapter());
    await Future.wait([
      Hive.openBox<UserModel>(AppConstants.userBox),
      Hive.openBox<ExpenseModel>(AppConstants.dailyExpensesBox),
      Hive.openBox<FixedExpenseModel>(AppConstants.fixedExpensesBox),
      Hive.openBox<GoalModel>(AppConstants.goalsBox),
      Hive.openBox(AppConstants.settingsBox),
      Hive.openBox(AppConstants.incomeBox),
    ]);
  }

  static void _safe<T>(TypeAdapter<T> a) {
    if (!Hive.isAdapterRegistered(a.typeId)) Hive.registerAdapter(a);
  }

  static Future<void> _initSystemUI() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }
}
