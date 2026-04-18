import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/models/income.dart';
import 'data/models/expense.dart';
import 'data/models/fixed_expense.dart';
import 'data/models/goal.dart';
import 'data/models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة المنطقة الزمنية
  tz.initializeTimeZones();

  // تهيئة Hive
  await Hive.initFlutter();

  // تسجيل adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(FixedExpenseAdapter());
  Hive.registerAdapter(GoalAdapter());

  // فتح الصناديق
  await Future.wait([
    Hive.openBox<UserProfile>(AppConstants.userBox),
    Hive.openBox<Income>(AppConstants.incomeBox),
    Hive.openBox<Expense>(AppConstants.dailyExpensesBox),
    Hive.openBox<FixedExpense>(AppConstants.fixedExpensesBox),
    Hive.openBox<Goal>(AppConstants.goalsBox),
    Hive.openBox(AppConstants.settingsBox),
  ]);

  // شاشة عمودية فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ألوان شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: MudabbirApp()));
}
