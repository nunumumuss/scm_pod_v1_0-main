import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fec_corp_app/services/auth_service.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            accountName: Text('${context.watch<AccountProvider>().account?.name} ทะเบียน: ${context.watch<AccountProvider>().account?.carLicense} '),
            accountEmail: Text('${context.watch<AccountProvider>().account?.email}'),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text('หน้าหลัก'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Get.offNamedUntil('/home', (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_sharp),
            title: const Text('เกี่ยวกับเรา'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Get.offNamedUntil(
                  '/about',
                  arguments: {
                    'companyName': 'Fec Corp',
                    'companyPhone': '0288888888'
                  },
                  (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warehouse_sharp),
            title: const Text('คลังสินค้า'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () {
              Get.offNamedUntil('/warehouse', (route) => false);
            },
          ),
          const Divider(),
    
          ListTile(
            leading: const Icon(Icons.logout_sharp),
            title: const Text('Sign Out'),
            trailing: const Icon(Icons.arrow_right),
            onTap: () async {
              await authService.logout();
              Get.offNamedUntil('/login', (route) => false);
            },
          ), 
        ],
      ),
    );
  }
}
