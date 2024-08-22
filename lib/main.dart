// flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
import 'package:fec_corp_app/providers/account_provider.dart';
import 'package:fec_corp_app/screens/about_screen.dart';
import 'package:fec_corp_app/screens/check_delivery_screen.dart';
import 'package:fec_corp_app/screens/checkin_screen.dart';
import 'package:fec_corp_app/screens/confirm_screen.dart';
import 'package:fec_corp_app/screens/fail_screen.dart';
import 'package:fec_corp_app/screens/home_screen.dart';
import 'package:fec_corp_app/screens/loaded_screen.dart';
import 'package:fec_corp_app/screens/login_screen.dart';
import 'package:fec_corp_app/screens/picked_screen.dart';
import 'package:fec_corp_app/screens/reverse_delivery_screen.dart';
import 'package:fec_corp_app/screens/warehouse_screen.dart';
import 'package:fec_corp_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

bool isLogIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  isLogIn = await authService.checkIsLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TCE LIMS',
      theme: ThemeData(
        fontFamily: 'K2D',
        colorSchemeSeed: const Color(0xFFDF2329),
        // colorSchemeSeed: const Color(0xFFDF2329), // #df2329 from web (hex color)
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFFDF2329),
        //   secondary: Colors.blue
        //   onSurface: Colors.grey,
        //   onSurfaceVariant: Colors.yellow,
        //   onPrimaryContainer: const Color.fromARGB(255, 244, 246, 244),
        // ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold)
        ),
        useMaterial3: true,
      ),
      // home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: isLogIn ? '/home' : '/login',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/about', page: () => const AboutScreen()),
        GetPage(name: '/check-delivery', page: () => const CheckDeliveryScreen()),
        GetPage(name: '/warehouse', page: () => const WarehouseScreen()),
        GetPage(name: '/checkin', page: () => const CheckinScreen()),
        GetPage(name: '/picked', page: () => const PickedScreen()),
        GetPage(name: '/loaded', page: () => const LoadedScreen()),
        GetPage(name: '/confirm', page: () => const ConfirmScreen()),
        GetPage(name: '/rvdelivery', page: () => const RevDeliveryScreen()),
        GetPage(name: '/fail', page: () => const FailScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
      ],
    );
  }
}

