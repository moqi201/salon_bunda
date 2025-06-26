import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/screen/booking_management_screen.dart'; // Import yang benar untuk detail/management
import 'package:salon_bunda/salon/screen/riwayat_list_screen.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

// Hapus import ini jika DetailRiwayatBookingScreen sebenarnya adalah BookingManagementScreen
// import 'package:salon_bunda/salon/screen/riwayat_list_screen.dart'; // <-- HAPUS JIKA TIDAK DIGUNAKAN

class RiwayatBookingScreen extends StatefulWidget {
  const RiwayatBookingScreen({super.key});

  @override
  State<RiwayatBookingScreen> createState() => _RiwayatBookingScreenState();
}

class _RiwayatBookingScreenState extends State<RiwayatBookingScreen> {
  List<Datum> _riwayatBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Map untuk melacak booking yang sudah diedit. Key: bookingId, Value: isEdited
  final Map<int, bool> _editedBookings = {};

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRiwayatBooking();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchRiwayatBooking() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset error message
    });
    try {
      final BaseResponse<List<Datum>>? response =
          await _apiService.getRiwayatBooking();

      if (kDebugMode) {
        debugPrint(
          'API Service getRiwayatBooking Raw Response: Message: ${response?.message}, Success: ${response?.success}',
        );
      }

      if (!mounted) return;

      if (response != null &&
          response.success == true &&
          response.data != null) {
        setState(() {
          _riwayatBookings = response.data!;
          _errorMessage = null;
          // Inisialisasi _editedBookings untuk booking baru jika diperlukan
          for (var booking in _riwayatBookings) {
            if (!_editedBookings.containsKey(booking.id)) {
              _editedBookings[booking.id!] = false; // Default: belum diedit
            }
          }
        });
      } else {
        setState(() {
          _errorMessage =
              response?.message ??
              'Gagal memuat riwayat booking. Data kosong atau gagal.';
          _riwayatBookings = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching riwayat booking: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan atau server: $e';
        _riwayatBookings = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBooking(int bookingId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Panggil API untuk menghapus booking
      final BaseResponse? response = await _apiService.deleteBooking(bookingId);

      if (!mounted) return;

      if (response != null && response.success == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking berhasil dihapus!')));
        // Refresh daftar booking setelah penghapusan berhasil
        _fetchRiwayatBooking();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Gagal menghapus booking.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus booking: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        backgroundColor: Colors.pink.shade100,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Oops! Terjadi kesalahan:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchRiwayatBooking,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : _riwayatBookings.isEmpty
              ? const Center(
                child: Text(
                  'Tidak ada riwayat booking yang ditemukan.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchRiwayatBooking,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _riwayatBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _riwayatBookings[index];
                    // Periksa apakah booking ini sudah ditandai sebagai diedit
                    final bool isEdited = _editedBookings[booking.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (booking.id != null) {
                            final bool? bookingUpdated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailRiwayatBookingScreen(
                                      bookingId: booking.id!,
                                    ),
                              ),
                            );
                            if (mounted && bookingUpdated == true) {
                              setState(() {
                                _editedBookings[booking.id!] =
                                    true; // Tandai sebagai sudah diedit
                              });
                              _fetchRiwayatBooking(); // Refresh data
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ID Booking tidak tersedia.'),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.service?.name ??
                                          'Layanan Tidak Diketahui',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Karyawan: ${booking.service?.employeeName ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Harga: Rp ${booking.service?.price?.toStringAsFixed(0) ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol/Icon Setting atau Delete
                              IconButton(
                                icon: Icon(
                                  isEdited
                                      ? Icons.delete
                                      : Icons
                                          .settings, // Ubah ikon berdasarkan status isEdited
                                  color:
                                      isEdited
                                          ? Colors.red
                                          : Colors.grey, // Ubah warna ikon
                                  size: 24,
                                ),
                                tooltip:
                                    isEdited
                                        ? 'Hapus Booking'
                                        : 'Kelola Booking',
                                onPressed: () async {
                                  if (booking.id != null) {
                                    if (isEdited) {
                                      // Jika sudah diedit, panggil fungsi delete
                                      _deleteBooking(booking.id!);
                                    } else {
                                      // Jika belum diedit, panggil screen management
                                      final bool? bookingUpdated =
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      BookingManagementScreen(
                                                        bookingId: booking.id,
                                                      ),
                                            ),
                                          );
                                      if (mounted && bookingUpdated == true) {
                                        setState(() {
                                          _editedBookings[booking.id!] =
                                              true; // Tandai sebagai sudah diedit
                                        });
                                        _fetchRiwayatBooking(); // Refresh daftar jika ada perubahan
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'ID Booking tidak tersedia untuk dikelola.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
