import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/screen/home_screen.dart';
import 'package:salon_bunda/salon/screen/login_register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salon_bunda/salon/service/api_service.dart'; // Untuk memeriksa token awal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Periksa apakah token sudah ada saat aplikasi dimulai
  final String? token = await ApiService.getToken();
  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Booking Layanan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}