import 'package:flutter_test/flutter_test.dart';
import 'package:tennisnow/shared/domain/rating.dart';

/// Pure-domain tests for the Rating value object — no Flutter/codegen needed.
/// Guards the validation invariant that protects performance/mood/energy data.
void main() {
  group('Rating', () {
    test('accepts values within 1..5', () {
      for (var i = 1; i <= 5; i++) {
        expect(Rating(i).value, i);
      }
    });

    test('throws below the minimum', () {
      expect(() => Rating(0), throwsArgumentError);
    });

    test('throws above the maximum', () {
      expect(() => Rating(6), throwsArgumentError);
    });

    test('tryFrom returns null for null or out-of-range', () {
      expect(Rating.tryFrom(null), isNull);
      expect(Rating.tryFrom(0), isNull);
      expect(Rating.tryFrom(6), isNull);
      expect(Rating.tryFrom(3)?.value, 3);
    });

    test('equality is by value', () {
      expect(Rating(4), equals(Rating(4)));
      expect(Rating(4), isNot(equals(Rating(5))));
    });
  });
}
