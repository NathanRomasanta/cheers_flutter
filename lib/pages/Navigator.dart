import 'package:cheers_flutter/pages/ItemAccounts.dart';
import 'package:cheers_flutter/pages/Menu.dart';
import 'package:cheers_flutter/pages/Payment.dart';
import 'package:cheers_flutter/pages/Settings.dart';
import 'package:cheers_flutter/pages/Orders.dart';
import 'package:cheers_flutter/pages/Stocks.dart';
import 'package:cheers_flutter/pages/Transactions.dart';
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
          toggleable: true,
          header: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
            child: SizedBox(
                height: 40,
                child: Image.asset(
                  'lib/assets/images/Logo.png',
                )),
          ),
          size: const NavigationPaneSize(openMaxWidth: 60),
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
                  Icons.corporate_fare_rounded,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Transactions"),
                body: const TransactionScreen()),
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
                  Icons.send,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Orders"),
                body: const StockOrder()),
            PaneItem(
                icon: const Icon(
                  Icons.sip,
                  color: Color(0xffFF6E1F),
                  size: 25,
                ),
                title: const Text("Item Accounts"),
                body: const ItemAccounts()),
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
