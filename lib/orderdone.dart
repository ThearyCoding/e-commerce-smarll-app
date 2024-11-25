import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderDone extends StatefulWidget {
  const OrderDone({Key? key}) : super(key: key);

  @override
  State<OrderDone> createState() => _OrderDoneState();
}

class _OrderDoneState extends State<OrderDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Lottie.network(
                  'https://lottie.host/f7307f05-308f-4f5e-aa62-75ecc9833293/m1fp72iAIF.json',
                  width: 300,
                  height: 300,
                  repeat: false,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                  left: 40.0,
                ),
                child: Text(
                  "Order Successfully",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 40.0,
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Text(
                  "Your Order will be sent to your address. Thank you for the Order!",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 40,
              margin: const EdgeInsets.only(left: 40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
