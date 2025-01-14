import 'package:cheers_flutter/pages/Admin%20pages/AdminCreation.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminHome.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminInventory.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminItemCreation.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminSettings.dart';
import 'package:cheers_flutter/pages/Menu.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class AdminNavigator extends StatefulWidget {
  const AdminNavigator({super.key});

  @override
  State<AdminNavigator> createState() => _AdminNavigatorState();
}

//adding comments just to test
class _AdminNavigatorState extends State<AdminNavigator> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        home: NavigationView(
      pane: NavigationPane(
          toggleable: true,
          displayMode: PaneDisplayMode.auto,
          size: const NavigationPaneSize(
            openMaxWidth: 200,
          ),
          header: Container(
            child: SizedBox(height: 50),
          ),
          items: [
            PaneItem(
                icon: const Icon(Icons.folder),
                title: const Text("Home"),
                body: const AdminHome()),
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Settings"),
                body: const AdminSettings()),
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Creation"),
                body: const AdminCreation()),
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Item Creation"),
                body: const AdminCreation()),
            PaneItem(
                icon: const Icon(FluentIcons.add),
                title: const Text("Item Creation"),
                body: const AdminItemCreation()),
            PaneItem(
                icon: const Icon(FluentIcons.stock_down),
                title: const Text("Item Inventory"),
                body: const AdminInventoryScreen()),
          ],
          selected: currentPage,
          onChanged: (index) => setState(() {
                currentPage = index;
              })),
    ));
  }
}
