import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';

import '../icon_registry.dart';

String styleToSuffix(String style) => style
    .split('-')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join();

String kebabToConst(String name) => name
    .split('-')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join();

void showIconDetailSheet(
  BuildContext context, {
  required SolarIconItem item,
  required double iconSize,
  required Widget iconPreview,
  required Color primaryColor,
  Color? secondaryColor,
  double? strokeWidth,
}) {
  String colorToHex(Color c) =>
      '0x${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  final primaryHex = colorToHex(primaryColor);
  final secondaryHex =
      secondaryColor != null ? colorToHex(secondaryColor) : null;

  String formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  final constName = '${kebabToConst(item.name)}${styleToSuffix(item.style)}';
  final isIconData = item.iconData != null;

  final sb = StringBuffer();
  if (isIconData) {
    sb.writeln('Icon(');
    sb.writeln('  SolarIcons.$constName,');
    sb.writeln('  size: ${iconSize.round()},');
    sb.writeln('  color: Color($primaryHex),');
    sb.writeln(')');
  } else {
    sb.writeln('SolarIcon(');
    sb.writeln('  SolarIcons.$constName,');
    sb.writeln('  size: ${iconSize.round()},');
    sb.writeln('  color: Color($primaryHex),');
    if (secondaryHex != null) {
      sb.writeln('  secondaryColor: Color($secondaryHex),');
    }
    if (strokeWidth != null) {
      sb.writeln('  strokeWidth: ${formatNumber(strokeWidth)},');
    }
    sb.writeln(')');
  }

  final code = sb.toString();

  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconPreview,
          const SizedBox(height: 16),
          Text(
            'SolarIcons.$constName',
            style: Theme.of(ctx).textTheme.titleMedium,
          ),
          Text(
            item.style.toUpperCase(),
            style: Theme.of(ctx).textTheme.labelSmall,
          ),
          if (isIconData) ...[
            const SizedBox(height: 4),
            Text(
              item.iconData!.codePoint.toRadixString(16),
              style: Theme.of(ctx).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: SolarIcon(SolarIcons.copyLinear, size: 18),
            label: const Text('Copy code'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
