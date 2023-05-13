import 'package:App/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MybookingsPage extends StatelessWidget {
  final String email;
  const MybookingsPage(this.email, {super.key});

  static const String _title = 'My Bookings';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            email,
                          )));
            },
          ),
        ),
        body: MyStatefulWidget(email),
      ),
    );
  }
}

class Activity extends StatelessWidget {
  final dynamic data;
  const Activity(this.data, {super.key});

  String getitString(List list) {
    String name = "";
    for (var i = 0; i < list.length - 1; i++) {
      name += (list[i] + ', ');
    }
    name += list.last;

    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.circle,
              color: data['upcoming'] == true ? Colors.green : Colors.red,
            ),
            // trailing: Text("Rs 90"),
            title: Text(data["dropOffTime"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booked At: ' + data['centerName']),
                Text('Children: ' + getitString(data['childName'])),
                Text('Activities: ' + getitString(data['activityName'])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Party extends StatelessWidget {
  final dynamic data;
  const Party(this.data, {super.key});

  String getitString(List list) {
    String name = "";
    for (var i = 0; i < list.length - 1; i++) {
      name += (list[i] + ', ');
    }
    name += list.last;

    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.circle,
              color: data['upcoming'] == true ? Colors.green : Colors.red,
            ),
            title: Text(data["startTime"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booked At: ' + data['centerAddress']),
                Text('Children: ' + data['children'].toString()),
                Text('Parent: ' + data['adults'].toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final String email;
  const MyStatefulWidget(this.email, {super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> Activities = [];

  List<dynamic> Parties = [];

  Future<void> fetchActivities() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/activity/fetch/activities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        Activities = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> fetchParties() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/activity/fetch/parties'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        Parties = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  final _selectedColor = const Color(0xff1a73e8);
  final _unselectedColor = const Color(0xff5f6368);

  int index = 0;
  final _tabs = const [
    Tab(text: 'Activity'),
    Tab(text: 'Party'),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    fetchActivities();
    fetchParties();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              labelColor: _selectedColor,
              indicatorColor: _selectedColor,
              unselectedLabelColor: _unselectedColor,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: index == 0
                        ? Activities.map((elem) {
                            return Activity(elem);
                          }).toList()
                        : Parties.map((elem) {
                            return Party(elem);
                          }).toList(),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
