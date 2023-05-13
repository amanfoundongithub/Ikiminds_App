import 'package:App/bookingModule/location.dart';
import 'package:App/main.dart';
import 'package:flutter/material.dart';
import 'package:multiselect/multiselect.dart';

import 'package:App/profile/profile.dart' show Child;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MyActivityModule extends StatefulWidget {
  final String email;
  final int mobileNumber;
  const MyActivityModule(this.email, this.mobileNumber, {Key? key})
      : super(key: key);

  @override
  State<MyActivityModule> createState() => _MyActivityModule();
}

class _MyActivityModule extends State<MyActivityModule> {
  // init

  List<Child> children = [];
  static List<int> timeAvailable = [1, 2, 3];
  List<String> activities = [
    // List of activities
    'Origami',
    'Painting',
    'Story telling',
    'Dancing',
    'Clay Modelling'
  ];
  DateTime current = DateTime.now();
  bool loaded = false;

  // Data for Activity booking

  List<String> selected = []; // selected children
  TextEditingController activityDropTime = TextEditingController();
  TextEditingController bookingDate = TextEditingController();
  int duration = 1;
  List<String> chosenActivities = [];

  Future<void> fetchChild() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/parent/children'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );

    if (response.statusCode == 200) {
      final array =
          jsonDecode(response.body); // array of children(json objects)
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < array.length; i++) {
          final elem = array[i];
          final child = Child(
              name: elem["name"],
              DOB: elem["date_of_birth"],
              gender: elem["gender"]);
          children.add(child);
        }
        loaded = true;
      });
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  int valid = 777;
  Future<int> checkValid() async {
    if (selected.isEmpty) {
      return 0;
    }
    if (chosenActivities.isEmpty) {
      return 1;
    }

    if (bookingDate.text.isEmpty) {
      return 2;
    }

    if (activityDropTime.text.isEmpty) {
      return 3;
    }

    return valid;
  }

  List<String> errorsList = [
    'Please Select Children For Activity, The Field Cannot Be Empty',
    'Please Select Activities For The Session, The Field Cannot Be Empty',
    'Please Select A Booking Date',
    'Please Select A Drop Time For The Activity',
  ];

  @override
  void initState() {
    super.initState();
    fetchChild();
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
              'Children',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            loaded == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 30,
                        child: DropDownMultiSelect(
                          decoration: InputDecoration(
                            labelText: 'Select Children',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          options: children.map((child) => child.name).toList(),
                          selectedValues:
                              selected, // array of selected chuldren
                          onChanged: (value) {
                            setState(() {
                              selected = value;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Container(
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: [
            Text(
              'Activities',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 30,
              child: DropDownMultiSelect(
                decoration: InputDecoration(
                  labelText: 'Select Activities',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                options: activities,
                selectedValues: chosenActivities,
                onChanged: (value) {
                  setState(() {
                    chosenActivities = value;
                    return;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 20,
            child: Column(
              children: [
                // Drop Off Time
                Text(
                  'Booking Time',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    child: TextField(
                      readOnly: true,
                      controller: bookingDate,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: 'Date Of Activity'),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: current,
                            firstDate: current,
                            lastDate: DateTime(
                                current.year, current.month + 2, current.day));

                        if (picked != null) {
                          setState(() {
                            bookingDate.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 20,
                    child: TextField(
                      controller: activityDropTime,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.timer),
                        labelText: 'Drop Time',
                      ),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            activityDropTime.text =
                                time.format(context).toString();
                            return;
                          });
                        } else {
                          setState(() {
                            activityDropTime.text =
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
                              child: Text(elem.toString() +
                                  (elem > 1 ? ' hours' : ' hour')));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            duration = int.parse(value ??
                                '1'); // to return a non nullable string
                          });
                        }),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    checkValid().then((value) {
                      if (value == valid) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LocationPage(
                                    widget.email,
                                    selected,
                                    chosenActivities,
                                    bookingDate.text,
                                    activityDropTime.text,
                                    duration,
                                    widget.mobileNumber)));
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
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    //border radius equal to or more than 50% of width
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
              ],
            ),
          ),
        ],
      ),
    ]);
  }
}
