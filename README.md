# solar_icons_plus

[![pub package](https://img.shields.io/pub/v/solar_icons_plus.svg)](https://pub.dev/packages/solar_icons_plus)
[![License: MIT](https://img.shields.io/badge/code-MIT-blue.svg)](LICENSE)
[![Icons: CC BY 4.0](https://img.shields.io/badge/icons-CC_BY_4.0-orange.svg)](LICENSE-THIRD-PARTY)

The complete [Solar icon set](https://icon-sets.iconify.design/solar/) for Flutter with native `IconData` for filled styles and faithful inline SVG rendering for stroke and duotone styles.

Live demo / Gallery: https://ocostalucas.github.io/solar_icons_plus/

<!-- GENERATED_CATALOG_START -->
Source: `@iconify-json/solar` **v1.2.10**

| Style | Icons |
| --- | ---: |
| BoldDuotone | 1268 |
| LineDuotone | 1268 |
| Linear | 1268 |
| Outline | 1268 |
| Broken | 1268 |
| Bold | 1268 |
| **Total** | **7608** |
<!-- GENERATED_CATALOG_END -->

## Installation

```yaml
dependencies:
  solar_icons_plus: ^1.0.0
```

## Usage

Filled-path variants use Flutter's native `Icon` widget:

```dart
import 'package:solar_icons_plus/solar_icons_plus.dart';

Icon(SolarIcons.heartBold, size: 32, color: const Color(0xFFE91E63))
Icon(SolarIcons.settingsOutline)
```

Stroke and duotone variants use `SolarIcon`. Original strokes and opacity layers are preserved:

```dart
SolarIcon(
  SolarIcons.home2BoldDuotone,
  size: 32,
  color: const Color(0xFF6C5CE7),
)

SolarIcon(SolarIcons.heartLineDuotone)
SolarIcon(SolarIcons.home2Linear)
SolarIcon(SolarIcons.userRoundedBroken)
```

For duotone styles (`BoldDuotone`, `LineDuotone`), you can tint the background
layer with `secondaryColor`. Elements rendered with an `opacity` attribute (the
duotone background) use this color; the foreground keeps `color`. When
`secondaryColor` is `null`, both layers share `color` and the native opacity
fade is kept:

```dart
SolarIcon(
  SolarIcons.home2BoldDuotone,
  size: 48,
  color: const Color(0xFF6C5CE7),
  secondaryColor: const Color(0xFFE0D9FF),
)
```

For stroke-based styles (`Linear`, `Broken`, `Line Duotone`) you can adjust the
line thickness with `strokeWidth`, clamped to a `0.5`–`3` range. When omitted,
the original template width (`1.5`) is kept:

```dart
SolarIcon(
  SolarIcons.home2Linear,
  size: 48,
  color: const Color(0xFF6C5CE7),
  strokeWidth: 3,
)
```

You can also import the classes for one style:

```dart
Icon(SolarIconsBold.heart)
SolarIcon(SolarIconsBoldDuotone.rocket)
SolarIcon(SolarIconsLinear.home2)
```

Both `Icon` and `SolarIcon` inherit size and color from `IconTheme`.

## Architecture

| Style | Representation | Widget |
| --- | --- | --- |
| Outline, Bold | Two icon fonts | `Icon` |
| Linear, Broken, Line Duotone, Bold Duotone | Inline SVG strings | `SolarIcon` |

The split keeps native Flutter ergonomics and font tree shaking where the source consists of filled paths. Stroke-based artwork stays SVG because TrueType icon fonts cannot represent SVG strokes faithfully.

## Licensing

Package source code is MIT licensed. The bundled Solar artwork was created by [480 Design](https://www.figma.com/community/file/1166831539721848736) and is distributed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), which requires attribution. See [LICENSE-THIRD-PARTY](LICENSE-THIRD-PARTY).
