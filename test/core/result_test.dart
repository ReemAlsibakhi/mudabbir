import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/errors/result.dart';

void main() {
  group('Result<T>', () {
    test('Success.isSuccess = true', () {
      expect(const Success(42).isSuccess, true);
    });

    test('Fail.isFailure = true', () {
      expect(const Fail<int>(ValidationFailure('err')).isFailure, true);
    });

    test('Success.valueOrNull returns value', () {
      expect(const Success('hello').valueOrNull, 'hello');
    });

    test('Fail.valueOrNull returns null', () {
      expect(const Fail<String>(StorageFailure('err')).valueOrNull, isNull);
    });

    test('guard wraps async success', () async {
      final r = await Result.guard<int>(() async => 42);
      expect(r.isSuccess, true);
      expect(r.valueOrNull, 42);
    });

    test('guard wraps async exception', () async {
      final r = await Result.guard<int>(() async => throw Exception('boom'));
      expect(r.isFailure, true);
      expect(r.failureOrNull, isA<UnexpectedFailure>());
    });

    test('map transforms Success value', () {
      final r = const Success(10).map((v) => v * 2);
      expect(r.valueOrNull, 20);
    });

    test('map on Fail is pass-through', () {
      final r = const Fail<int>(ValidationFailure('err')).map((v) => v * 2);
      expect(r.isFailure, true);
    });
  });
}
