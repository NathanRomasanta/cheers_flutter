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

  static InputDecoration inputBoxMain = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: Colors.orange, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: Colors.grey, width: 1.0),
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
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle alertDialogHeader = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle alertTextButton = TextStyle(
    fontFamily: 'Product Sans',
    color: const Color(0xffFF6E1F),
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h3ss = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h7s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 14,
    color: Colors.grey,
  );
  static const TextStyle h4s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle h5s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 13,
    color: Colors.grey,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h2s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 20,
    color: Colors.grey,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle inputBoxLabels = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 15,
    color: Colors.black,
  );
}
