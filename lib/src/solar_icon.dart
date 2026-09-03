import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a Solar icon stored as an inline SVG template.
class SolarIcon extends StatelessWidget {
  const SolarIcon(
    this.svg, {
    super.key,
    this.size,
    this.color,
    this.secondaryColor,
    this.strokeWidth,
    this.semanticLabel,
  });

  /// SVG template generated from the official Solar collection.
  final String svg;

  /// Width and height. Defaults to the surrounding [IconTheme].
  final double? size;

  /// Icon color. Native Solar opacity layers preserve duotone effects.
  final Color? color;

  /// Secondary color for the duotone layer (elements rendered with an
  /// `opacity` attribute). Only applies to duotone styles; when `null`, the
  /// [color] is used and the native opacity fade is preserved.
  final Color? secondaryColor;

  /// Stroke width for stroke-based styles (Linear, Broken, Line Duotone).
  /// Replaces every `stroke-width` in the template; when `null`, the original
  /// template width is kept. Accepted range: `0.5` to `3` (values outside are
  /// clamped). Ignored by filled styles (Bold, Outline).
  final double? strokeWidth;

  /// Accessibility label announced by assistive technologies.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final resolvedSize = size ?? theme.size ?? 24;
    final resolvedColor = color ?? theme.color ?? const Color(0xFF1C274C);
    final renderedSvg = applyColors(
      svg,
      resolvedColor,
      secondaryColor,
      strokeWidth: strokeWidth,
    );

    return SvgPicture.string(
      renderedSvg,
      width: resolvedSize,
      height: resolvedSize,
      semanticsLabel: semanticLabel,
    );
  }

  static const double minStrokeWidth = 0.5;
  static const double maxStrokeWidth = 3.0;

  /// Applies the template colors. When [secondary] is provided, elements that
  /// carry an `opacity` attribute (the duotone background layer) receive the
  /// secondary color; everything else uses [primary]. When [secondary] is
  /// `null`, all elements share [primary] and the native opacity fade remains.
  /// When [strokeWidth] is provided, every `stroke-width` in the template is
  /// replaced by it (clamped to [minStrokeWidth]..[maxStrokeWidth]).
  static String applyColors(
    String svg,
    Color primary,
    Color? secondary, {
    double? strokeWidth,
  }) {
    var result = svg;
    if (strokeWidth != null) {
      final width =
          strokeWidth.clamp(minStrokeWidth, maxStrokeWidth).toDouble();
      result = result.replaceAll(
        RegExp(r'stroke-width="[^"]*"'),
        'stroke-width="${_formatNumber(width)}"',
      );
    }

    final primaryHex = _toHex(primary);
    if (secondary == null) {
      return result.replaceAll('{color}', primaryHex);
    }
    final secondaryHex = _toHex(secondary);

    // Detect the inherited paint mode from the root <g> that carries the
    // template color (duotone icons paint either by fill or by stroke).
    final rootGroup = RegExp(r'<g\b[^>]*\{color\}[^>]*>')
        .firstMatch(result)
        ?.group(0);
    final isStrokeBased = rootGroup?.contains('stroke="{color}"') ?? false;
    final isFillBased = rootGroup?.contains('fill="{color}"') ?? false;

    final elementRe = RegExp(
      r'<(?:g|path|circle|ellipse|rect|line|polyline|polygon|use|text)\b[^>]*>',
    );
    final output = StringBuffer();
    var last = 0;
    for (final match in elementRe.allMatches(result)) {
      output.write(result.substring(last, match.start));
      var tag = match.group(0)!;
      if (tag.contains('opacity=')) {
        if (tag.contains('{color}')) {
          tag = tag.replaceAll('{color}', secondaryHex);
        } else if (isFillBased || isStrokeBased) {
          final paintAttr = isStrokeBased ? 'stroke' : 'fill';
          if (!tag.contains('$paintAttr=')) {
            final name = RegExp(r'^<(\w+)').firstMatch(tag)?.group(0);
            if (name != null) {
              tag = tag.replaceFirst(
                name,
                '$name $paintAttr="$secondaryHex"',
              );
            }
          }
        }
      }
      output.write(tag);
      last = match.end;
    }
    output.write(result.substring(last));
    return output.toString().replaceAll('{color}', primaryHex);
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  static String _toHex(Color color) {
    final value = color.toARGB32() & 0x00FFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  @visibleForTesting
  static String toHexPublic(Color color) => _toHex(color);
}
