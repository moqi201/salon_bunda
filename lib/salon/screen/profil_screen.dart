import 'package:flutter/material.dart';
// Mengubah impor login_model.dart untuk menyembunyikan kelas User
import 'package:salon_bunda/salon/model/login_models.dart' hide User;
import 'package:salon_bunda/salon/model/user_model.dart'; // Import user_model.dart untuk kelas User
import 'package:salon_bunda/salon/service/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<User?>(
        // Mengambil data user dari ApiService
        future: ApiService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Data profil tidak tersedia. Silakan login.'),
            );
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueGrey.shade100,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileInfoRow(
                    Icons.person_outline,
                    'Nama',
                    user.name ?? 'N/A',
                  ),
                  const Divider(),
                  _buildProfileInfoRow(
                    Icons.email_outlined,
                    'Email',
                    user.email ?? 'N/A',
                  ),
                  const Divider(),
                  _buildProfileInfoRow(
                    Icons.date_range,
                    'Bergabung Sejak',
                    user.createdAt != null
                        ? user.createdAt!.toLocal().toString().split(' ')[0]
                        : 'N/A',
                  ),
                  const Divider(),
                  _buildProfileInfoRow(
                    Icons.update,
                    'Terakhir Diperbarui',
                    user.updatedAt != null
                        ? user.updatedAt!.toLocal().toString().split(' ')[0]
                        : 'N/A',
                  ),
                  const Divider(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Widget pembantu untuk baris info profil
  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blueGrey.shade700),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
