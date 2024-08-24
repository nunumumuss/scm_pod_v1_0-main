import 'package:fec_corp_app/constants/constants.dart';
import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class CheckDeliveryScreen extends StatefulWidget {
  const CheckDeliveryScreen({super.key});

  @override
  State<CheckDeliveryScreen> createState() => _CheckDeliveryScreenState();
}

class _CheckDeliveryScreenState extends State<CheckDeliveryScreen> {
  List<dynamic> deliveryReport = [];
  bool isLoading = false;
  String? error;

  Future<void> getData(String carLicense) async {
    try {
    setState(() {
      isLoading = true;
    });  

    String apiUri = Constants.apiServer + Constants.ApiPodDeliveryLog + '?car_license=' + carLicense; 
    print(apiUri);
    final res =  await http.get(Uri.parse(apiUri));  
    // var res = await http.get(       Uri.parse('https://api.codingthailand.com/api/fec-corp/check-delivery?car_license=$carLicense'));

    // print(res.body);
    if (res.statusCode == 200) {
        // List<dynamic> resData = json.decode(res.body);
        String resBody = utf8.decode(res.bodyBytes);
        Map<String, dynamic> jsonData = jsonDecode(resBody);
        List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonData['results']);
        setState(() {
          deliveryReport = resData;
          // print (deliveryReport);
          // print(res);
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
    String? carLicense = accountProvider.account?.carLicense; // Safely access account name
    // print (user_name); 
    String apiUri = '${Constants.apiServer}${Constants.ApiPodDeliveryLog}?car_license=$carLicense'; 
    print(apiUri);
    getData(carLicense!); // กท1 / กท0
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
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
        title:  deliveryReport.isEmpty ? const Text('สถานะการส่งสินค้า') : 
        Text('สถานะการส่งสินค้า ${deliveryReport.length} รายการ'),
      ),
      body: isLoading ? 
            const Center(
              child: CircularProgressIndicator()
            )
           : GroupedListView<dynamic, String>(
            elements: deliveryReport,
            groupBy: (element) => element['shipid'],
            groupSeparatorBuilder: (String groupByValue) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Shipment ID: $groupByValue', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            itemBuilder: (context, dynamic element) => Card(
               elevation: 8.0,
               margin: const EdgeInsets.all(5.0),
               child: ListTile(
                 leading: const Icon(Icons.newspaper),
                 title: Text('DO: ${element['doid']} Bill: ${element['billno']}'), 
                 subtitle: Text('${element['cusname']}'),
                 trailing: Text(element['do_stat']),
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