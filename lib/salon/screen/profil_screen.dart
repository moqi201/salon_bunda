// lib/salon/screen/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:salon_bunda/salon/model/user_model.dart'; // Import user_model.dart untuk kelas User
import 'package:salon_bunda/salon/screen/login_register.dart';
import 'package:salon_bunda/salon/screen/verif/hapus_service.dart';
import 'package:salon_bunda/salon/screen/verif/verif.dart'; // Asumsi EditBooking ada di sini, jika tidak, sesuaikan path
import 'package:salon_bunda/salon/service/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Definisikan palet warna konsisten
  static const Color _primaryAccentBlue = Color(
    0xDD000000,
  ); // Deep, sophisticated blue
  static const Color _darkCharcoal = Color(0xFF212121); // Deep charcoal
  static const Color _lightGreyBackground = Color(
    0xFFF5F5F5,
  ); // Lighter grey for background
  static const Color _mediumGreyText = Color(
    0xFF424242,
  ); // Darker grey for details
  static const Color _lightDivider = Color(
    0xFFE0E0E0,
  ); // Lighter grey for dividers
  static const Color _iconGrey = Color(
    0xFF757575,
  ); // Slightly darker grey for icons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreyBackground, // Latar belakang abu-abu terang
      appBar: AppBar(
        title: const Text(
          'My Profile', // Judul lebih menarik
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ), // White logout icon
            onPressed: () async {
              await ApiService.deleteToken();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginRegisterScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.black87, // AppBar putih
        elevation: 1, // Elevasi tipis untuk bayangan lembut
        // shadowColor: Colors.grey.withOpacity(0.3), // Bayangan abu-abu lembut
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ), // Ikon panah kembali hitam
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: FutureBuilder<User?>(
        // Mengambil data user dari ApiService
        future: ApiService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/Animation - 1751259356339.json',
                width: 150, // Sesuaikan ukuran sesuai kebutuhan
                height: 150, // Sesuaikan ukuran sesuai kebutuhan
                fit: BoxFit.contain,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline, // Ikon error
                      color: Colors.black, // Warna ikon hitam
                      size: 70,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Failed to load profile. Please try again later.\n\nDetails: ${snapshot.error}', // Pesan error lebih informatif
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_outlined, // Ikon untuk "tidak ada data"
                      color: Colors.grey,
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Profile data not available. Please log in or create an account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final user = snapshot.data!;
            // Cek apakah email user adalah 'Mq@gmail.com'

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                0.2,
                              ), // Bayangan lembut untuk avatar
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              Colors.blueGrey.shade700, // Masculine tone
                          backgroundImage:
                              user.email != null
                                  ? NetworkImage(
                                    'https://www.gravatar.com/avatar/${user.email!.hashCode}?d=identicon',
                                  )
                                  : null,
                          child:
                              user.email == null
                                  ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Spasi lebih besar
                    Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _darkCharcoal, // Judul bagian hitam
                      ),
                    ),
                    const SizedBox(height: 15), // Spasi setelah judul bagian
                    _buildProfileInfoCard(
                      Icons.person_outline,
                      'Name',
                      user.name ?? 'N/A',
                    ),
                    _buildProfileInfoCard(
                      Icons.email_outlined,
                      'Email',
                      user.email ?? 'N/A',
                    ),
                    _buildProfileInfoCard(
                      Icons.date_range,
                      'Joined Since',
                      user.createdAt != null
                          ? user.createdAt!.toLocal().toString().split(' ')[0]
                          : 'N/A',
                    ),
                    _buildProfileInfoCard(
                      Icons.update,
                      'Last Updated',
                      user.updatedAt != null
                          ? user.updatedAt!.toLocal().toString().split(' ')[0]
                          : 'N/A',
                    ),
                    const SizedBox(height: 40),
                    const Divider(
                      height: 1,
                      color: _lightDivider,
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 40),

                    // --- Conditional Admin Actions ---// Hanya tampilkan jika user adalah admin
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Actions', // Judul untuk bagian tombol
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildManagementButton(
                          context,
                          icon: Icons.delete_sweep_outlined,
                          label: 'Manage Services ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HapusService(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildManagementButton(
                          context,
                          icon: Icons.edit_calendar_outlined,
                          label: 'Manage Bookings ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const EditBooking(), // Pastikan EditBooking ada
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // --- Akhir Conditional Admin Actions ---
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Widget pembantu untuk baris info profil dalam bentuk Card
  Widget _buildProfileInfoCard(IconData icon, String title, String value) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(icon, size: 28, color: _iconGrey),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _mediumGreyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu baru untuk tombol manajemen
  Widget _buildManagementButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Tinggi tombol konsisten
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28, // Ukuran ikon lebih besar
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87, // Biru tua sebagai aksen
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Sudut membulat
          ),
          elevation: 5, // Sedikit bayangan
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }
}
