/// Generates the Solar Icons Plus fonts, Dart APIs, and example registry.
///
/// Run from the package root after `npm install`:
///
/// ```sh
/// dart run scripts/generate.dart
/// ```
library;

import 'dart:convert';
import 'dart:io';

const _sourceFile = 'node_modules/@iconify-json/solar/icons.json';
const _sourcePackageFile = 'node_modules/@iconify-json/solar/package.json';
const _fontPackage = 'solar_icons_plus';
const _tempDirectory = '.tmp';

const _styles = <_Style>[
  _Style('bold-duotone', 'BoldDuotone', usesSvg: true),
  _Style('line-duotone', 'LineDuotone', usesSvg: true),
  _Style('linear', 'Linear', usesSvg: true),
  _Style('outline', 'Outline'),
  _Style('broken', 'Broken', usesSvg: true),
  _Style('bold', 'Bold'),
];

const _reservedWords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'Function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

Future<void> main() async {
  final source = File(_sourceFile);
  if (!source.existsSync()) {
    stderr.writeln('Solar source not found. Run `npm install` first.');
    exitCode = 1;
    return;
  }

  final json = jsonDecode(source.readAsStringSync()) as Map<String, dynamic>;
  final defaultWidth = (json['width'] as num?)?.toDouble() ?? 24;
  final defaultHeight = (json['height'] as num?)?.toDouble() ?? 24;
  final rawIcons = json['icons'] as Map<String, dynamic>;
  final icons = <_SolarIcon>[];

  for (final MapEntry(key: name, value: raw) in rawIcons.entries) {
    final data = raw as Map<String, dynamic>;
    if (data['hidden'] == true) continue;
    final style = _styles.firstWhere(
      (candidate) => name.endsWith('-${candidate.slug}'),
      orElse: () => throw FormatException('Unknown Solar style: $name'),
    );
    final baseName = name.substring(0, name.length - style.slug.length - 1);
    icons.add(
      _SolarIcon(
        name: name,
        baseName: baseName,
        identifier: _identifier(baseName),
        body: data['body'] as String,
        width: (data['width'] as num?)?.toDouble() ?? defaultWidth,
        height: (data['height'] as num?)?.toDouble() ?? defaultHeight,
        style: style,
      ),
    );
  }

  icons.sort((a, b) => a.name.compareTo(b.name));
  _validateCatalog(icons);

  Directory('lib/fonts').createSync(recursive: true);
  Directory('lib/src/icons').createSync(recursive: true);

  for (final style in _styles.where((style) => !style.usesSvg)) {
    final styleIcons = icons.where((icon) => icon.style == style).toList();
    stdout.writeln('Generating ${style.label}: ${styleIcons.length} icons');
    _writeFontInput(style, styleIcons);
    await _generateFont(style);
    final codepoints = _readCodepoints(style);
    File(
      '$_tempDirectory/font/${style.slug}/${style.fontFamily}.ttf',
    ).copySync('lib/fonts/${style.fontFamily}.ttf');
    File(
      'lib/src/icons/solar_icons_plus_${style.fileSuffix}.dart',
    ).writeAsStringSync(_generateFontApi(style, styleIcons, codepoints));
  }

  for (final style in _styles.where((style) => style.usesSvg)) {
    final styleIcons = icons.where((icon) => icon.style == style).toList();
    stdout.writeln('Generating ${style.label}: ${styleIcons.length} icons');
    File(
      'lib/src/icons/solar_icons_plus_${style.fileSuffix}.dart',
    ).writeAsStringSync(_generateSvgApi(style, styleIcons));
    final staleFont = File('lib/fonts/${style.fontFamily}.ttf');
    if (staleFont.existsSync()) staleFont.deleteSync();
  }

  File(
    'lib/src/solar_icons.dart',
  ).writeAsStringSync(_generateAggregator(icons));
  File('lib/solar_icons_plus.dart').writeAsStringSync(_generateEntry(icons));

  final exampleDirectory = Directory('example/lib');
  if (exampleDirectory.existsSync()) {
    File(
      'example/lib/icon_registry.dart',
    ).writeAsStringSync(_generateRegistry(icons));
  }

  _updateReadme(icons);
  Directory(_tempDirectory).deleteSync(recursive: true);

  stdout.writeln('Generated ${icons.length} Solar icons successfully.');
  for (final style in _styles.reversed) {
    final count = icons.where((icon) => icon.style == style).length;
    stdout.writeln('  ${style.label}: $count');
  }
}

