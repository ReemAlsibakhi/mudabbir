import 'package:equatable/equatable.dart';

final class Streak extends Equatable {
  final int    count;
  final String lastLogDate; // "2025-04-18"
  final int    bestCount;
  final int    rescueTokens;

  const Streak({
    this.count         = 0,
    this.lastLogDate   = '',
    this.bestCount     = 0,
    this.rescueTokens  = 1,
  });

  bool get loggedToday {
    final today = _today();
    return lastLogDate == today;
  }

  bool get isAtRisk {
    if (count == 0) return false;
    final now       = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final yStr      = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
    return lastLogDate != _today() && lastLogDate != yStr && count > 0;
  }

  String get statusMessage {
    if (count == 0)    return 'ابدأ سلسلتك اليوم!';
    if (count < 7)     return '$count أيام متواصلة 💪';
    if (count < 30)    return 'أنت من أفضل المستخدمين 🌟';
    return 'أسطوري! $count يوم بدون انقطاع 🏆';
  }

  String? get badgeLabel {
    if (count >= 30) return '🏆 أسطوري';
    if (count >= 7)  return '⭐ متميز';
    return null;
  }

  Streak markLogged() {
    final today = _today();
    if (lastLogDate == today) return this; // Edge: already logged
    final newCount = _wasYesterday() ? count + 1 : 1;
    final best     = newCount > bestCount ? newCount : bestCount;
    return Streak(
      count:        newCount,
      lastLogDate:  today,
      bestCount:    best,
      rescueTokens: rescueTokens,
    );
  }

  Streak useRescueToken() {
    if (rescueTokens <= 0) return this; // Edge: no tokens
    if (loggedToday)       return this; // Edge: already logged
    return markLogged().copyWith(rescueTokens: rescueTokens - 1);
  }

  Streak copyWith({int? count, String? lastLogDate, int? bestCount, int? rescueTokens}) =>
      Streak(
        count:        count        ?? this.count,
        lastLogDate:  lastLogDate  ?? this.lastLogDate,
        bestCount:    bestCount    ?? this.bestCount,
        rescueTokens: rescueTokens ?? this.rescueTokens,
      );

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  bool _wasYesterday() {
    final now  = DateTime.now();
    final yest = DateTime(now.year, now.month, now.day - 1);
    final yStr = '${yest.year}-${yest.month.toString().padLeft(2,'0')}-${yest.day.toString().padLeft(2,'0')}';
    return lastLogDate == yStr || lastLogDate.isEmpty; // Edge: first time
  }

  @override
  List<Object?> get props => [count, lastLogDate, bestCount, rescueTokens];
}
