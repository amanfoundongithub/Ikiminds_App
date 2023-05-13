import 'package:App/bookingModule/booking.dart';
import 'package:App/profile/editProfile.dart';
import 'package:App/profile/myBookings.dart';
import 'package:flutter/material.dart';
import 'package:App/authenticationModule/authenMain.dart';
import 'package:App/profile/addChild.dart';

import 'package:accordion/accordion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Child {
  final String name;
  final String DOB;
  final String gender;

  const Child({
    // constructor function
    required this.name,
    required this.DOB,
    required this.gender,
  });
}

class ProfilePage extends StatefulWidget {
  final String email; // email as an arguement

  const ProfilePage(this.email, {Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // It is the Profile Page here

  String parentName = 'Nikunj';
  int mobileNumber = 9289857147;

  List<Child> children = []; // list of children

  // Boolean variables
  bool infoLoaded = false;

  Future<void> fetchProfile() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/parent/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );

    if (response.statusCode == 200) {
      parentName = jsonDecode(response.body)["name"];

      mobileNumber = jsonDecode(response.body)["mobile_no"];

      // children
      final childresponse = await http.post(
        Uri.parse('http://192.168.174.180:5000/parent/children'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': widget.email,
        }),
      );

      if (childresponse.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          final array = jsonDecode(childresponse.body);

          for (var i = 0; i < array.length; i++) {
            final elem = array[i];
            children.add(Child(
                name: elem["name"],
                DOB: elem["date_of_birth"],
                gender: elem["gender"]));
          }
          infoLoaded = true;
        });
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> addChild(String name, String DOB, String gender) async {
    final response = await http.put(
      Uri.parse('http://192.168.174.180:5000/parent/update/addchild'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'parent': widget.email,
        'name': name,
        'DOB': DOB,
        'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      print("child appended successfully");
    } else {
      throw Exception('Failed to connect to server');
    }
    setState(() {
      children.add(Child(name: name, DOB: DOB, gender: gender));
    });
  }

  // Boolean to show children
  bool showChildren = false;

  @override
  void initState() {
    super.initState();

    // fetch the details of the parent
    fetchProfile();
  }

  final _storage = const FlutterSecureStorage();

  removeCredentials() async {
    await _storage.delete(key: "KEY_USERNAME");
    await _storage.delete(key: "KEY_PASSWORD");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile Page'),
          actions: <Widget>[
            PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit Profile') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditProfilePage(widget.email)));
                  }
                },
                itemBuilder: (BuildContext context) {
                  return ['Edit Profile', 'Settings'].map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                )),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName:
                    Text(parentName, style: const TextStyle(fontSize: 20)),
                accountEmail: Text(widget.email,
                    style: const TextStyle(color: Colors.grey)),
                currentAccountPicture: CircleAvatar(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile.jpg',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/profilebg.jpg")),
                ),
              ),
              ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text(
                    'My Bookings',
                  ),
                  onTap: () {
                    // Navigate to My Booking Page here
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MybookingsPage(widget.email)));
                  }),
              ListTile(
                leading: const Icon(Icons.child_care),
                title: const Text('My Children'),
                onTap: () {
                  setState(() {
                    showChildren = !showChildren;
                  });
                },
              ),
              showChildren == true
                  ? Accordion(
                      maxOpenSections: 1,
                      headerBackgroundColor: Colors.transparent,
                      contentBorderColor: Colors.transparent,
                      contentBackgroundColor: Colors.transparent,
                      children: children.map((e) {
                        var index = children.indexOf(e);
                        var name = children[index].name;
                        var dateOfBirth = children[index].DOB;
                        var gender = children[index].gender;
                        return AccordionSection(
                            header: Text(name,
                                style: const TextStyle(
                                  fontSize: 15,
                                )),
                            content: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(dateOfBirth.substring(0, 10),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          )),
                                    ],
                                  ),
                                  Text(gender,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                ]));
                      }).toList(),
                    )
                  : const SizedBox(),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Log Out'),
                onTap: () {
                  removeCredentials();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthenticationPage()));
                },
              ),
            ],
          ),
        ),
        body: infoLoaded == true
            ? Column(
                children: [
                  Expanded(flex: 1, child: TopPortion(widget.email)),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            parentName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          _ProfileInfoRow(
                              widget.email, mobileNumber.toString()),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AddChildPage(
                                            addChild); // add child : function to add child
                                      });
                                },
                                heroTag: 'child',
                                elevation: 0,
                                label: const Text("ADD A CHILD"),
                                icon: const Icon(Icons.add),
                              ),
                              const SizedBox(height: 16.0),
                              FloatingActionButton.extended(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyBookingModule(
                                              widget.email, mobileNumber)));
                                },
                                heroTag: 'center',
                                elevation: 0,
                                backgroundColor: Colors.red,
                                label: const Text("Book A Center"),
                                icon: const Icon(Icons.maps_home_work_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                children: const [
                  CircularProgressIndicator(),
                  Text('Please wait for profile to load...'),
                ],
              )),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String email;
  final String mobileNumber;

  const _ProfileInfoRow(this.email, this.mobileNumber, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ProfileInfoItem> _items = [
      ProfileInfoItem("Email ID", email),
      ProfileInfoItem("Mobile Number", mobileNumber),
    ];
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0)
                      const VerticalDivider(
                        color: Colors.grey,
                      ),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final String value;
  ProfileInfoItem(this.title, this.value);
}

class TopPortion extends StatefulWidget {
  final String email;
  const TopPortion(this.email, {super.key});

  @override
  State<TopPortion> createState() => _TopPortionState();
}

class _TopPortionState extends State<TopPortion> {
  String imagePath = '';

  Future<void> findImage() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String fileName = widget.email;
    String filePath = '${appDirectory.path}/$fileName.jpg';

    if (await File(filePath).exists()) {
      setState(() {
        imagePath = filePath;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    findImage();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick an image'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextButton(
                  child: const Text('From Gallery'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      _handleImage(pickedFile.path);
                    }
                  },
                ),
                TextButton(
                  child: const Text('From Camera'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    XFile? pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      _handleImage(pickedFile.path);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleImage(String imagePath) {
    File imageFile = File(imagePath);
    _saveImage(imageFile);
  }

  Future<void> _saveImage(File imageFile) async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String fileName = widget.email;
    String filePath = '${appDirectory.path}/$fileName.jpg';
    await imageFile.copy(filePath);

    setState(() {
      imagePath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromARGB(255, 54, 89, 149),
                    Color(0xff006df1)
                  ]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imagePath.isEmpty
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg')),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(imagePath)),
                          ),
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: imagePath.isNotEmpty
                      ? CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.file_upload),
                          onPressed: _pickImage,
                        ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
