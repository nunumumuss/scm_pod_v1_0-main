import 'package:fec_corp_app/constants/constants.dart'; 
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

// Define a global variable for user_carlicense
String user_carlicense = '';

class LoadedScreen extends StatefulWidget {
  const LoadedScreen({super.key});

  @override
  State<LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends State<LoadedScreen> {
  final authService = AuthService();
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;

  Future<void> getData(String carLicense) async {
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodLoaded}?car_license=${carLicense}';
      final res = await http.get(Uri.parse(apiUri));
      String resBody = utf8.decode(res.bodyBytes);
      if (res.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(resBody);
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
  Future<void> postCfloaded(List<String> shipmentIds) async { // Accept a list of shipment IDs
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodLoaded}'; // Make sure to include the correct base URL

      // Prepare the request body as a JSON array
      String body = jsonEncode(shipmentIds); // Directly encode the list of strings
    
      // Send the POST request
      final res  = await http.post(
        Uri.parse(apiUri),
        headers: {
          'Content-Type': 'application/json', // Set the content type to JSON
        },
        body: body, // Encode the body to JSON
      );       
      

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        // Show a dialog with the success message and a button to confirm
        _showConfirmationDialog(responseData['message']);
      } else if (res.statusCode == 404) {         
        _showConfirmationDialog('ไม่มีข้อมูลที่ยืนยัน Loaded');
        
      } else {
        _showConfirmationDialog('เกิดข้อผิดพลาด ${res.statusCode} โปรดลองใหม่');
      }
    } catch (e) {
       _showConfirmationDialog('เกิดข้อผิดพลาด ${e} โปรดลองใหม่');
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
          title: const Text('รอขึ้นสินค้า'),
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
          ? const Text('รอขึ้นสินค้า') 
          : Text('รอขึ้นสินค้า ${deliveryReport.length} รายการ'),
        backgroundColor: Colors.red.shade400,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
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
                title: Text('Shipment No.: ${element['shipid']}  ${element['pick_stat']}'),
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
              ElevatedButton(
                onPressed: () {
                  List<String> shipmentIds = deliveryReport
                  .map((element) => element['shipid'] as String) // Map to extract shipid
                  .toList();
                  postCfloaded(shipmentIds); // Call the API when the button is pressed
                },
                style: ElevatedButton.styleFrom(
                        // foregroundColor: Colors.white, backgroundColor: Colors.red)), // text color
                        foregroundColor: Colors.white, 
                        backgroundColor:  Colors.red, // text color
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                child: const Text('ยืนยันขึ้นสินค้าสำเร็จ'),
              ),
            ],
          ),
        ],
      ),    
    );
  }
}
