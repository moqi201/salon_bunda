// lib/salon/screen/riwayat_booking.dart

import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class RiwayatBookingScreen extends StatefulWidget {
  const RiwayatBookingScreen({super.key});

  @override
  State<RiwayatBookingScreen> createState() => _RiwayatBookingScreenState();
}

class _RiwayatBookingScreenState extends State<RiwayatBookingScreen> {
  late Future<List<Datum>?> _riwayatBooking;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // PERBAIKAN DI SINI:
    // Menggunakan .then() untuk mengekstrak 'data' dari BaseResponse
    _riwayatBooking = _apiService
        .getRiwayatBooking()
        .then((response) {
          if (response != null && response.data != null) {
            return response.data;
          }
          return null; // Mengembalikan null jika response atau data-nya null
        })
        .catchError((error) {
          // Tangani error jika terjadi dalam Future
          print('Error fetching riwayat booking: $error');
          return null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        backgroundColor: Colors.pink.shade100, // Contoh warna AppBar
      ),
      body: FutureBuilder<List<Datum>?>(
        future: _riwayatBooking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada riwayat booking.'));
          } else {
            final List<Datum> bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.service?.name ??
                              'Nama Layanan Tidak Diketahui',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waktu Booking: ${booking.bookingTime?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${booking.status ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                booking.status == 'confirmed'
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (booking.service != null) ...[
                          Text(
                            'Deskripsi: ${booking.service!.description ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Harga: Rp ${booking.service!.price ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Karyawan: ${booking.service!.employeeName ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (booking.service!.servicePhotoUrl != null &&
                              booking.service!.servicePhotoUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  booking.service!.servicePhotoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 100,
                                            color: Colors.grey,
                                          ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
