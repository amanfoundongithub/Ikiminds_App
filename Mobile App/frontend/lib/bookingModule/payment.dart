import 'package:App/bookingModule/invoice.dart';
import 'package:App/main.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:App/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<String> activities = [
  // List of activities
  'Origami',
  'Painting',
  'Story telling',
  'Dancing',
  'Clay Modelling'
];

class PaymentGatewayPage extends StatefulWidget {
  final String email, bookingDate, dropTime, centerId, centerName;
  final int duration, mobileNumber;
  final List<String> selectedActivites, children;
  const PaymentGatewayPage(
      this.email,
      this.children,
      this.selectedActivites,
      this.bookingDate,
      this.dropTime,
      this.duration,
      this.mobileNumber,
      this.centerId,
      this.centerName,
      {Key? key})
      : super(key: key);

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final navigator = Navigator.of(context);
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/activity/confirmBooking'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'dropOffTime': widget.dropTime,
        'duration': widget.duration,
        'parentEmail': widget.email,
        'centerId': widget.centerId,
        'childrenString': widget.children,
        'activityString': widget.selectedActivites,
        'center_address': widget.centerName,
        'bookingDate': widget.bookingDate,
      }),
    );
    navigator.push(MaterialPageRoute(
        builder: (context) => InvoicePage(
            widget.email,
            widget.children,
            widget.selectedActivites,
            widget.bookingDate,
            widget.dropTime,
            widget.duration,
            widget.mobileNumber,
            widget.centerId,
            widget.centerName,
            prices,
            total)));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  final List<String> prices = [];
  bool infoLoaded = false;
  int total = 0;
  getPrice(String activityName) async {
    // Write
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/activity/getPrice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'activity_name': activityName,
      }),
    );

    if (response.statusCode == 200) {
      int cost = jsonDecode(response.body)['price'];
      total += cost * widget.duration * widget.children.length;
      String tobeadded =
          "$activityName     $cost x${widget.duration} x${widget.children.length}";
      prices.add(tobeadded);
      if (prices.length == widget.selectedActivites.length) {
        setState(() {
          infoLoaded = true;
        });
      }
    } else {
      // email does not exist
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    for (var item in widget.selectedActivites) {
      getPrice(item);
    }
  }

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
        title: const Text("Billing"),
      ),
      body: infoLoaded == true
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.monetization_on_sharp),
                              title: const Text("Booking Details"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text('Children Selected: $name'),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "Date of Booking: ${widget.bookingDate}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Drop off time: ${widget.dropTime}"),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Duration: ${widget.duration} hours"),
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
                                  for (var item in prices)
                                    Text(
                                      item,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Total: Rs $total",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Razorpay razorpay = Razorpay();
                          var options = {
                            'key': 'rzp_test_X3Lp0ol12yjPmd',
                            'amount': total * 100,
                            'name': 'Kidventures',
                            'description': 'Child Payment',
                            'retry': {'enabled': true, 'max_count': 1},
                            'send_sms_hash': true,
                            'prefill': {
                              'contact': widget.mobileNumber,
                              'email': widget.email
                            },
                          };
                          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                              _handlePaymentSuccess);
                          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                              _handlePaymentError);
                          razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                              _handleExternalWallet);
                          razorpay.open(options);
                        },
                        child: const Text("Pay with Razorpay")),
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
