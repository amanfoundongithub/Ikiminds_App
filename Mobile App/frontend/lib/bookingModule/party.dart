import 'package:App/bookingModule/location2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class MyPartyModule extends StatefulWidget {
  final String email;
  final int mobileNumber;
  const MyPartyModule(this.email, this.mobileNumber, {Key? key}) : super(key: key);

  @override
  State<MyPartyModule> createState() => _MyPartyModule();
}

class _MyPartyModule extends State<MyPartyModule> {
  // initialization

  String email = '';
  List<int> timeAvailable = []; // array of duration of the activity
  DateTime current = DateTime.now();

  // Data stored for party

  TextEditingController partyStartTime = TextEditingController();
  TextEditingController partyBookingDate = TextEditingController();
  int duration = 1;
  int adults = 0;
  int children = 0;

  // Error Handling

  // Error1: Alphabetical number of adults
  // Error2: Range error

  bool editAdults = false;
  int adultsErr = 0;

  TextEditingController adultNumber = TextEditingController();

  void updateAdults(String adultsNumber) {
    setState(() {
      if (num.tryParse(adultsNumber) == null) {
        adultsErr = 1;
      } else if (int.parse(adultsNumber) > 10) {
        adultsErr = 2;
      } else {
        adultsErr = 0;
        adults = int.parse(adultsNumber);
        editAdults = false;
      }
    });
  }

  bool editChildren = false;
  int childrenErr = 0;

  TextEditingController childNumber = TextEditingController();

  void updatechildren(String nChildren) {
    setState(() {
      if (num.tryParse(nChildren) == null) {
        childrenErr = 1;
      } else if (int.parse(nChildren) > 20) {
        childrenErr = 2;
      } else {
        childrenErr = 0;
        children = int.parse(nChildren);
        editChildren = false;
      }
    });
  }

  int valid = 777;
  int checkValid() {
    if (int.parse(adultNumber.text) == 0) {
      return 0;
    } else if (int.parse(childNumber.text) == 0) {
      return 1;
    } else if (partyBookingDate.text.isEmpty) {
      return 2;
    } else if (partyStartTime.text.isEmpty) {
      return 3;
    }
    return valid;
  }

  List<String> errorsList = [
    'Number Of Adults Cannot Be Zero, Please Select A Non-Zero Integer',
    'Number Of Children Cannot Be Zero, Please Select A Non-Zero Integer',
    'Please Select A Booking Date',
    'Please Select A Drop Time For The Party',
  ];

  @override
  void initState() {
    email = widget.email;
    for (int i = 1; i <= 5; i++) {
      timeAvailable.add(i);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 20,
      ),
      Container(
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: [
            Text(
              'Participants',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 60,
                child: NumberInputWithIncrementDecrement(
                  widgetContainerDecoration: const BoxDecoration(),
                  numberFieldDecoration: const InputDecoration(
                      labelText: 'Adults',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      )),
                  controller: adultNumber,
                  incDecBgColor: const Color.fromRGBO(211, 211, 211, 1),
                  buttonArrangement: ButtonArrangement.rightEnd,
                  min: 0,
                  max: 10,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 60,
                child: NumberInputWithIncrementDecrement(
                  widgetContainerDecoration: const BoxDecoration(),
                  numberFieldDecoration: const InputDecoration(
                      labelText: 'Children',
                      labelStyle: TextStyle(
                        fontSize: 20,
                      )),
                  controller: childNumber,
                  incDecBgColor: const Color.fromRGBO(211, 211, 211, 1),
                  buttonArrangement: ButtonArrangement.rightEnd,
                  min: 0,
                  max: 10,
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        'Schedule Party',
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(color: Colors.black),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: TextField(
            readOnly: true,
            controller: partyBookingDate,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), labelText: 'Date Of Party'),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: current,
                  firstDate: current,
                  lastDate:
                      DateTime(current.year, current.month + 2, current.day));

              if (picked != null) {
                setState(() {
                  partyBookingDate.text =
                      DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: TextField(
            controller: partyStartTime,
            decoration: const InputDecoration(
              icon: Icon(Icons.timer),
              labelText: 'Party Time',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? time = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
              if (time != null) {
                setState(() {
                  partyStartTime.text = time.format(context).toString();
                  return;
                });
              } else {
                setState(() {
                  partyStartTime.text =
                      TimeOfDay.now().format(context).toString();
                  return;
                });
                return;
              }
            },
          ),
        ),
      ]),
      const SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Duration: ',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          DropdownButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              value: duration.toString(),
              items: timeAvailable.map((elem) {
                return DropdownMenuItem(
                    value: elem.toString(),
                    child: Text(
                        elem.toString() + (elem > 1 ? ' hours' : ' hour')));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  duration = int.parse(
                      value ?? '1'); // to return a non nullable string
                });
              }),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      ElevatedButton(
        onPressed: () {
          int value = checkValid();
          if (value == valid) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LocationPage(widget.email, adultNumber.text, childNumber.text, partyBookingDate.text, partyStartTime.text, duration, widget.mobileNumber)));
          } else {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('ALERT!'),
                    content: Text(errorsList[value]),
                    actions: [
                      OutlinedButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ],
                  );
                });
          }
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )),
        child: const Padding(
          padding: EdgeInsets.all(6.0),
          child: Text(
            'Find Centers Nearby',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      )
    ]);
  }
}
