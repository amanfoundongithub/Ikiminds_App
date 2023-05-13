import 'package:App/main.dart';
import 'package:flutter/material.dart';

class InvoicePage extends StatefulWidget {
  final String email, bookingDate, startTime;
  final int duration, mobileNumber;
  final String adult, children, centerAddress;
  const InvoicePage(this.email, this.adult, this.children, this.bookingDate,
      this.startTime, this.duration, this.mobileNumber, this.centerAddress,
      {Key? key})
      : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool infoLoaded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Booking Confirmed"),
      ),
      body: infoLoaded == true
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2 - 260,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 20,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Color.fromARGB(255, 57, 235, 63),
                              ),
                              title: const Text("Booking Details"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Payment Confirmed'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Center: ${widget.centerAddress}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Total: Rs ${3000 * widget.duration}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
              children: const [
                CircularProgressIndicator(),
                Text('Generating your bill...'),
              ],
            )),
    );
  }
}
