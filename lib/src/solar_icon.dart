import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a Solar icon stored as an inline SVG template.
class SolarIcon extends StatelessWidget {
  const SolarIcon(
    this.svg, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// SVG template generated from the official Solar collection.
  final String svg;

  /// Width and height. Defaults to the surrounding [IconTheme].
  final double? size;

  /// Icon color. Native Solar opacity layers preserve duotone effects.
  final Color? color;

  /// Accessibility label announced by assistive technologies.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final resolvedSize = size ?? theme.size ?? 24;
    final resolvedColor = color ?? theme.color ?? const Color(0xFF1C274C);
    final renderedSvg = svg.replaceAll('{color}', _toHex(resolvedColor));

    return SvgPicture.string(
      renderedSvg,
      width: resolvedSize,
      height: resolvedSize,
      semanticsLabel: semanticLabel,
    );
  }

  static String _toHex(Color color) {
    final value = color.toARGB32() & 0x00FFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  @visibleForTesting
  static String toHexPublic(Color color) => _toHex(color);
}
