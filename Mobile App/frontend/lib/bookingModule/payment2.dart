import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:App/profile/profile.dart' show Child;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:App/bookingModule/invoice2.dart';

class PaymentGatewayPage extends StatefulWidget {
  final String email, bookingDate, startTime;
  final int duration, mobileNumber;
  final String adult, children, centerAddress;
  const PaymentGatewayPage(
      this.email,
      this.adult,
      this.children,
      this.bookingDate,
      this.startTime,
      this.duration,
      this.mobileNumber,
      this.centerAddress,
      {Key? key})
      : super(key: key);

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final navigator = Navigator.of(context);
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/activity/confirmParty'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'startTime': widget.startTime,
        'duration': widget.duration,
        'parentEmail': widget.email,
        'centerAddress': widget.centerAddress,
        'children': widget.children,
        'adult': widget.adult,
        'bookingDate': widget.bookingDate,
      }),
    );
    navigator.push(MaterialPageRoute(
        builder: (context) => InvoicePage(
            widget.email,
            widget.adult,
            widget.children,
            widget.bookingDate,
            widget.startTime,
            widget.duration,
            widget.mobileNumber,
            widget.centerAddress)));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  final List<String> prices = [];
  bool infoLoaded = true;
  int total = 0;

  @override
  void initState() {
    super.initState();
    total = 3000 * widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing"),
      ),
      body: infoLoaded == true
          ? Center(
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
                                Text("Number of Children ${widget.children}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Number of Adults ${widget.adult}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Duration ${widget.duration} hours"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Date of Booking ${widget.bookingDate}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Start time ${widget.startTime}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Center: ${widget.centerAddress}"),
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
                          'description': 'Party Payment',
                          'retry': {'enabled': true, 'max_count': 1},
                          'send_sms_hash': true,
                          'prefill': {
                            'contact': widget.mobileNumber,
                            'email': widget.email
                          },
                        };
                        razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                            _handlePaymentSuccess);
                        razorpay.on(
                            Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
                        razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                            _handleExternalWallet);
                        razorpay.open(options);
                      },
                      child: const Text("Pay with Razorpay")),
                ],
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