void _validateCatalog(List<_SolarIcon> icons) {
  if (icons.isEmpty) throw StateError('The Solar catalog is empty.');
  final names = <String>{};
  final identifiers = <String>{};
  for (final icon in icons) {
    if (!names.add(icon.name)) throw StateError('Duplicate icon: ${icon.name}');
    final apiName = '${icon.identifier}${icon.style.label}';
    if (!identifiers.add(apiName)) {
      throw StateError('Dart identifier collision: $apiName');
    }
  }
}

void _writeFontInput(_Style style, List<_SolarIcon> icons) {
  final directory = Directory('$_tempDirectory/svg/${style.slug}');
  directory.createSync(recursive: true);
  for (final icon in icons) {
    File(
      '${directory.path}/${icon.baseName}.svg',
    ).writeAsStringSync(_standaloneSvg(icon));
  }
}

String _standaloneSvg(_SolarIcon icon) {
  const em = 1024.0;
  const fillFactor = 0.85;
  final maxDimension = icon.width > icon.height ? icon.width : icon.height;
  final scale = em * fillFactor / maxDimension;
  final x = (em - icon.width * scale) / 2;
  final y = (em - icon.height * scale) / 2;
  final body = icon.body.replaceAll('currentColor', '#000000');
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">'
      '<g transform="translate(${x.toStringAsFixed(6)} ${y.toStringAsFixed(6)}) '
      'scale(${scale.toStringAsFixed(6)})">$body</g></svg>';
}

Future<void> _generateFont(_Style style) async {
  final output = '$_tempDirectory/font/${style.slug}';
  Directory(output).createSync(recursive: true);
  final result = await Process.run('node', <String>[
    'scripts/generate_font.js',
    '$_tempDirectory/svg/${style.slug}',
    output,
    style.fontFamily,
  ], runInShell: true);
  if (result.exitCode != 0) {
    throw ProcessException(
      'node',
      const [],
      '${result.stdout}\n${result.stderr}',
    );
  }
}

