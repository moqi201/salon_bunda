// lib/salon/widget/booking_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart'
    as riwayat_alias;
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:flutter/foundation.dart'; // Import ini untuk debugPrint

class BookingDetailEditDialog extends StatefulWidget {
  final riwayat_alias.Datum bookingDatum;
  final VoidCallback
  onBookingUpdated; // Callback untuk memberitahu parent sudah diupdate

  const BookingDetailEditDialog({
    super.key,
    required this.bookingDatum,
    required this.onBookingUpdated,
  });

  @override
  State<BookingDetailEditDialog> createState() =>
      _BookingDetailEditDialogState();
}

class _BookingDetailEditDialogState extends State<BookingDetailEditDialog> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Helper untuk menampilkan SnackBar
  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
    }
  }

  // Metode untuk memperbarui status booking (Konfirmasi/Batalkan)
  Future<void> _updateBookingStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.updateBooking(
        widget.bookingDatum.id!,
        status: newStatus,
      );

      // Pastikan widget masih mounted sebelum menggunakan context
      if (!mounted) return;

      if (response != null) {
        // PERBAIKAN: Cek `response.success` secara eksplisit
        if (response.success == true) {
          // <--- PERBAIKAN DI SINI
          _showSnackBar(
            'Booking berhasil di${newStatus.toLowerCase()}!',
            backgroundColor: Colors.green,
          );
          // Panggil callback sebelum menutup dialog agar halaman parent punya waktu untuk refresh
          widget.onBookingUpdated();
          Navigator.of(context).pop(); // Tutup dialog
        } else {
          // API merespons tapi 'success' adalah false
          final String errorMessage =
              response.message ?? 'Terjadi kesalahan saat memperbarui.';
          _showSnackBar(
            'Gagal memperbarui booking: $errorMessage',
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Response dari ApiService adalah null (biasanya masalah koneksi/parsing fatal di ApiService)
        _showSnackBar(
          'Terjadi kesalahan koneksi atau server tidak merespons.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // Menggunakan debugPrint untuk debugging yang lebih baik di Flutter
      debugPrint('Error updating booking: $e');
      _showSnackBar(
        'Terjadi kesalahan tak terduga: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Metode untuk menghapus booking
  Future<void> _deleteBooking() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.deleteBooking(widget.bookingDatum.id!);

      // Pastikan widget masih mounted sebelum menggunakan context
      if (!mounted) return;

      if (response != null) {
        // PERBAIKAN: Cek `response.success` secara eksplisit
        if (response.success == true) {
          // <--- PERBAIKAN DI SINI
          _showSnackBar(
            'Booking berhasil dihapus!',
            backgroundColor: Colors.green,
          );
          widget.onBookingUpdated(); // Panggil callback sukses
          Navigator.of(context).pop(); // Tutup dialog
        } else {
          // API merespons tapi 'success' adalah false
          final String errorMessage =
              response.message ?? 'Terjadi kesalahan saat menghapus.';
          _showSnackBar(
            'Gagal menghapus booking: $errorMessage',
            backgroundColor: Colors.red,
          );
        }
      } else {
        // Response dari ApiService adalah null
        _showSnackBar(
          'Terjadi kesalahan koneksi atau server tidak merespons.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      // Menggunakan debugPrint untuk debugging yang lebih baik di Flutter
      debugPrint('Error deleting booking: $e');
      _showSnackBar(
        'Terjadi kesalahan tak terduga: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kelola Booking'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Layanan: ${widget.bookingDatum.service?.name ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu: ${widget.bookingDatum.bookingTime != null ? DateFormat('dd MMM, HH:mm').format(widget.bookingDatum.bookingTime!.toLocal()) : 'N/A'}',
            ),
            const SizedBox(height: 8),
            Text(
              'Status Saat Ini: ${widget.bookingDatum.status ?? 'N/A'}',
              style: TextStyle(
                color:
                    widget.bookingDatum.status == 'confirmed'
                        ? Colors.green.shade700
                        : widget.bookingDatum.status == 'pending'
                        ? const Color.fromARGB(255, 245, 0, 0)
                        : widget.bookingDatum.status ==
                            'cancelled' // Menambahkan warna untuk status 'cancelled'
                        ? Colors
                            .red
                            .shade700 // Warna merah untuk cancelled
                        : Colors
                            .grey
                            .shade700, // Warna default jika status tidak dikenal
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        // Hanya tampilkan tombol Konfirmasi jika statusnya 'pending'
        if (widget.bookingDatum.status == 'pending')
          TextButton(
            onPressed:
                _isLoading ? null : () => _updateBookingStatus('confirmed'),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(color: Colors.green),
            ),
          ),
        // Tampilkan tombol Batalkan hanya jika status bukan 'cancelled' atau 'completed'
        if (widget.bookingDatum.status != 'cancelled' &&
            widget.bookingDatum.status != 'completed')
          TextButton(
            onPressed:
                _isLoading ? null : () => _updateBookingStatus('cancelled'),
            child: const Text(
              'Batalkan',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        // Tombol hapus selalu ada
        TextButton(
          onPressed: _isLoading ? null : _deleteBooking,
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
