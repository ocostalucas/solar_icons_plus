import 'package:flutter/material.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';

import 'icon_registry.dart';

void main() => runApp(const SolarIconsGallery());

class SolarIconsGallery extends StatelessWidget {
  const SolarIconsGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solar Icons Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        useMaterial3: true,
      ),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String query = '';
  String style = 'all';

  List<SolarIconItem> get filtered => solarIconItems
      .where((item) {
        final matchesQuery = item.name.contains(query.trim().toLowerCase());
        final matchesStyle = style == 'all' || item.style == style;
        return matchesQuery && matchesStyle;
      })
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final items = filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Icons Plus'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search 7,608 icons',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => query = value),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: style,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All styles')),
                    DropdownMenuItem(value: 'linear', child: Text('Linear')),
                    DropdownMenuItem(value: 'outline', child: Text('Outline')),
                    DropdownMenuItem(value: 'broken', child: Text('Broken')),
                    DropdownMenuItem(value: 'bold', child: Text('Bold')),
                    DropdownMenuItem(
                      value: 'line-duotone',
                      child: Text('Line Duotone'),
                    ),
                    DropdownMenuItem(
                      value: 'bold-duotone',
                      child: Text('Bold Duotone'),
                    ),
                  ],
                  onChanged: (value) => setState(() => style = value ?? 'all'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${items.length} results'),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisExtent: 112,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _IconTile(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.item});
  final SolarIconItem item;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.iconData case final iconData?)
              Icon(iconData, size: 34, color: color)
            else if (item.svg case final svg?)
              SolarIcon(svg, size: 34, color: color),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(item.style, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
