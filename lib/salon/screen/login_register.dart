import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/auth_response.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

import 'home_screen.dart'; // Navigasi ke Home Screen setelah login

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

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
  bool _isPasswordVisible = false; // State untuk toggle visibilitas password

  // Definisikan palet warna yang konsisten
  static const Color _primaryColor = Colors.black87; // Biru yang menarik
  static const Color _accentColor = Color(0xFF50E3C2); // Aksen hijau muda
  static const Color _textColor = Color(0xFF333333); // Warna teks gelap
  static const Color _lightTextColor = Color(
    0xFF666666,
  ); // Warna teks lebih terang
  static const Color _backgroundColor = Color(
    0xFFF0F2F5,
  ); // Latar belakang abu-abu muda
  static const Color _errorColor = Color(0xFFD0021B); // Merah untuk error

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor ?? _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 8,
      ),
    );
  }

  Future<void> _performAuth(bool isRegister) async {
    // Validasi sederhana sebelum API call
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar(
        'Email dan Password harus diisi.',
        backgroundColor: _errorColor,
      );
      return;
    }
    if (isRegister && _nameController.text.isEmpty) {
      _showSnackBar(
        'Nama harus diisi untuk pendaftaran.',
        backgroundColor: _errorColor,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    BaseResponse<AuthData>? authResponse;
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

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (authResponse != null && authResponse.success == true) {
      _showSnackBar(
        authResponse.message ?? 'Autentikasi berhasil!',
        backgroundColor: _accentColor,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      String errorMessage = 'Autentikasi gagal. Silakan coba lagi.';
      if (authResponse != null) {
        if (authResponse.message != null && authResponse.message!.isNotEmpty) {
          errorMessage = authResponse.message!;
        }

        if (authResponse.errors != null) {
          authResponse.errors?.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n${value.join(', ')}';
            } else {
              errorMessage += '\n$value';
            }
          });
        }
      }
      _showSnackBar(errorMessage, backgroundColor: _errorColor);
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
      backgroundColor: _backgroundColor, // Latar belakang keseluruhan layar
      appBar: AppBar(
        title: Text(
          _isRegisterMode ? 'Daftar' : 'Masuk',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 0, // Hapus shadow AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image/studio3.png', // Pastikan path ini benar
                height: 150, // Sesuaikan tinggi gambar sesuai kebutuhan
              ),
              const SizedBox(height: 30),
              // Judul utama
              Text(
                _isRegisterMode ? 'Buat Akun Baru' : 'Selamat Datang Kembali!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isRegisterMode
                    ? 'Bergabunglah dengan Salon Bunda sekarang.'
                    : 'Silakan masuk untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: _lightTextColor),
              ),
              const SizedBox(height: 40),

              // Input Nama (hanya untuk Register)
              if (_isRegisterMode) ...[
                // TextField(
                //   controller: _nameController,
                //   decoration: InputDecoration(
                //     labelText: 'Nama Lengkap',
                //     prefixIcon: Icon(Icons.person),
                //   ),
                //   // Tambahkan ikon
                // ),
                TextField(
                  // Menggunakan TextField standar untuk kontrol lebih
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'nama lengkap',
                    labelStyle: TextStyle(color: _lightTextColor),
                    prefixIcon: Icon(
                      Icons.person_2_sharp,
                      color: _primaryColor,
                    ), // Ikon gembok
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: _primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: _primaryColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              TextField(
                // Menggunakan TextField standar untuk kontrol lebih
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: _lightTextColor),
                  prefixIcon: Icon(
                    Icons.email,
                    color: _primaryColor,
                  ), // Ikon gembok
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: _primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Input Password dengan Toggle Mata
              TextField(
                // Menggunakan TextField standar untuk kontrol lebih
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: _lightTextColor),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: _primaryColor,
                  ), // Ikon gembok
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _primaryColor, // Warna ikon toggle
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: _primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: _primaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Login/Register
              _isLoading
                  ? const CircularProgressIndicator(color: _primaryColor)
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _performAuth(_isRegisterMode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(_isRegisterMode ? 'Daftar' : 'Masuk'),
                    ),
                  ),
              const SizedBox(height: 20),

              // Tombol Toggle Mode (Login/Register)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                    // Bersihkan controller saat beralih mode
                    _emailController.clear();
                    _passwordController.clear();
                    _nameController.clear();
                    _isPasswordVisible = false; // Reset visibility
                  });
                },
                child: Text(
                  _isRegisterMode
                      ? 'Sudah punya akun? Masuk di sini'
                      : 'Belum punya akun? Daftar di sini',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
