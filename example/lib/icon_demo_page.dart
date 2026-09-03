import 'package:flutter/material.dart';
import 'package:solar_icons_plus/solar_icons_plus.dart';

class IconDemoPage extends StatefulWidget {
  const IconDemoPage({super.key});

  @override
  State<IconDemoPage> createState() => _IconDemoPageState();
}

class _IconDemoPageState extends State<IconDemoPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icon Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Icon (Bold & Outline)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(SolarIcons.userOutline),
              SizedBox(width: 12),
              Icon(SolarIcons.heartBold, color: Colors.red),
              SizedBox(width: 12),
              Icon(SolarIcons.homeOutline),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'IconButton',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(SolarIcons.settingsOutline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IconButton pressed')),
              );
            },
          ),

          const SizedBox(height: 16),
          const Text(
            'TextField with prefixIcon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: SolarIcon(SolarIcons.minimalisticMagnifierLinear),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'SolarIcon (SVG styles)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              SolarIcon(SolarIcons.heartLinear, color: Colors.red, size: 32),
              SizedBox(width: 12),
              SolarIcon(
                SolarIcons.lightbulbBoldDuotone,
                color: Colors.orange,
                secondaryColor: Colors.white,
                size: 32,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'SolarIcon strokeWidth',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              SolarIcon(
                SolarIcons.home2Linear,
                color: Colors.indigo,
                size: 36,
              ),
              SizedBox(width: 16),
              SolarIcon(
                SolarIcons.home2Linear,
                color: Colors.indigo,
                size: 36,
                strokeWidth: 2.5,
              ),
              SizedBox(width: 16),
              SolarIcon(
                SolarIcons.home2Linear,
                color: Colors.indigo,
                size: 36,
                strokeWidth: 3,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'Buttons with Icons',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(SolarIcons.addOutline),
                label: const Text('Add'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(SolarIcons.downloadOutline),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(SolarIcons.shareOutline),
                label: const Text('Share'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'BottomNavigation (interactive)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Center(child: Text('Selected: $_selectedIndex')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(SolarIcons.homeOutline),
            activeIcon: Icon(SolarIcons.homeBold),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(SolarIcons.settingsOutline),
            activeIcon: Icon(SolarIcons.settingsBold),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(SolarIcons.userOutline),
            activeIcon: Icon(SolarIcons.userBold),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('FAB pressed'))),
        child: const Icon(SolarIcons.addBold),
      ),
    );
  }
}
