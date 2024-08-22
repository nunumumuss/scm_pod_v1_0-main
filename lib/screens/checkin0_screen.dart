import 'package:fec_corp_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

class Checkin0Screen extends StatefulWidget {
  const Checkin0Screen({super.key});

  @override
  State<Checkin0Screen> createState() => _Checkin0ScreenState();
}

class _Checkin0ScreenState extends State<Checkin0Screen> {
  final authService = AuthService();
  bool gpsEnabled = false;
  bool permissionGranted = false;
  l.Location location = l.Location();
  l.LocationData? locationData;
  String data1 = ''; // น้อยกว่า 10 km
  String data2 = ''; // มากกว่า 10 km
  List<dynamic> checkinData = [];

  Future<List<dynamic>> getData() async {
    
    var res = await http.get(Uri.parse('https://api.codingthailand.com/api/fec-corp/checkin?car_license=กท1'));
    
    // print(res.body);


    if (res.statusCode == 200) {
      List<dynamic> data = json.decode(res.body);
      return data;
    } else {
      // 400 404 401 500
      throw Exception('เกิดข้อผิดพลาดจาก Server โปรดลองใหม่');
    }
  }

  @override
  void initState() {
    checkStatus();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In' ),
        backgroundColor: Colors.red.shade400,
      ),
      body: Column(
        children: [
          Expanded(
            child: Wrap(
              children: [
                // ElevatedButton(
                //     onPressed: () {
                //       requestEnableGps();
                //     },
                //     child: gpsEnabled
                //         ? const Text('GPS เปิดแล้ว!')
                //         : const Text('เปิดใช้งาน GPS')),
                // ElevatedButton(
                //     onPressed: () {
                //       requestLocationPermission();
                //     },
                //     child: permissionGranted
                //         ? const Text('ขอ Permission แล้ว!')
                //         : const Text('ขอสิทธิ์ Location')),
                ElevatedButton(
                    onPressed: () async {
                      final locationData = await location.getLocation();
                      // print('Lat: ${locationData.latitude} Long: ${locationData.longitude}');

                      final data = await getData();
                      findClosestLocation(data, locationData.latitude!,
                          locationData.longitude!);
                    },
                    child: const Text('ตรวจสอบการ Check In')),
              ],
            ),
          ),
          const Divider(),
          data1.isNotEmpty
              ? Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Text(data1),
                      const Divider(),
                      ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Text('${checkinData[index]['ship_count']} ที่'),
                              title: Text('ปลายทาง: ${checkinData[index]['province']}'),
                              subtitle: Text(
                                  'Lat: ${checkinData[index]['letitude']} Long: ${checkinData[index]['longitude']}'),
                              trailing:
                                  Text('ต้นทาง: ${checkinData[index]['ship_point']}'),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: checkinData.length
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.red.shade700,
                        textColor: Colors.white,
                        height: 60,
                        padding: const EdgeInsets.all(20.0),
                        child: const Text('Check In'),
                      ),
                    ],
                  ))
              : Expanded(flex: 5, child: Text(data2)),
        ],
      ),
    );
  }

  void checkStatus() async {
    bool gpsEnabled = await Permission.location.serviceStatus.isEnabled;
    bool permissionGranted = await Permission.locationWhenInUse.isGranted;
    setState(() {
      gpsEnabled = gpsEnabled;
      permissionGranted = permissionGranted;
    });
  }

  void requestEnableGps() async {
    if (gpsEnabled) {
      print('Gps เปิดอยู่');
    } else {
      bool isGpsActive = await location.requestService();
      if (!isGpsActive) {
        setState(() {
          gpsEnabled = false;
        });
        print('ผู้ใช้ไม่ได้เปิด GPS');
      } else {
        print('เปิดใช้ permission gps ให้กับผู้ใช้');
        setState(() {
          gpsEnabled = true;
        });
      }
    }
  }

  void requestLocationPermission() async {
    var permissionStatus = await Permission.locationWhenInUse.request();
    if (permissionStatus.isGranted) {
      setState(() {
        permissionGranted = true;
      });
    } else {
      setState(() {
        permissionGranted = false;
      });
    }
  }

// หาระยะทาง (km) ระหว่างจุดสองจุด
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const double earthRadiusKm = 6371.0; // Radius of the Earth in kilometers

    double startLatitudeRad = startLatitude * (pi / 180);
    double startLongitudeRad = startLongitude * (pi / 180);
    double endLatitudeRad = endLatitude * (pi / 180);
    double endLongitudeRad = endLongitude * (pi / 180);

    double dLat = endLatitudeRad - startLatitudeRad;
    double dLon = endLongitudeRad - startLongitudeRad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(startLatitudeRad) *
            cos(endLatitudeRad) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadiusKm * c;

    return distance; // Distance in kilometers
  }

// หากจังหวัดที่ใกล้ที่สุด เทียบกับพิกัดรถ
  void findClosestLocation(
      List<dynamic> data, double userLatitude, double userLongitude) {
    double closestDistance = double.infinity;
    Map<String, dynamic>? closestLocation;

    for (var location in data) {
      double locationLatitude = double.parse(location['letitude']);
      double locationLongitude = double.parse(location['longitude']);

      double distance = calculateDistance(
          userLatitude, userLongitude, locationLatitude, locationLongitude);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestLocation = location;
      }
    }

    if (closestLocation != null) {
      // print(
      //     'กำลังเดินทางจาก: ${closestLocation['ship_point']} ไปยัง ${closestLocation['province']}');
      // print(
      //     'เหลือระยะทางประมาณ: ${closestDistance.toStringAsFixed(2)} กิโลเมตรก่อนถึงปลายทาง');
      if (closestDistance <= 10) {
        data1 = "";
        setState(() {
          checkinData = data;
          data2 = "";
          data1 =
              "กำลังเดินทางจาก: ${closestLocation!['ship_point']} ไปยัง ${closestLocation['province']} เหลือระยะทางประมาณ: ${closestDistance.toStringAsFixed(2)} กิโลเมตรก่อนถึงปลายทาง เช็คอินได้แล้ว!";
        });
      } else {
        data2 = "";
        setState(() {
          data1 = "";
          data2 =
              "กำลังเดินทางจาก: ${closestLocation!['ship_point']} ไปยัง ${closestLocation['province']} เหลือระยะทางประมาณ: ${closestDistance.toStringAsFixed(2)} กิโลเมตรก่อนถึงปลายทาง ยัง checkin ไม่ได้";
        });
      }
    } else {
      print('No locations found.');
    }
  }
} // end of class