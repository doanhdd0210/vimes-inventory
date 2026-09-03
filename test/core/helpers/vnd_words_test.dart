import 'package:flutter_test/flutter_test.dart';
import 'package:vimes_inventory/core/helpers/vnd_words.dart';

void main() {
  group('VndWords.of', () {
    final cases = <num, String>{
      0: 'Không đồng',
      1: 'Một đồng',
      5: 'Năm đồng',
      10: 'Mười đồng',
      11: 'Mười một đồng',
      15: 'Mười lăm đồng',
      21: 'Hai mươi mốt đồng',
      24: 'Hai mươi tư đồng',
      105: 'Một trăm lẻ năm đồng',
      100: 'Một trăm đồng',
      1000: 'Một nghìn đồng',
      1015: 'Một nghìn không trăm mười lăm đồng',
      1234000: 'Một triệu hai trăm ba mươi tư nghìn đồng',
      1000000: 'Một triệu đồng',
      1000000000: 'Một tỷ đồng',
      123456789:
          'Một trăm hai mươi ba triệu bốn trăm năm mươi sáu nghìn '
          'bảy trăm tám mươi chín đồng',
    };

    cases.forEach((amount, expected) {
      test('$amount → $expected', () {
        expect(VndWords.of(amount), expected);
      });
    });

    test('rounds fractional đồng', () {
      expect(VndWords.of(10.4), 'Mười đồng');
      expect(VndWords.of(10.5), 'Mười một đồng');
    });

    test('handles negatives', () {
      expect(VndWords.of(-1000), 'Âm một nghìn đồng');
    });
  });
}
