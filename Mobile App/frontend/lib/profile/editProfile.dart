import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:App/profile/profile.dart';

class EditProfilePage extends StatefulWidget {
  final String email;
  const EditProfilePage(this.email, {super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String parentName = 'Nikunj';
  bool parentEdit = false;
  bool parentErr = false;
  TextEditingController name = TextEditingController();

  int mobileNumber = 9289857147;
  bool mobileNumberEdit = false;
  bool mobileNumberErr = false;
  TextEditingController number = TextEditingController();

  // Boolean variables
  bool infoLoaded = false;

  Future<void> updateProfile() async {
    final response = await http.put(
      Uri.parse('http://192.168.174.180:5000/parent/update/profile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': widget.email,
        'mobile_no': mobileNumber,
        'name': parentName,
      }),
    );

    if (response.statusCode == 200) {
      print("Profile Updated");
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  void updateParentName(String newname) {
    setState(() {
      if (newname.isEmpty) {
        parentErr = true;
        return;
      }
      parentErr = false;
      parentEdit = false; // edit option false

      parentName = newname;
      updateProfile();
    });
  }

  void updateMobileNumber(String newphone) {
    setState(() {
      if (num.tryParse(newphone) == null) {
        mobileNumberErr = true;
        return;
      } else if (newphone.length != 10) {
        mobileNumberErr = true;
        return;
      }

      mobileNumberErr = false;
      mobileNumberEdit = false;

      mobileNumber = int.parse(newphone);
      updateProfile();
    });
  }

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

    if (!mounted) {
      return;
    }

    if (response.statusCode == 200) {
      setState(() {
        name.text = jsonDecode(response.body)["name"];
        parentName = name.text;

        mobileNumber = jsonDecode(response.body)["mobile_no"];
        number.text = mobileNumber.toString();

        infoLoaded = true;
      });
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  void initState() {
    super.initState();

    // fetch the details of the parent
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "Edit Details",
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            widget.email,
                          )));
            },
          ),
        ),
        body: infoLoaded
            ? Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: parentEdit == false ? width - 60 : width - 100,
                    child: TextField(
                      controller: name,
                      enabled: parentEdit,
                      decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: const Icon(Icons.person),
                          labelText:
                              parentEdit == false ? "Parent's Name:" : '',
                          errorText: parentErr == true
                              ? 'Please enter a valid name'
                              : '',
                          hintStyle: const TextStyle(color: Colors.blue),
                          hintText: "Enter your Name"),
                    ),
                  ),
                  parentEdit == false
                      ? IconButton(
                          // To add an iconButton
                          onPressed: () {
                            setState(() {
                              parentEdit = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                        )
                      : IconButton(
                          onPressed: () {
                            updateParentName(name.text);
                          },
                          icon: Icon(Icons.done)),
                  parentEdit == false
                      ? SizedBox()
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              name.text = parentName;
                              parentEdit = false;
                            });
                          },
                          icon: Icon(Icons.cancel_outlined))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: mobileNumberEdit == false ? width - 60 : width - 100,
                    child: TextField(
                      controller: number,
                      enabled: mobileNumberEdit,
                      decoration: InputDecoration(
                          isDense: true,
                          prefixIcon: const Icon(
                            Icons.phone,
                          ),
                          labelText:
                              mobileNumberEdit == false ? "Mobile Number:" : '',
                          errorText: mobileNumberErr == true
                              ? 'Please enter a valid number'
                              : '',
                          hintStyle: const TextStyle(color: Colors.blue),
                          hintText: "Enter your Mobile Number"),
                    ),
                  ),
                  mobileNumberEdit == false
                      ? IconButton(
                          // To add an iconButton
                          onPressed: () {
                            setState(() {
                              mobileNumberEdit = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                        )
                      : IconButton(
                          onPressed: () {
                            updateMobileNumber(number.text);
                          },
                          icon: Icon(Icons.done)),
                  mobileNumberEdit == false
                      ? SizedBox()
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              number.text = mobileNumber.toString();
                              mobileNumberEdit = false;
                            });
                          },
                          icon: Icon(Icons.cancel_outlined))
                ]),
              ])
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
