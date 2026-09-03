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

    test('uses the primary color everywhere when no secondary is set', () {
      final svg =
          '<g fill="{color}"><path opacity=".5" d="a"/><path d="b"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        null,
      );
      expect(
        result,
        '<g fill="#6c5ce7"><path opacity=".5" d="a"/><path d="b"/></g>',
      );
      expect(result, isNot(contains('{color}')));
    });

    test('applies the secondary color to opacity elements only', () {
      final svg =
          '<g fill="{color}"><path opacity=".5" d="a"/><path d="b"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        const Color(0xFF111111),
      );
      expect(
        result,
        '<g fill="#6c5ce7"><path fill="#111111" opacity=".5" d="a"/><path d="b"/></g>',
      );
    });

    test('applies the secondary color to stroke-based duotone elements', () {
      final svg = '<g fill="none" stroke="{color}">'
          '<circle cx="12" cy="12" r="10" opacity=".5"/>'
          '<path d="m1 1"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        const Color(0xFF999999),
      );
      expect(
        result,
        '<g fill="none" stroke="#6c5ce7">'
        '<circle stroke="#999999" cx="12" cy="12" r="10" opacity=".5"/>'
        '<path d="m1 1"/></g>',
      );
    });

    test('replaces every stroke-width when a value is provided', () {
      final svg = '<g stroke-width="1.5">'
          '<path d="a"/><circle stroke-width="1.5" r="2"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        null,
        strokeWidth: 3,
      );
      expect(
        result,
        '<g stroke-width="3">'
        '<path d="a"/><circle stroke-width="3" r="2"/></g>',
      );
    });

    test('clamps stroke width to the 0.5..3 range', () {
      final svg = '<g stroke-width="1.5"><path d="a"/></g>';
      final low = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        null,
        strokeWidth: 0.1,
      );
      final high = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        null,
        strokeWidth: 10,
      );
      expect(low, contains('stroke-width="0.5"'));
      expect(high, contains('stroke-width="3"'));
      expect(SolarIcon.minStrokeWidth, 0.5);
      expect(SolarIcon.maxStrokeWidth, 3.0);
    });

    test('keeps the original stroke-width when none is provided', () {
      final svg = '<g stroke-width="1.5"><path d="a"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        null,
      );
      expect(result, contains('stroke-width="1.5"'));
    });

    test('works with secondary color and stroke width together', () {
      final svg = '<g fill="none" stroke="{color}" stroke-width="1.5">'
          '<circle r="10" opacity=".5"/>'
          '<path d="m1 1"/></g>';
      final result = SolarIcon.applyColors(
        svg,
        const Color(0xFF6C5CE7),
        const Color(0xFF999999),
        strokeWidth: 2.5,
      );
      expect(
        result,
        '<g fill="none" stroke="#6c5ce7" stroke-width="2.5">'
        '<circle stroke="#999999" r="10" opacity=".5"/>'
        '<path d="m1 1"/></g>',
      );
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
