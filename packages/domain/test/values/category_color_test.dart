import 'package:pf_domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('CategoryColor', () {
    test('accepts #RRGGBB and bare RRGGBB', () {
      expect(CategoryColor('#1f8FFF').hex, '#1F8FFF');
      expect(CategoryColor('1f8FFF').hex, '#1F8FFF');
    });

    test('rejects wrong length', () {
      expect(() => CategoryColor('#FFF'), throwsArgumentError);
    });

    test('rejects non-hex', () {
      expect(() => CategoryColor('#ZZZZZZ'), throwsArgumentError);
    });

    test('exposes RGB channels', () {
      final c = CategoryColor('#1F8FFF');
      expect(c.red, 0x1F);
      expect(c.green, 0x8F);
      expect(c.blue, 0xFF);
    });
  });
}
