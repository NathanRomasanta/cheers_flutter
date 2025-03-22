import 'package:flutter/material.dart';
import 'package:cheers_flutter/design/design.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 20),
              child: Text(
                "Payment Method",
                style: CheersStyles.paymentTitle,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CashPaymentButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Pay with Credit Card",
                    icon: Icons.credit_card,
                    lineColor: Colors.green,
                    textStyle: CheersStyles.h3ss,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  CashPaymentButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Pay with Cash",
                    icon: Icons.money,
                    lineColor: Colors.green,
                    textStyle: CheersStyles.h3ss,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  CashPaymentButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Fast Payment",
                    icon: Icons.send_to_mobile,
                    lineColor: Colors.green,
                    textStyle: CheersStyles.h3ss,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
