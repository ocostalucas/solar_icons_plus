import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';

void main() {
  group('generated catalog', () {
    test('exposes all six styles', () {
      expect(SolarIcons.accessibilityLinear, isA<String>());
      expect(SolarIcons.accessibilityOutline, isA<IconData>());
      expect(SolarIcons.accessibilityBroken, isA<String>());
      expect(SolarIcons.accessibilityBold, isA<IconData>());
      expect(SolarIcons.accessibilityLineDuotone, isA<String>());
      expect(SolarIcons.accessibilityBoldDuotone, isA<String>());
    });

    test('font icons use their matching font families', () {
      expect(SolarIcons.accessibilityOutline.fontFamily, 'SolarIconsOutline');
      expect(SolarIcons.accessibilityBold.fontFamily, 'SolarIconsBold');
    });

    test('font icons declare the package', () {
      expect(SolarIcons.home2Outline.fontPackage, 'solar_icons_plus');
      expect(SolarIcons.home2Bold.fontPackage, 'solar_icons_plus');
    });

    test('SVG templates preserve strokes, color, and opacity', () {
      expect(SolarIcons.accessibilityLinear, contains('stroke'));
      expect(SolarIcons.accessibilityBroken, contains('{color}'));
      expect(SolarIcons.accessibilityBoldDuotone, contains('{color}'));
      expect(SolarIcons.accessibilityBoldDuotone, contains('opacity'));
    });
  });

  group('SolarIcon', () {
    test('converts colors to SVG hex', () {
      expect(SolarIcon.toHexPublic(const Color(0xFF6C5CE7)), '#6c5ce7');
    });

    testWidgets('renders a duotone SVG at the requested size', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SolarIcon(
            SolarIcons.accessibilityBoldDuotone,
            size: 40,
            color: Color(0xFF6C5CE7),
          ),
        ),
      );

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(picture.width, 40);
      expect(picture.height, 40);
      expect(tester.takeException(), isNull);
    });

    testWidgets('inherits size and color from IconTheme', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: IconTheme(
            data: IconThemeData(size: 36, color: Color(0xFF112233)),
            child: SolarIcon(SolarIcons.accessibilityLineDuotone),
          ),
        ),
      );

      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(picture.width, 36);
      expect(picture.height, 36);
    });
  });
}