Map<String, int> _readCodepoints(_Style style) {
  final data =
      jsonDecode(
            File(
              '$_tempDirectory/font/${style.slug}/${style.fontFamily}.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return data.map((key, value) => MapEntry(key, value as int));
}

String _generateFontApi(
  _Style style,
  List<_SolarIcon> icons,
  Map<String, int> codepoints,
) {
  final output = StringBuffer()
    ..writeln('// GENERATED AUTOMATICALLY — DO NOT EDIT MANUALLY')
    ..writeln('// Source: @iconify-json/solar')
    ..writeln('// Style: ${style.label}; icons: ${icons.length}')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln('abstract class SolarIcons${style.label} {');
  for (final icon in icons) {
    final codepoint = codepoints[icon.baseName];
    if (codepoint == null) throw StateError('Missing codepoint: ${icon.name}');
    output
      ..writeln('  /// ${icon.baseName} (${style.slug})')
      ..writeln(
        "  static const IconData ${icon.identifier} = IconData("
        "0x${codepoint.toRadixString(16)}, fontFamily: '${style.fontFamily}', "
        "fontPackage: '$_fontPackage');",
      )
      ..writeln();
  }
  output.writeln('}');
  return output.toString();
}

String _generateSvgApi(_Style style, List<_SolarIcon> icons) {
  final output = StringBuffer()
    ..writeln('// GENERATED AUTOMATICALLY — DO NOT EDIT MANUALLY')
    ..writeln('// Source: @iconify-json/solar')
    ..writeln('// Style: ${style.label}; icons: ${icons.length}')
    ..writeln()
    ..writeln('abstract class SolarIcons${style.label} {');
  for (final icon in icons) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'viewBox="0 0 ${_number(icon.width)} ${_number(icon.height)}">'
        '${icon.body.replaceAll('currentColor', '{color}')}</svg>';
    output
      ..writeln('  /// ${icon.baseName} (${style.slug})')
      ..writeln("  static const String ${icon.identifier} = '${_escape(svg)}';")
      ..writeln();
  }
  output.writeln('}');
  return output.toString();
}

String _generateAggregator(List<_SolarIcon> icons) {
  final output = StringBuffer()
    ..writeln('// GENERATED AUTOMATICALLY — DO NOT EDIT MANUALLY')
    ..writeln('// Source: @iconify-json/solar')
    ..writeln();
  for (final style in _styles) {
    output.writeln(
      "import 'icons/solar_icons_plus_${style.fileSuffix}.dart' as ${style.alias};",
    );
  }
  output
    ..writeln()
    ..writeln('/// Flat access to every Solar icon and style.')
    ..writeln('abstract class SolarIcons {');
  final sorted = List<_SolarIcon>.from(icons)
    ..sort(
      (a, b) => '${a.identifier}${a.style.label}'.compareTo(
        '${b.identifier}${b.style.label}',
      ),
    );
  for (final icon in sorted) {
    final type = icon.style.usesSvg ? 'String' : 'IconData';
    output.writeln(
      '  static const $type ${icon.identifier}${icon.style.label} = '
      '${icon.style.alias}.SolarIcons${icon.style.label}.${icon.identifier};',
    );
  }
  output.writeln('}');
  return output.toString().replaceFirst(
    '// Source: @iconify-json/solar\n',
    "// Source: @iconify-json/solar\n\nimport 'package:flutter/widgets.dart';\n",
  );
}

String _generateEntry(List<_SolarIcon> icons) {
  final counts = <String, int>{
    for (final style in _styles)
      style.slug: icons.where((icon) => icon.style == style).length,
  };
  return '''// GENERATED AUTOMATICALLY — DO NOT EDIT MANUALLY
// Source: @iconify-json/solar
// Total: ${icons.length} icons
${_styles.map((style) => '//   ${style.label}: ${counts[style.slug]}').join('\n')}

export 'src/solar_icon.dart';
export 'src/solar_icons.dart';
${_styles.map((style) => "export 'src/icons/solar_icons_plus_${style.fileSuffix}.dart';").join('\n')}
''';
}

String _generateRegistry(List<_SolarIcon> icons) {
  final output = StringBuffer()
    ..writeln('// GENERATED AUTOMATICALLY — DO NOT EDIT MANUALLY')
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln("import 'package:solar_icons_plus/solar_icons_plus.dart';")
    ..writeln()
    ..writeln('class SolarIconItem {')
    ..writeln('  const SolarIconItem({')
    ..writeln('    required this.name,')
    ..writeln('    required this.style,')
    ..writeln('    this.iconData,')
    ..writeln('    this.svg,')
    ..writeln('  });')
    ..writeln('  final String name;')
    ..writeln('  final String style;')
    ..writeln('  final IconData? iconData;')
    ..writeln('  final String? svg;')
    ..writeln('}')
    ..writeln()
    ..writeln('const solarIconItems = <SolarIconItem>[');
  for (final icon in icons) {
    final property = '${icon.identifier}${icon.style.label}';
    final value = icon.style.usesSvg
        ? 'svg: SolarIcons.$property'
        : 'iconData: SolarIcons.$property';
    output.writeln(
      "  SolarIconItem(name: '${icon.baseName}', style: '${icon.style.slug}', $value),",
    );
  }
  output.writeln('];');
  return output.toString();
}

void _updateReadme(List<_SolarIcon> icons) {
  final file = File('README.md');
  if (!file.existsSync()) return;
  final package =
      jsonDecode(File(_sourcePackageFile).readAsStringSync())
          as Map<String, dynamic>;
  final counts = _styles
      .map((style) {
        final count = icons.where((icon) => icon.style == style).length;
        return '| ${style.label} | $count |';
      })
      .join('\n');
  final generated =
      '''<!-- GENERATED_CATALOG_START -->
Source: `@iconify-json/solar` **v${package['version']}**

| Style | Icons |
| --- | ---: |
$counts
| **Total** | **${icons.length}** |
<!-- GENERATED_CATALOG_END -->''';
  final contents = file.readAsStringSync();
  file.writeAsStringSync(
    contents.replaceFirst(
      RegExp(
        r'<!-- GENERATED_CATALOG_START -->.*<!-- GENERATED_CATALOG_END -->',
        dotAll: true,
      ),
      generated,
    ),
  );
}

String _identifier(String name) {
  final pieces = name.split(RegExp(r'[^a-zA-Z0-9]+'));
  var result = pieces.first.toLowerCase();
  for (final piece in pieces.skip(1)) {
    if (piece.isEmpty) continue;
    result += piece[0].toUpperCase() + piece.substring(1).toLowerCase();
  }
  if (RegExp(r'^\d').hasMatch(result)) result = 'i$result';
  if (_reservedWords.contains(result)) result = '${result}Icon';
  return result;
}

String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$');

String _number(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

class _Style {
  const _Style(this.slug, this.label, {this.usesSvg = false});
  final String slug;
  final String label;
  final bool usesSvg;
  String get fileSuffix => slug.replaceAll('-', '_');
  String get alias => fileSuffix;
  String get fontFamily => 'SolarIcons$label';
}

class _SolarIcon {
  const _SolarIcon({
    required this.name,
    required this.baseName,
    required this.identifier,
    required this.body,
    required this.width,
    required this.height,
    required this.style,
  });
  final String name;
  final String baseName;
  final String identifier;
  final String body;
  final double width;
  final double height;
  final _Style style;
}
