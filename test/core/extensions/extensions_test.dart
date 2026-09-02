import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/extensions/extensions.dart';

void main() {
  group('StringX', () {
    test('capitalized / titleCase', () {
      expect('hello world'.capitalized, 'Hello world');
      expect('hello world'.titleCase, 'Hello World');
    });
    test('truncate', () {
      expect('abcdef'.truncate(3), 'abc…');
      expect('ab'.truncate(3), 'ab');
    });
    test('isValidEmail', () {
      expect('a@b.co'.isValidEmail, isTrue);
      expect('a@b'.isValidEmail, isFalse);
    });
    test('NullableStringX', () {
      String? value;
      expect(value.isNullOrBlank, isTrue);
      expect(value.orEmpty(), '');
    });
  });

  group('DateTimeX', () {
    test('isSameDay / startOfDay', () {
      final a = DateTime(2026, 1, 1, 9);
      final b = DateTime(2026, 1, 1, 23);
      expect(a.isSameDay(b), isTrue);
      expect(a.startOfDay, DateTime(2026, 1, 1));
    });
  });

  group('IterableX', () {
    test('firstWhereOrNull', () {
      expect([1, 2, 3].firstWhereOrNull((e) => e.isEven), 2);
      expect(<int>[].firstWhereOrNull((e) => true), isNull);
    });
    test('groupBy', () {
      final grouped = [1, 2, 3, 4].groupBy((e) => e.isEven);
      expect(grouped[true], [2, 4]);
      expect(grouped[false], [1, 3]);
    });
  });

  group('NumX', () {
    test('asCurrencyVnd formats with grouping', () {
      expect(1234567.asCurrencyVnd.contains('1.234.567'), isTrue);
    });
  });
}
