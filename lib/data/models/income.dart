import 'package:hive/hive.dart';
part 'income.g.dart';

@HiveType(typeId: 1)
class Income extends HiveObject {
  @HiveField(0) String monthKey; // "2025-04"
  @HiveField(1) double primary;   // الزوج / الراتب الشخصي
  @HiveField(2) double secondary; // الزوجة
  @HiveField(3) double extra;     // دخل إضافي
  @HiveField(4) DateTime updatedAt;

  Income({
    required this.monthKey,
    this.primary = 0,
    this.secondary = 0,
    this.extra = 0,
    required this.updatedAt,
  });

  double get total => primary + secondary + extra;
}
