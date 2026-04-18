import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

class HiveService {
  HiveService._();

  static late Box _settings;
  static late Box _income;
  static late Box _fixedExpenses;
  static late Box _dailyExpenses;
  static late Box _goals;
  static late Box _streak;

  static Future<void> init() async {
    _settings      = await Hive.openBox(HiveKeys.settings);
    _income        = await Hive.openBox(HiveKeys.income);
    _fixedExpenses = await Hive.openBox(HiveKeys.fixedExpenses);
    _dailyExpenses = await Hive.openBox(HiveKeys.dailyExpenses);
    _goals         = await Hive.openBox(HiveKeys.goals);
    _streak        = await Hive.openBox(HiveKeys.streak);
  }

  // ── Settings ──────────────────────────────
  static T getSetting<T>(String key, T defaultValue) =>
      _settings.get(key, defaultValue: defaultValue) as T;

  static Future<void> setSetting(String key, dynamic value) =>
      _settings.put(key, value);

  // ── Month key helper ──────────────────────
  static String monthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  static String get currentMonthKey {
    final now = DateTime.now();
    return monthKey(now.year, now.month);
  }

  // ── Income ───────────────────────────────
  static Map<String, dynamic> getIncome(String mk) {
    final raw = _income.get(mk);
    if (raw == null) return {'husband': 0.0, 'wife': 0.0, 'extra': 0.0};
    return Map<String, dynamic>.from(raw as Map);
  }

  static Future<void> saveIncome(String mk, Map<String, dynamic> data) =>
      _income.put(mk, data);

  static double getTotalIncome(String mk) {
    final i = getIncome(mk);
    return (i['husband'] as double? ?? 0) +
        (i['wife'] as double? ?? 0) +
        (i['extra'] as double? ?? 0);
  }

  // ── Fixed Expenses ────────────────────────
  static List<Map<String, dynamic>> getFixedExpenses() {
    final raw = _fixedExpenses.get('list');
    if (raw == null) return [];
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveFixedExpenses(List<Map<String, dynamic>> list) =>
      _fixedExpenses.put('list', list);

  static double getTotalFixed() =>
      getFixedExpenses().fold(0.0, (sum, e) => sum + (e['amount'] as double? ?? 0));

  // ── Daily Expenses ────────────────────────
  static List<Map<String, dynamic>> getDailyExpenses(String mk) {
    final raw = _dailyExpenses.get(mk);
    if (raw == null) return [];
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveDailyExpenses(String mk, List<Map<String, dynamic>> list) =>
      _dailyExpenses.put(mk, list);

  static Future<void> addDailyExpense(String mk, Map<String, dynamic> expense) async {
    final list = getDailyExpenses(mk);
    list.add(expense);
    await saveDailyExpenses(mk, list);
  }

  static Future<void> deleteDailyExpense(String mk, String id) async {
    final list = getDailyExpenses(mk);
    list.removeWhere((e) => e['id'] == id);
    await saveDailyExpenses(mk, list);
  }

  static double getTotalDaily(String mk) =>
      getDailyExpenses(mk).fold(0.0, (sum, e) => sum + (e['amount'] as double? ?? 0));

  static double getTotalExpenses(String mk) =>
      getTotalFixed() + getTotalDaily(mk);

  // Get today's expenses
  static List<Map<String, dynamic>> getTodayExpenses() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getDailyExpenses(currentMonthKey)
        .where((e) => e['date'] == todayStr)
        .toList();
  }

  // ── Goals ─────────────────────────────────
  static List<Map<String, dynamic>> getGoals() {
    final raw = _goals.get('list');
    if (raw == null) return [];
    return (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveGoals(List<Map<String, dynamic>> list) =>
      _goals.put('list', list);

  static Future<void> addGoal(Map<String, dynamic> goal) async {
    final list = getGoals();
    list.add(goal);
    await saveGoals(list);
  }

  static Future<void> updateGoal(String id, Map<String, dynamic> updatedGoal) async {
    final list = getGoals();
    final idx = list.indexWhere((g) => g['id'] == id);
    if (idx != -1) {
      list[idx] = updatedGoal;
      await saveGoals(list);
    }
  }

  static Future<void> deleteGoal(String id) async {
    final list = getGoals();
    list.removeWhere((g) => g['id'] == id);
    await saveGoals(list);
  }

  // ── Streak ────────────────────────────────
  static Map<String, dynamic> getStreak() {
    final raw = _streak.get('data');
    if (raw == null) return {'count': 0, 'lastDate': '', 'bestStreak': 0};
    return Map<String, dynamic>.from(raw as Map);
  }

  static Future<void> saveStreak(Map<String, dynamic> data) =>
      _streak.put('data', data);

  // ── Health Score ─────────────────────────
  static double calculateHealthScore(String mk) {
    final income = getTotalIncome(mk);
    if (income == 0) return 0;
    final expenses = getTotalExpenses(mk);
    final balance = income - expenses;
    final savingRate = (balance / income) * 100;
    if (savingRate >= 20) return 90 + (savingRate - 20).clamp(0, 10);
    if (savingRate >= 10) return 60 + (savingRate - 10) * 3;
    if (savingRate >= 0)  return 30 + savingRate * 3;
    return 0;
  }

  // ── Full Clear ────────────────────────────
  static Future<void> clearAll() async {
    await _settings.clear();
    await _income.clear();
    await _fixedExpenses.clear();
    await _dailyExpenses.clear();
    await _goals.clear();
    await _streak.clear();
  }
}
