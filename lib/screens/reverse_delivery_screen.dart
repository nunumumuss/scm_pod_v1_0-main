import 'package:fec_corp_app/constants/constants.dart'; 
import 'package:fec_corp_app/services/auth_service.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';
 

// Define a global variable for user_billno
String user_billno = '';

class RevDeliveryScreen extends StatefulWidget { // Changed class name to RevDelivery
  const RevDeliveryScreen({super.key});

  @override
  State<RevDeliveryScreen> createState() => _RevDeliveryScreenState();
}

class _RevDeliveryScreenState extends State<RevDeliveryScreen> {
  final authService = AuthService();
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;
  final TextEditingController billNoController = TextEditingController(); // Changed to billNoController

  Future<void> getData(String billNo) async { // Changed parameter to billNo
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodCfDelivery}?bill_no=${billNo}'; // Changed API endpoint
      final res = await http.get(Uri.parse(apiUri));

      if (res.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(res.body);
        List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonData['results']);
        setState(() {
          deliveryReport = resData;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          error = "${res.statusCode} ไม่มีข้อมูล";
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

  Future<void> postCFRVdelivery(String billNo) async { // Changed function name to postCFRVdelivery
    try {
      setState(() {
        isLoading = true;
      });

      String apiUri = '${Constants.apiServer}${Constants.ApiPodCfDelivery}?bill_no=${billNo}'; // Changed API endpoint
      final res = await http.post(Uri.parse(apiUri));

      if (res.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(res.body);
        // Show a dialog with the success message and a button to confirm
        _showConfirmationDialog(responseData['message']);
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
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {     
    super.initState();
    // Removed user login info dependency
    // Uncomment the following line if you want to call getData() with a predefined bill number for testing.
    // getData('example_bill_number');  
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Message Alert'),
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
          ? const Text('รอขึ้นสินค้าสำเร็จ') 
          : Text('รอขึ้นสินค้าสำเร็จ ${deliveryReport.length} รายการ'),
        backgroundColor: Colors.red.shade400,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: billNoController, // Input for bill number
                  decoration: const InputDecoration(
                    labelText: 'กรุณากรอกหมายเลขบิล',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: GroupedListView<dynamic, String>(
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
              ),
            ],
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
                  // Call getData with the input bill number when the button is pressed
                  String billNo = billNoController.text.trim();
                  if (billNo.isNotEmpty) {
                    getData(billNo); // Fetch data using the input bill number
                  } else {
                    // Handle empty input if needed
                    Get.snackbar('Error', 'กรุณากรอกหมายเลขบิล'); // Show error message
                  }
                },
                child: const Text('ยกเลิกการยืนยันส่งสินค้าสำเร็จ'),
              ),
            ],
          ),
        ],
      ),    
    );
  }
}
