import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/screen/home_screen.dart';
import 'package:salon_bunda/salon/screen/login_register.dart';
import 'package:salon_bunda/salon/service/api_service.dart'; // Pastikan path ini benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Periksa apakah token sudah ada saat aplikasi dimulai
  final String? token = await ApiService.getToken();
  // Tentukan rute awal berdasarkan keberadaan token
  final String initialRoute =
      token != null && token.isNotEmpty ? '/home' : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Booking Layanan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      // Menggunakan initialRoute untuk menentukan halaman pertama
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
