import 'package:cheers_flutter/pages/Menu.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class NavigatorGate extends StatefulWidget {
  const NavigatorGate({super.key});

  @override
  State<NavigatorGate> createState() => _NavigatorGateState();
}

class _NavigatorGateState extends State<NavigatorGate> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        home: NavigationView(
      pane: NavigationPane(
          displayMode: PaneDisplayMode.open,
          items: [
            PaneItem(
                icon: const Icon(Icons.folder),
                title: const Text("Home"),
                body: const MenuScreen()),
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Home"),
                body: const Settings()),
          ],
          selected: currentPage,
          onChanged: (index) => setState(() {
                currentPage = index;
              })),
    ));
  }
}
