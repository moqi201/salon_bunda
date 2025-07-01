// import 'dart:async'; // Untuk Timer

// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// // Import halaman utama Anda (ganti dengan nama file yang sesuai)
// import 'package:salon_bunda/salon/screen/login_register.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;
//   late AnimationController _lottieController; // Controller untuk animasi Lottie

//   @override
//   void initState() {
//     super.initState();

//     // Inisialisasi AnimationController untuk FadeTransition
//     _fadeController = AnimationController(
//       duration: const Duration(seconds: 2), // Durasi fade in
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _fadeController,
//         curve: Curves.easeIn, // Kurva animasi ease-in
//       ),
//     );

//     // Inisialisasi AnimationController untuk ScaleTransition
//     _scaleController = AnimationController(
//       duration: const Duration(seconds: 2), // Durasi scale
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       // Mulai dari 80% ukuran asli
//       CurvedAnimation(
//         parent: _scaleController,
//         curve: Curves.easeOutBack, // Kurva animasi sedikit memantul di akhir
//       ),
//     );

//     // Inisialisasi AnimationController untuk Lottie
//     _lottieController = AnimationController(vsync: this);

//     // Jalankan animasi fade dan scale secara bersamaan
//     _fadeController.forward();
//     _scaleController.forward();

//     // Navigasi ke halaman utama setelah beberapa saat (misal: 4 detik)
//     Timer(const Duration(seconds: 4), () {
//       // Pastikan widget masih mounted sebelum melakukan navigasi
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => const LoginRegisterScreen(),
//           ), // Ganti dengan halaman utama Anda
//         );
//       }
//     });

//     // Loop Lottie animation (jika diinginkan)
//     _lottieController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _lottieController.repeat(); // Ulangi animasi setelah selesai
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _scaleController.dispose();
//     _lottieController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Sesuaikan warna latar belakang
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Efek Fade dan Scale pada gambar logo
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Image.asset(
//                   'assets/image/STUDIP.png', // Path gambar logo Anda
//                   width: 200, // Sesuaikan ukuran gambar
//                   height: 200,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             // Animasi Lottie (opsional, sebagai indikator loading atau pemanis)
//             Lottie.asset(
//               'assets/lottie/Animation - 1751259356339.json', // Path animasi Lottie Anda
//               controller: _lottieController,
//               onLoaded: (composition) {
//                 _lottieController
//                   ..duration = composition.duration
//                   ..forward();
//               },
//               width: 100, // Sesuaikan ukuran animasi Lottie
//               height: 100,
//               repeat: true, // Biarkan Lottie berulang
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Studio Salon Glowrilla',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
