import 'package:flutter/material.dart';

class CheersStyles {
  static InputDecoration inputBox = InputDecoration(
    labelText: "",
    filled: true, // Enables the background color
    fillColor: Colors.grey[200], // Light gray background
    contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0), // Rounded corners
      borderSide: BorderSide.none, // No border
    ),
  );

  static ButtonStyle buttonMain = ButtonStyle(
      textStyle: MaterialStateProperty.all(
          const TextStyle(fontFamily: "Product Sans")),
      minimumSize: MaterialStateProperty.all(const Size(200, 40)),
      foregroundColor: MaterialStateProperty.all(Colors.white), // Text color
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      backgroundColor: MaterialStateProperty.all(const Color(0xffFF6E1F)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      )));

  static const TextStyle h1s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 25,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle inputBoxLabels = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 15,
    color: Colors.black,
  );
}
