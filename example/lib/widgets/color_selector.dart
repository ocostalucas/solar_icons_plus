import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';

class ColorSelector extends StatelessWidget {
  final String label;
  final Color? selectedColor;
  final ValueChanged<Color?> onChanged;
  final bool showAuto;
  final Widget? trailing;
  final Widget? labelSuffix;

  const ColorSelector({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onChanged,
    this.showAuto = false,
    this.trailing,
    this.labelSuffix,
  });

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor ?? Colors.blue,
            onColorChanged: (c) => onChanged(c),
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final displayColor = selectedColor ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          if (labelSuffix != null) ...[const SizedBox(width: 4), labelSuffix!],
          const SizedBox(width: 8),
          if (showAuto)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onChanged(null),
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedColor == null
                          ? primary
                          : Colors.grey.shade300,
                      width: selectedColor == null ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Auto', style: TextStyle(fontSize: 10)),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => _openColorPicker(context),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: 2),
              ),
              child: const Icon(
                SolarIcons.paintBrushOutline,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
