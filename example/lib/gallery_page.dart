import 'package:flutter/material.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'icon_demo_page.dart';
import 'icon_registry.dart';
import 'widgets/color_selector.dart';
import 'widgets/icon_detail_sheet.dart';

const kSolarStyles = <String>[
  'linear',
  'outline',
  'broken',
  'bold',
  'line-duotone',
  'bold-duotone',
];

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  String _query = '';
  double _iconSize = 32;
  double _strokeWidth = 1.5;
  Color _color = const Color(0xFF6C5CE7);
  Color? _secondaryColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: kSolarStyles.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<SolarIconItem> _filteredIcons(String? style) {
    var list = solarIconItems;
    if (style != null) {
      list = list.where((i) => i.style == style).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Widget _buildIcon(SolarIconItem item, {double? size}) {
    final s = size ?? _iconSize;
    if (item.iconData case final iconData?) {
      return Icon(iconData, size: s, color: _color);
    }
    return SolarIcon(
      item.svg!,
      size: s,
      color: _color,
      secondaryColor: _secondaryColor,
      strokeWidth: _strokeWidth,
    );
  }

  String _styleLabel(String style) {
    final parts = style.split('-');
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  Widget _buildGrid(String? style) {
    final icons = _filteredIcons(style);
    if (icons.isEmpty) {
      return const Center(child: Text('No icons found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final item = icons[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showIconDetailSheet(
            context,
            item: item,
            iconSize: _iconSize,
            iconPreview: _buildIcon(item, size: 64),
            primaryColor: _color,
            secondaryColor: _secondaryColor,
            strokeWidth: _strokeWidth,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(item),
              const SizedBox(height: 4),
              Text(
                item.name,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const pubDevUrl = 'https://pub.dev/packages/solar_icons_plus';
    const gitHubUrl = 'https://github.com/ocostalucas/solar_icons_plus';

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(276),
          child: Column(
            children: [
              // Title and links area
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Title + description (left)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'solar_icons_plus',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore and test icons',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    // Icons (right) linking to pub.dev and GitHub
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Open on pub.dev',
                          icon: const Icon(SolarIcons.linkOutline),
                          onPressed: () async {
                            final uri = Uri.parse(pubDevUrl);
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open the link $pubDevUrl',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'View on GitHub',
                          icon: const SolarIcon(SolarIcons.codeLinear),
                          onPressed: () async {
                            final uri = Uri.parse(gitHubUrl);
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open the link $gitHubUrl',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Open Icon Demo',
                          icon: Icon(SolarIcons.lightbulbBold),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const IconDemoPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search icons...',
                    prefixIcon: const Icon(SolarIcons.magnifierOutline),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(SolarIcons.closeCircleOutline),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorSelector(
                      label: 'Primary',
                      selectedColor: _color,
                      onChanged: (c) => setState(() {
                        if (c != null) _color = c;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Size', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${_iconSize.round()}',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _iconSize,
                              min: 16,
                              max: 64,
                              onChanged: (v) => setState(() => _iconSize = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ColorSelector(
                label: 'Secondary',
                selectedColor: _secondaryColor,
                onChanged: (c) => setState(() => _secondaryColor = c),
                showAuto: true,
                labelSuffix: Tooltip(
                  message: 'Only applies to duotone icons',
                  child: Icon(
                    SolarIcons.infoCircleOutline,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
                child: Row(
                  children: [
                    const Text('Stroke', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        _formatNumber(_strokeWidth),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth.clamp(0.5, 3.0),
                        min: 0.5,
                        max: 3.0,
                        divisions: 10,
                        onChanged: (v) => setState(() => _strokeWidth = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All (${_filteredIcons(null).length})'),
                  for (final style in kSolarStyles)
                    Tab(
                      text:
                          '${_styleLabel(style)} (${_filteredIcons(style).length})',
                    ),
                ],
                isScrollable: true,
                tabAlignment: TabAlignment.start,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrid(null),
          for (final style in kSolarStyles) _buildGrid(style),
        ],
      ),
    );
  }
}
