import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/screen/home_screen.dart';
import 'package:salon_bunda/salon/screen/login_register.dart';
import 'package:salon_bunda/salon/screen/splash_screen.dart'; // Import SplashScreen yang baru Anda buat
// import 'package:shared_preferences/shared_preferences.dart'; // Tidak lagi diperlukan di main.dart
// import 'package:salon_bunda/salon/service/api_service.dart'; // Tidak lagi diperlukan di main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tidak perlu lagi memeriksa token di sini.
  // Pemeriksaan token akan dilakukan di dalam SplashScreen.
  runApp(const MyApp()); // MyApp sekarang selalu dimulai dengan SplashScreen
}

class MyApp extends StatelessWidget {
  // initialRoute tidak lagi diperlukan di sini karena kita menggunakan home
  const MyApp({Key? key}) : super(key: key);

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
      home: const SplashScreen(), // Atur SplashScreen sebagai halaman awal
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}