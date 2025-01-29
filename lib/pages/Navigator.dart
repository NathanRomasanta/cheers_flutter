import 'package:cheers_flutter/pages/Menu.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:cheers_flutter/pages/Stock.dart';
import 'package:cheers_flutter/pages/Stocks.dart';
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
          header: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
            child: SizedBox(
                height: 40,
                child: Image.asset(
                  'lib/assets/images/Logo.png',
                )),
          ),
          size: const NavigationPaneSize(openMaxWidth: 150),
          items: [
            PaneItem(
                icon: const Icon(
                  Icons.point_of_sale,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Order"),
                body: const POSPage()),
            PaneItem(
                icon: const Icon(
                  Icons.table_chart,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Stock"),
                body: const StocksPage()),
            PaneItem(
                icon: const Icon(
                  Icons.table_chart,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Stocks"),
                body: const BarStock()),
            PaneItem(
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Settings"),
                body: const Settings()),
          ],
          selected: currentPage,
          onChanged: (index) => setState(() {
                currentPage = index;
              })),
    ));
  }
}
