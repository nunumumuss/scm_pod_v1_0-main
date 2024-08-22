import 'package:fec_corp_app/constants/constants.dart'; 
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as l;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

// Define a global variable for user_carlicense
String user_carlicense = '';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final authService = AuthService();
  bool gpsEnabled = false;
  bool permissionGranted = false;
  l.Location location = l.Location();
  l.LocationData? locationData;
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;

  Future<void> getData(String carLicense) async {
    try {
      setState(() {
        isLoading = true;
      });
      final locationData = await location.getLocation();
      double lat = locationData.latitude ?? 0.0; // Default to 0.0 if latitude is null
      double long = locationData.longitude ?? 0.0; // Default to 0.0 if latitude is null
      
      // Format the latitude to 5 decimal places
      String str_lat = lat.toStringAsFixed(5);
      String str_long = long.toStringAsFixed(5);

      String apiUri = '${Constants.apiServer}${Constants.ApiPodCheckin}?car_license=${carLicense}&latitude=${str_lat}&longitude=${str_long}'; 
      print(apiUri);
      final res = await http.get(Uri.parse(apiUri));

      if (res.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(res.body);
        List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonData['results']);
        setState(() {
          deliveryReport = resData;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          error = "ไม่มีข้อมูล";
        });
      } else {
        setState(() {
          error = "เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่";
        });
      }
    } catch (e) {
      setState(() {
        error = "เกิดข้อผิดพลาด โปรดลองใหม่";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> postCfCheckin(String carLicense) async {
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodLoaded}?car_license=${carLicense}';
      final res = await http.post(Uri.parse(apiUri));

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        // Show a dialog with the success message and a button to confirm
        _showConfirmationDialog(responseData['message']);
      } else if (res.statusCode == 404) {
        setState(() {
          error = "ไม่มีข้อมูลที่ยืนยัน Check In";
        });
      } else {
        setState(() {
          error = "เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่";
        });
      }
    } catch (e) {
      setState(() {
        error = "เกิดข้อผิดพลาด โปรดลองใหม่";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ผลการดำเนินการ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAllNamed('/home'); // Clear stack and go to home
              },
              child: const Text('ฺBack to home'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {     
    super.initState();
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    user_carlicense = accountProvider.account!.carLicense; 
    getData(user_carlicense);  
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Check In'),
          backgroundColor: Colors.red.shade400,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(' $error'),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                }, 
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: deliveryReport.isEmpty 
          ? const Text('Check In') 
          : Text('Check In ${deliveryReport.length} รายการ'),
        backgroundColor: Colors.red.shade400,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : deliveryReport.isNotEmpty && deliveryReport.any((element) => element.containsKey('site')) 
            ? GroupedListView<dynamic, String>(
                elements: deliveryReport,
                groupBy: (element) => element['site'],
                groupSeparatorBuilder: (String groupByValue) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'คลังสินค้า: $groupByValue', 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                itemBuilder: (context, dynamic element) => Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.all(5.0),
                  child: ListTile(
                    leading: const Icon(Icons.newspaper),
                    title: Text('ระยะห่างระหว่างคลังสินค้า : ${element['distance']}'),  
                  ), 
                ),
                useStickyGroupSeparators: true,
                order: GroupedListOrder.DESC,
              )
            : GroupedListView<dynamic, String>(
                elements: deliveryReport,
                groupBy: (element) => element['ship_point'],
                groupSeparatorBuilder: (String groupByValue) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'คลังสินค้า: $groupByValue', 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                itemBuilder: (context, dynamic element) => Card(
                  elevation: 8.0,
                  margin: const EdgeInsets.all(5.0),
                  child: ListTile(
                    leading: const Icon(Icons.newspaper),
                    title: Text('Shipment No.: ${element['shipid']}'),
                    trailing: Text('หน้าท่า: ${element['dock_no']}'),
                    subtitle: Text(element['province']),
                  ), 
                ),
                useStickyGroupSeparators: true,
                order: GroupedListOrder.DESC,
              ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show the button only if there is a site "SW" in deliveryReport
              if (!deliveryReport.any((element) => element.containsKey('site')))
                ElevatedButton(
                  onPressed: () {
                    postCfCheckin(user_carlicense); // Call the API when the button is pressed
                  },
                  child: const Text('ยืนยัน Check In'),
                ),
            ],
          ),
        ],
      ),      
    );
  }
}
