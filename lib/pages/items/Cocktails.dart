import 'package:flutter/material.dart';

class CocktailsPage extends StatefulWidget {
  const CocktailsPage({super.key});

  @override
  State<CocktailsPage> createState() => _CocktailsPageState();
}

class _CocktailsPageState extends State<CocktailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Back"))
      ]),
      body: const Text("Cocktails"),
    );
  }
}
