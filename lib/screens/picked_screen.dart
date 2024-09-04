import 'package:fec_corp_app/constants/constants.dart'; 
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class PickedScreen extends StatefulWidget {
  const PickedScreen({super.key});

  @override
  State<PickedScreen> createState() => _PickedScreenState();
}

class _PickedScreenState extends State<PickedScreen> {
  final authService = AuthService();
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;
 
  Future<void> getData(String carLicense) async {
    try {
    setState(() {
      isLoading = true;
    });  
    
    String apiUri = '${Constants.apiServer}${Constants.ApiPodPicked}?car_license=${carLicense}';
    final res =  await http.get(Uri.parse(apiUri));  
    String resBody = utf8.decode(res.bodyBytes);
    // print(res.body);
    if (res.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(resBody);
        List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonData['results']);
        setState(() {
          deliveryReport = resData;
          print(deliveryReport);
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

  @override
  void initState() {     
    // Get the account provider and assign account name to user_name
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    String? user_name = accountProvider.account?.carLicense; // Safely access account name
    // print (user_name);
    getData(user_name!); // กท1 / กท0
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
        title: const Text('พร้อมให้ load สินค้า' ),
        backgroundColor: Colors.red.shade400,
      ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$error'),
              ElevatedButton(
                onPressed: () {
                    Get.back();
                }, 
                child: const Text('Back to home')
              )
            ], 
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:  deliveryReport.isEmpty ? const Text('พร้อมให้ load สินค้า'): 
        Text('พร้อมให้ load สินค้า ${deliveryReport.length} รายการ'),
        backgroundColor: Colors.red.shade400,
      ),
      body: isLoading ? 
            const Center(
              child: CircularProgressIndicator()
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
                 title: Text('Shipment No.: ${element['shipid']}  ${element['pick_stat']}'),
                 trailing: Text('หน้าท่า: ${element['dock_no']}'),
                 subtitle: Text(element['province']),
               ), 
            ),
            // itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']), // optional
            useStickyGroupSeparators: true, // optional
            // floatingHeader: true, // optional
            order: GroupedListOrder.DESC, // optional
            // footer: const Text("Widget at the bottom of list"), // optional
          ),
      
    );
  }
}