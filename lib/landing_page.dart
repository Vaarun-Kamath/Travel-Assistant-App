import 'package:flutter/material.dart';
import 'assistant.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  TextField InputBox(String val) {
    return TextField(
      decoration: InputDecoration(
        labelText: val,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(height: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Travel Assistant",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 150),
            InputBox("Enter Starting Location"),
            const SizedBox(height: 30),
            InputBox("Enter Ending Location"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(217, 41, 41, 1)),
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: () => print("Assist Trip"),
              child: const Text("Assist Trip"),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromRGBO(217, 41, 41, 1))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const Assistant();
                    },
                  ),
                );
              },
              child: const Text("Assist Trip"),
            ),
          ],
        ),
      ),
    );
  }
}
