import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:fec_corp_app/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  final authService = AuthService();

  @override
  void initState() {
    Provider.of<AccountProvider>(context, listen: false).getAccount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        drawer: const MenuDrawer(),
        appBar: AppBar(
          leading: IconButton.outlined(
              onPressed: () {
                _key.currentState!.openDrawer();
              },
              icon: const Icon(Icons.menu)),
          title: Image.asset('assets/images/logo02.png', height: 50),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 225, 55, 55),
          toolbarHeight: 80,
          actions: [
            IconButton(onPressed: () => {}, icon: const Icon(Icons.help)),
          ],
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            InkWell(
              onTap: () {
                Get.toNamed('/checkin');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 35, 223, 154),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 60, color: Colors.white),
                    Text('Check In',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),

            InkWell(
              onTap: () {
                Get.toNamed('/confirm');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 35, 223, 154),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_bus_sharp, size: 60, color: Colors.white),
                    Text('Confirm',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text('Delivery',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),
 
            InkWell(
              onTap: () => {Get.toNamed('/picked')},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0xFFDF2329),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message_sharp, size: 60, color: Colors.white),
                    Text('Message',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text('Alert',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => {Get.toNamed('/rvdelivery')},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color(0xFFDF2329),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bus_alert_rounded, size: 60, color: Colors.white),
                    Text('Reverse',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text('Confirm Delivery',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),
             
            
            InkWell(
              onTap: () => {Get.toNamed('/loaded')},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 40, 182, 253),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_sharp, size: 60, color: Colors.white),
                    Text('Confirm',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text('Loading',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),
            
            InkWell(
              onTap: () => {Get.toNamed('/check-delivery')},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 40, 182, 253),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_sharp, size: 60, color: Colors.white),
                    Text('Check Delivery',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    Text('Status',
                        style: TextStyle(fontSize: 20, color: Colors.white))
                  ],
                ),
              ),
            ),
            
          ],
        ));
  }
}
