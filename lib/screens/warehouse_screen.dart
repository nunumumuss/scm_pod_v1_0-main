// When using TCE-API, please change 'getdata2' to 'getdata' in the initState function 

import 'package:fec_corp_app/constants/constants.dart';
import 'package:fec_corp_app/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  Future<List<dynamic>>? warehouseFuture;

  Future<List<dynamic>> getData() async {
    String apiUri = Constants.apiServer + Constants.ApiPodWarehouse; 
    final res =  await http.get(Uri.parse(apiUri));   
 
    String resBody = utf8.decode(res.bodyBytes);
    if (res.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(resBody);
      List<Map<String, dynamic>> warehouse = List<Map<String, dynamic>>.from(jsonData['results']);
      
      // print(warehouse);
      return warehouse;
    } else {
      // 400 404 401 500
      throw Exception('เกิดข้อผิดพลาดจาก Server โปรดลองใหม่');
    }
  }
 
  @override
  void initState() {
    warehouseFuture = getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      key: _key,
      appBar: AppBar(
        leading: IconButton.outlined(
            onPressed: () {
              _key.currentState!.openDrawer();
            },
            icon: const Icon(Icons.menu)),
        title: const Text('WareHouse Sites'),
        backgroundColor: const Color.fromARGB(255, 225, 55, 55),
        toolbarHeight: 80,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: warehouseFuture, 
        builder: (context, snapshot) {
           if (snapshot.hasData) {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.business),
                    title: Text('${snapshot.data![index]['desct']}'),
                    subtitle: Text('Tel: ${snapshot.data![index]['tel']}'),
                    // subtitle: Text('Location:${snapshot.data![index]['latitude']} , ${snapshot.data![index]['longitude']}'),
                    trailing: Text('${snapshot.data![index]['site']}'),
                  );
                }, 
                separatorBuilder: (context, index) => const Divider(), 
                itemCount: snapshot.data!.length
              );
           } 
           if (snapshot.hasError) {
              return Text('${snapshot.error}');
           }
           if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Text('ไม่มีข้อมูลจาก Server');
           }
           if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
           }

           return const Text('เกิดข้อผิดพลาด โปรดลองใหม่');
        }
      )
    );
  }
}
