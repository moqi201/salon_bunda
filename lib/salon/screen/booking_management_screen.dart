// lib/salon/screen/booking_management_screen.dart (File Diperbarui)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart'
    as riwayat_alias;
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/booking_dialog.dart'; // Impor dialog baru

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({
    super.key,
  }); // Tidak lagi memerlukan bookingDatum

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<riwayat_alias.Datum>?>
  _bookingsFuture; // Future untuk mengambil data
  List<riwayat_alias.Datum> _bookings = []; // Daftar booking yang sebenarnya
  bool _isLoadingInitial = true; // Untuk status loading awal

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // Memulai pengambilan data saat inisialisasi
  }

  // Metode untuk mengambil daftar booking
  Future<void> _fetchBookings() async {
    setState(() {
      _isLoadingInitial = true; // Set loading to true
    });
    try {
      final BaseResponse<List<riwayat_alias.Datum>>? response =
          await _apiService.getRiwayatBooking();
      if (response != null && response.data != null) {
        setState(() {
          _bookings = response.data!;
        });
      } else {
        // Handle case where response or data is null
        _showSnackBar(response?.message ?? 'Gagal memuat data booking.');
        setState(() {
          _bookings = []; // Clear bookings on error
        });
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan saat memuat booking: $e');
      setState(() {
        _bookings = []; // Clear bookings on error
      });
    } finally {
      setState(() {
        _isLoadingInitial = false; // Set loading to false after fetch completes
      });
    }
  }

  // Fungsi untuk menampilkan snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Fungsi untuk menampilkan dialog edit/hapus
  void _showBookingDetailEditDialog(riwayat_alias.Datum booking) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BookingDetailEditDialog(
          bookingDatum: booking,
          onBookingUpdated: () {
            // Callback ini dipanggil saat booking diupdate/hapus, kemudian refresh daftar
            _fetchBookings();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi & Manajemen Booking'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body:
          _isLoadingInitial
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
              ? const Center(child: Text('Tidak ada booking yang tersedia.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Menghapus InkWell dari Card, aksi sekarang ditangani oleh IconButton
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        // Menggunakan Row untuk menempatkan detail dan ikon
                        children: [
                          Expanded(
                            // Expanded agar detail booking memenuhi sisa ruang
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layanan: ${booking.service?.name ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Waktu: ${booking.bookingTime != null ? DateFormat('dd MMM yyyy HH:mm').format(booking.bookingTime!.toLocal()) : 'N/A'}',
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
                                            : booking.status == 'pending'
                                            ? Colors.orange.shade700
                                            : Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Harga: Rp ${booking.service?.price?.toStringAsFixed(2) ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // IconButton untuk manajemen booking
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.grey,
                            ),
                            onPressed:
                                () => _showBookingDetailEditDialog(booking),
                            tooltip: 'Manajemen Booking',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
