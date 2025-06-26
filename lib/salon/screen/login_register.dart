import 'package:flutter/material.dart';
// import 'package:salon_bunda/salon/model/login_models.dart'; // Ini sepertinya tidak lagi digunakan, bisa dihapus jika memang tidak ada kelas LoginModels di dalamnya
import 'package:salon_bunda/salon/model/user_model.dart'; // Import user_model.dart untuk kelas User
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/custom_text_field.dart';
import 'package:salon_bunda/salon/model/base_response.dart'; // Pastikan ini adalah BaseResponse yang sudah diubah ke nullable (String? message, bool? success)
import 'package:salon_bunda/salon/model/auth_response.dart'; // MENAMBAHKAN: Import AuthData dari auth_response.dart (bukan auth_response_model.dart jika nama filenya auth_response.dart)
import 'home_screen.dart'; // Navigasi ke Home Screen setelah login
// import 'package:salon_bunda/salon/screen/profil_screen.dart'; // Jika tidak digunakan, bisa dihapus
// import 'package:salon_bunda/salon/screen/riwayat_booking.dart'; // Jika tidak digunakan, bisa dihapus

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

    // Pastikan widget masih mounted sebelum menggunakan context
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Perbaikan penanganan respons API dengan null-safety yang benar
    if (authResponse != null && authResponse.success == true) {
      // Cek eksplisit success == true
      // Autentikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authResponse.message ?? 'Autentikasi berhasil!',
          ), // Gunakan ?? untuk pesan default
        ),
      );
      // Navigasi ke home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Autentikasi gagal
      String errorMessage = 'Autentikasi gagal. Silakan coba lagi.';
      if (authResponse != null) {
        // Jika ada pesan umum dari API
        if (authResponse.message != null && authResponse.message!.isNotEmpty) {
          // Cek null dan empty string
          errorMessage =
              authResponse.message!; // Gunakan ! setelah cek isNotEmpty
        }

        // Jika ada pesan error validasi dari API
        if (authResponse.errors != null) {
          authResponse.errors?.forEach((key, value) {
            if (value is List) {
              // Pastikan value adalah List
              errorMessage += '\n${value.join(', ')}'; // Gabungkan list error
            } else {
              errorMessage += '\n$value'; // Jika error bukan list
            }
          });
        }
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
        foregroundColor: Colors.white, // Tambahkan ini untuk warna teks AppBar
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
                        foregroundColor:
                            Colors
                                .white, // Tambahkan ini untuk warna teks tombol
                      ),
                      child: Text(
                        _isRegisterMode ? 'Register' : 'Login',
                        style: const TextStyle(
                          fontSize: 18,
                          // color: Colors.white, // Dihapus karena sudah di set di foregroundColor
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
