class StreakData {
  final int count;
  final String lastDate;
  final int bestCount;
  final int rescueTokens;
  final List<String> noSpendDays;

  const StreakData({
    this.count = 0,
    this.lastDate = '',
    this.bestCount = 0,
    this.rescueTokens = 1,
    this.noSpendDays = const [],
  });

  StreakData copyWith({
    int? count, String? lastDate, int? bestCount,
    int? rescueTokens, List<String>? noSpendDays,
  }) => StreakData(
    count: count ?? this.count,
    lastDate: lastDate ?? this.lastDate,
    bestCount: bestCount ?? this.bestCount,
    rescueTokens: rescueTokens ?? this.rescueTokens,
    noSpendDays: noSpendDays ?? this.noSpendDays,
  );
}
