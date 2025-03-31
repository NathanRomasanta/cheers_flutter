import 'package:flutter/material.dart';

class CheersStyles {
  static InputDecoration inputBox = InputDecoration(
    labelText: "",
    filled: true, // Enables the background color
    fillColor: Colors.white, // Light gray background
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
      textStyle:
          WidgetStateProperty.all(const TextStyle(fontFamily: "Product Sans")),
      minimumSize: WidgetStateProperty.all(const Size(200, 40)),
      foregroundColor: WidgetStateProperty.all(Colors.white), // Text color
      padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      backgroundColor: WidgetStateProperty.all(const Color(0xffFF6E1F)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      )));

  static const TextStyle h1s = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle menuTitle = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 25,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle paymentTitle = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 18,
    color: Colors.black,
  );

  static const TextStyle posTitleStyle = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 22,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle tableHeaders = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 14,
  );

  static const TextStyle tableItems =
      TextStyle(fontFamily: 'Product Sans', fontSize: 14, color: Colors.grey);

  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 23,
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
    color: Color(0xffFF6E1F),
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
    fontSize: 18,
    color: Colors.grey,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle inputBoxLabels = TextStyle(
    fontFamily: 'Product Sans',
    fontSize: 15,
    color: Colors.black,
  );
}

class CashPaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color lineColor;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle textStyle;
  final String text;
  final IconData icon;
  final double height;
  final double width;
  final double elevation;
  final Color shadowColor;
  final double lineWidth;
  final Color dividerColor;
  final double dividerThickness;
  final double dividerHeight;
  final double? lineHeight; // New parameter for customizing the line height

  const CashPaymentButton({
    Key? key,
    required this.onPressed,
    this.lineColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.text = "Pay with Cash",
    this.icon = Icons.payments,
    this.height = 90,
    this.width = 300,
    this.elevation = 5,
    this.shadowColor = Colors.grey,
    this.lineWidth = 3,
    this.dividerColor = Colors.grey,
    this.dividerThickness = 1,
    this.dividerHeight = 40,
    this.lineHeight, // Optional: If null, it will extend to the full height of the button
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero, // Remove default padding
          backgroundColor: backgroundColor,
          elevation: elevation,
          shadowColor: shadowColor,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // The line that can be customized to full height or specific height
            Container(
              width: lineWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(100),
                    bottomStart: Radius.circular(100)),
              ),
            ),
            // The content with icon, divider and text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: lineWidth + 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Container(
                    height: dividerHeight,
                    width: dividerThickness,
                    color: dividerColor,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    text,
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
