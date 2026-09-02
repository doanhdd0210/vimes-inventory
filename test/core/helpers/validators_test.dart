import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/helpers/validators.dart';

void main() {
  group('required', () {
    test('rejects null / blank', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('  '), isNotNull);
    });
    test('accepts non-blank', () {
      expect(Validators.required('x'), isNull);
    });
  });

  group('email', () {
    test('accepts a valid address', () {
      expect(Validators.email('a.b+c@example.co'), isNull);
    });
    test('rejects an invalid address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('positiveNumber', () {
    test('accepts positive, comma decimal', () {
      expect(Validators.positiveNumber('12,5'), isNull);
    });
    test('rejects zero and non-numbers', () {
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('abc'), isNotNull);
    });
  });

  test('combine returns the first error', () {
    final validate = Validators.combine([
      (v) => Validators.required(v),
      (v) => Validators.minLength(v, 3),
    ]);
    expect(validate(''), Validators.required(''));
    expect(validate('ab'), Validators.minLength('ab', 3));
    expect(validate('abc'), isNull);
  });
}
