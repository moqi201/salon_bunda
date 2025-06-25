import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/login_models.dart'; // Pastikan nama file ini login_model.dart (singular)
import 'package:salon_bunda/salon/model/user_model.dart'; // Import user_model.dart untuk kelas User
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/custom_text_field.dart';
import 'package:salon_bunda/salon/model/base_response.dart'; // MEMBETULKAN: Mengubah dari base_response.dart ke base_response_model.dart
import 'package:salon_bunda/salon/model/auth_response.dart'; // MENAMBAHKAN: Import AuthData dari auth_response_model.dart
import 'home_screen.dart'; // Navigasi ke Home Screen setelah login
import 'package:salon_bunda/salon/screen/profil_screen.dart'; // MEMBETULKAN: Mengubah dari profil_screen.dart ke profile_screen.dart
import 'package:salon_bunda/salon/screen/riwayat_booking.dart'; // MEMBETULKAN: Mengubah dari riwayat_booking.dart ke riwayat_booking_screen.dart

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isRegisterMode = false;

  Future<void> _performAuth(bool isRegister) async {
    setState(() {
      _isLoading = true;
    });

    BaseResponse<AuthData>? authResponse; // Menggunakan BaseResponse<AuthData>
    if (isRegister) {
      authResponse = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
    } else {
      authResponse = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (authResponse != null && authResponse.data?.token != null) {
      // Autentikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authResponse.message),
        ), // Menampilkan pesan sukses dari API
      );
      // Navigasi ke home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Autentikasi gagal
      String errorMessage = 'Authentication failed. Please try again.';
      if (authResponse != null && authResponse.errors != null) {
        // Jika ada pesan error dari API (misal: validasi)
        errorMessage = authResponse.message; // Gunakan pesan utama
        authResponse.errors?.forEach((key, value) {
          errorMessage += '\n${value[0]}'; // Tambahkan detail error validasi
        });
      } else if (authResponse != null && authResponse.message.isNotEmpty) {
        // Jika ada pesan umum dari API
        errorMessage = authResponse.message;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Register' : 'Login'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRegisterMode ? 'Buat Akun Baru' : 'Selamat Datang Kembali!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 30),
              if (_isRegisterMode)
              CustomTextField(controller: _nameController, labelText: 'Name'),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _performAuth(_isRegisterMode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        _isRegisterMode ? 'Register' : 'Login',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                  });
                },
                child: Text(
                  _isRegisterMode
                      ? 'Sudah punya akun? Login di sini'
                      : 'Belum punya akun? Daftar di sini',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
