import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:App/bookingModule/payment.dart';
import 'package:App/profile/profile.dart' show Child;

class LocationPage extends StatefulWidget {
  final String email, bookingDate, dropTime;
  final int duration, mobileNumber;
  final List<String> selectedActivites, children;
  const LocationPage(this.email, this.children, this.selectedActivites,
      this.bookingDate, this.dropTime, this.duration, this.mobileNumber,
      {Key? key})
      : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;
  bool isPos = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        latitude = _currentPosition!.latitude;
        longtitude = _currentPosition!.longitude;
      });
      _getAddressFromLatLng(_currentPosition!);
      fetchCentres();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  // Future<void> _AddressFromLatandLong(double lat, double long) async {
  //   await placemarkFromCoordinates(lat, long).then((value) {
  //     Placemark place = value[0];

  //     String s =
  //         '${place.street} , ${place.subLocality} , ${place.subAdministrativeArea} , ${place.country}';

  //     setState(() {
  //       list_of_address.add(s);
  //     });
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }

  // Future<void> GetAddressforList(List l) async {
  //   for (int i = 0; i < l.length; i++) {
  //     final element = l[i];

  //     await _AddressFromLatandLong(
  //         element['center']['Latitude'], element['center']['Longtitude']);
  //   }
  // }

  double latitude = 0;
  double longtitude = 0;

  bool fetched = false;
  Future<void> fetchCentres() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/location/nearest'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, double>{
        'latitude': latitude,
        'longtitude': longtitude,
      }),
    );

    if (response.statusCode == 200) {
      final array =
          jsonDecode(response.body); // array of children(json objects)

      // Now get the desired info from the data
      if (fetched == false) {
        setState(() {
          for (int i = 0; i < array.length; i++) {
            list_of_centers.add({
              'center_name': array[i]['center']['ID'],
              'address': array[i]['center']['address'],
              'distance': array[i]['distance'],
            });
          }
          isPos = true;
          fetched = true;
        });
      }

      print(array);
    }
  }

  List<dynamic> list_of_centers = [];

  int selectedindex = 0;
  @override
  void initState() {
    _getCurrentPosition().then((value) {
      fetchCentres();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final address = _currentAddress ?? '';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Select Centres")),
      body: isPos == true
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(''),
                    Center(
                        child: SingleChildScrollView(
                            child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          child: Text(
                            'Centers near $address',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                        Text(''),
                        Column(
                          children: list_of_centers.map((e) {
                            return ListTile(
                              title: Container(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e['address'],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          )),
                                      Text(e['distance'].toStringAsFixed(2) +
                                          ' km from your current location'),
                                      Text(''),
                                    ]),
                              ),
                              leading: Radio<int>(
                                splashRadius: 15,
                                hoverColor: Colors.yellow,
                                activeColor: Colors.green,
                                value: list_of_centers.indexOf(e),
                                groupValue: selectedindex,
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedindex = value ?? 0;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        Text(''),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PaymentGatewayPage(
                                          widget.email,
                                          widget.children,
                                          widget.selectedActivites,
                                          widget.bookingDate,
                                          widget.dropTime,
                                          widget.duration,
                                          widget.mobileNumber,
                                          list_of_centers[selectedindex]
                                              ['center_name'],
                                          list_of_centers[selectedindex]
                                              ['address'])));
                            },
                            child: const Text('Proceed To Payment')),
                        const Text(''),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Go Back')),
                      ],
                    ))),
                  ],
                ),
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Text('Please wait while we load a list of centers...'),
                  ])),
    );
  }
}
