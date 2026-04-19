import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/features/daily/domain/entities/streak.dart';

void main() {
  group('Streak Entity', () {
    test('markLogged increments count', () {
      final s = const Streak(count: 5).markLogged();
      expect(s.count, 6);
      expect(s.loggedToday, true);
    });

    test('markLogged on fresh streak starts at 1', () {
      final s = const Streak().markLogged();
      expect(s.count, 1);
    });

    test('markLogged is idempotent (cannot log twice same day)', () {
      final s1 = const Streak().markLogged();
      final s2 = s1.markLogged(); // same day
      expect(s2.count, s1.count);
    });

    test('useRescueToken does nothing with 0 tokens', () {
      final s = const Streak(count: 5, rescueTokens: 0);
      final s2 = s.useRescueToken();
      expect(s2.rescueTokens, 0);
      expect(s2.count, 5);
    });

    test('useRescueToken decrements tokens', () {
      final s = const Streak(count: 5, rescueTokens: 2, lastLogDate: '2000-01-01');
      final s2 = s.useRescueToken();
      expect(s2.rescueTokens, 1);
    });

    test('isAtRisk false when count is 0', () {
      expect(const Streak(count: 0).isAtRisk, false);
    });

    test('loggedToday false on fresh streak', () {
      expect(const Streak().loggedToday, false);
    });

    test('bestCount updated on new record', () {
      final s = const Streak(count: 9, bestCount: 9).markLogged();
      expect(s.bestCount, 10);
    });

    test('bestCount not reduced on lower count', () {
      // Simulate break: count reset to 1
      final s = const Streak(count: 1, bestCount: 50).markLogged();
      expect(s.bestCount, 50); // best preserved
    });
  });
}
