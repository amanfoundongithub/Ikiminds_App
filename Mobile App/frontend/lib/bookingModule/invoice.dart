import 'package:App/main.dart';
import 'package:flutter/material.dart';

class InvoicePage extends StatefulWidget {
  final String email, bookingDate, dropTime, centerId, centerName;
  final int duration, mobileNumber;
  final List<String> selectedActivites, children;
  final List<String> prices;
  final int total;
  const InvoicePage(
      this.email,
      this.children,
      this.selectedActivites,
      this.bookingDate,
      this.dropTime,
      this.duration,
      this.mobileNumber,
      this.centerId,
      this.centerName,
      this.prices,
      this.total,
      {Key? key})
      : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool infoLoaded = true;

  @override
  Widget build(BuildContext context) {
    String name = "";
    for (var i = 0; i < widget.children.length - 1; i++) {
      name += (widget.children[i] + ', ');
    }
    name += widget.children.last;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Invoice"),
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
                              title: const Text("Invoice"),
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
                                  Text("Center: ${widget.centerName}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Description:',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  for (var item in widget.prices)
                                    Text(
                                      item,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Total: Rs ${widget.total}",
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
