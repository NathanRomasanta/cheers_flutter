import 'package:cheers_flutter/pages/Menu.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:cheers_flutter/pages/Stock.dart';
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
          size: const NavigationPaneSize(compactWidth: 80),
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
                icon: const Icon(
                  Icons.point_of_sale,
                  color: Color(0xffFF6E1F),
                  size: 30,
                ),
                title: const Text("Home"),
                body: POSPage()),
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Home"),
                body: const Settings()),
            PaneItem(
                icon: const Icon(FluentIcons.stock_down),
                title: const Text("Stocks"),
                body: const BarStock()),
          ],
          selected: currentPage,
          onChanged: (index) => setState(() {
                currentPage = index;
              })),
    ));
  }
}
