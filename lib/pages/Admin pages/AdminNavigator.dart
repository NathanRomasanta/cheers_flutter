import 'package:cheers_flutter/pages/Admin%20pages/AdminCreation.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminHome.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminInventory.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminItemCreation.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminOrders.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminPOSItemCreation.dart';
import 'package:cheers_flutter/pages/Admin%20pages/AdminSettings.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AdminNavigator extends StatefulWidget {
  const AdminNavigator({super.key});

  @override
  State<AdminNavigator> createState() => _AdminNavigatorState();
}

//adding comments just to test
class _AdminNavigatorState extends State<AdminNavigator> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        header: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
          child: SizedBox(
              height: 40,
              child: Image.asset(
                'lib/assets/images/Logo.png',
              )),
        ),
        size: const NavigationPaneSize(openMaxWidth: 175),
        selected: _selectedIndex,
        onChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          PaneItem(
              icon: const Icon(FluentIcons.home),
              title: const Text('Home'),
              body: const AdminHome()),
          PaneItem(
              icon: const Icon(FluentIcons.contact),
              title: const Text('Profile'),
              body: const AdminInventoryScreen()),
          PaneItem(
              icon: const Icon(FluentIcons.admin),
              title: const Text('Orders'),
              body: const InventoryOrders()),
          PaneItem(
              icon: const Icon(FluentIcons.contact),
              title: const Text('Add User'),
              body: const AdminCreation()),
          PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('POS Item Creation'),
              body: const POSItemCreationScreen()),
          PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Inventory Creation'),
              body: const AdminItemCreation()),
          PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: const AdminSettings()),
        ],
      ),
    );
  }
}
