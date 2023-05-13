import 'package:App/profile/profile.dart';
import 'package:flutter/material.dart';
import 'party.dart';
import 'activity.dart';

class MyBookingModule extends StatefulWidget {
  final String email;
  final int mobileNumber;
  const MyBookingModule(this.email, this.mobileNumber,{Key? key}) : super(key: key);

  @override
  State<MyBookingModule> createState() => _MyBookingModule();
}

class _MyBookingModule extends State<MyBookingModule> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget Page = pageIndex == 0
        ? MyActivityModule(widget.email, widget.mobileNumber)
        : MyPartyModule(widget.email, widget.mobileNumber);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(pageIndex == 0 ? 'Activity Booking' : 'Party Booking',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: const Color.fromRGBO(90, 90, 90, 0.2),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.person),
                    color: Colors.white,
                    tooltip: "User's Profile",
                    onPressed: () {
                      setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(widget.email)));
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(child: Page),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                label: 'Activity',
                icon: Icon(Icons.people),
              ),
              BottomNavigationBarItem(
                label: 'Party',
                icon: Icon(Icons.bookmark_border),
              ),
            ],
            currentIndex: pageIndex,
            onTap: (int index) {
              setState(() {
                pageIndex = index;
              });
            },
          )),
    );
  }
}
