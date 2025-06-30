import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format angka harga
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
// Asumsi BookingDetailEditDialog sudah ada dan berisi logika yang diberikan sebelumnya// Sesuaikan path ini jika berbeda
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/booking_dialog.dart';

class EditBooking extends StatefulWidget {
  const EditBooking({super.key});

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  List<Datum> _riwayatBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  // Definisikan palet warna konsisten
  static const Color _primaryAccentBlue = Color(
    0xFF0A2342,
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
  static const Color _redDelete = Color(
    0xFFD32F2F,
  ); // A clear red for delete actions
  static const Color _disabledColor = Color(
    0xFFBDBDBD,
  ); // Warna untuk item yang dinonaktifkan

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
    // Show confirmation dialog before deleting
    final bool confirmDelete =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Confirm Deletion',
                style: TextStyle(
                  color: _darkCharcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to delete this booking? This action cannot be undone.',
                style: TextStyle(color: _mediumGreyText),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: _primaryAccentBlue),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _redDelete, // Red for delete button
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed

    if (!confirmDelete) {
      return; // If user cancels, do nothing
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final BaseResponse? response = await _apiService.deleteBooking(bookingId);

      if (!mounted) return;

      if (response != null && response.success == true) {
        _showSnackBar('Booking berhasil dihapus!', _primaryAccentBlue);
        _fetchRiwayatBooking(); // Refresh daftar booking setelah penghapusan berhasil
      } else {
        String errorMessage = response?.message ?? 'Gagal menghapus booking.';
        if (response != null && response.errors != null) {
          response.errors?.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n${value.join(', ')}';
            } else {
              errorMessage += '\n$value';
            }
          });
        }
        _showSnackBar(errorMessage, _redDelete);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error deleting booking: $e');
      _showSnackBar('Terjadi kesalahan saat menghapus booking: $e', _redDelete);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang abu-abu terang
      appBar: AppBar(
        title: const Text(
          'Manage Bookings', // Judul lebih formal
          style: TextStyle(
            color: Colors.white, // Teks putih
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: _darkCharcoal, // Warna AppBar hitam gelap
        elevation: 8, // Elevasi yang lebih dalam
        shadowColor: Colors.black87, // Bayangan lebih kuat
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ikon panah kembali putih
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _primaryAccentBlue,
                  ), // Loader biru
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: _redDelete, // Ikon error merah
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Oops! An error occurred:', // Pesan error lebih formal
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkCharcoal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _mediumGreyText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchRiwayatBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryAccentBlue, // Tombol biru
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
              : _riwayatBookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note_outlined, size: 80, color: _iconGrey),
                    SizedBox(height: 15),
                    Text(
                      'No booking history found.', // Pesan tidak ada booking
                      style: TextStyle(fontSize: 18, color: _mediumGreyText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchRiwayatBooking,
                color: _primaryAccentBlue, // Warna refresh indicator
                backgroundColor:
                    _lightGreyBackground, // Background refresh indicator
                child: ListView.builder(
                  padding: const EdgeInsets.all(16), // Padding lebih besar
                  itemCount: _riwayatBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _riwayatBookings[index];

                    // Logic untuk menentukan apakah booking dapat diedit
                    final bool isPending =
                        booking.status?.toLowerCase() == 'pending';
                    final bool isConfirmed =
                        booking.status?.toLowerCase() == 'confirmed';
                    final bool isCancelled =
                        booking.status?.toLowerCase() == 'cancelled';
                    final bool isCompleted =
                        booking.status?.toLowerCase() == 'completed';

                    // Booking dapat diedit jika:
                    // 1. Statusnya 'pending' ATAU 'confirmed'.
                    // 2. Belum 'cancelled' dan belum 'completed'.
                    // Catatan: Batas maksimal edit 3 kali TIDAK dapat diimplementasikan
                    // tanpa properti 'editCount' di model Datum dan dukungan API.
                    final bool canEdit =
                        (isPending || isConfirmed) &&
                        !isCancelled &&
                        !isCompleted;

                    String disabledReason = '';
                    if (isCancelled) {
                      disabledReason =
                          'Booking ini dibatalkan dan tidak dapat diedit.';
                    } else if (isCompleted) {
                      disabledReason =
                          'Booking ini selesai dan tidak dapat diedit.';
                    }
                    // Logika untuk "maximal edit hanya 3 kali" tidak dapat diimplementasikan di sini
                    // karena properti 'editCount' belum tersedia di model Datum Anda.

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                      ), // Margin vertikal lebih besar
                      elevation: 6, // Elevasi lebih dalam
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // Sudut lebih membulat
                      ),
                      // Ubah warna latar belakang jika tidak bisa diedit
                      color:
                          canEdit
                              ? Colors.white
                              : _disabledColor.withOpacity(0.7),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), // Efek inkwell sesuai border
                        onTap:
                            canEdit // Hanya aktifkan onTap jika canEdit true
                                ? () async {
                                  if (booking.id != null) {
                                    // Tampilkan dialog edit booking
                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return BookingDetailEditDialog(
                                          bookingDatum: booking,
                                          onBookingUpdated: () {
                                            _fetchRiwayatBooking(); // Refresh data setelah update
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    _showSnackBar(
                                      'Booking ID is not available.',
                                      Colors.orange.shade700,
                                    );
                                  }
                                }
                                : null, // Nonaktifkan onTap jika tidak bisa diedit
                        child: Padding(
                          padding: const EdgeInsets.all(
                            18.0,
                          ), // Padding lebih besar
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.service?.name ??
                                          'Unknown Service',
                                      style: TextStyle(
                                        fontSize: 19, // Ukuran font lebih besar
                                        fontWeight: FontWeight.bold,
                                        color:
                                            canEdit
                                                ? _primaryAccentBlue
                                                : _darkCharcoal.withOpacity(
                                                  0.6,
                                                ), // Warna teks berdasarkan editability
                                      ),
                                    ),
                                    const SizedBox(height: 6), // Spasi lebih
                                    Text(
                                      'Barber: ${booking.service?.employeeName ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            canEdit
                                                ? _mediumGreyText
                                                : _mediumGreyText.withOpacity(
                                                  0.6,
                                                ), // Warna teks berdasarkan editability
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Date: ${DateFormat('dd MM yyyy').format(booking.bookingTime!.toLocal())}', // Format tanggal yang lebih rapi
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            canEdit
                                                ? _iconGrey
                                                : _iconGrey.withOpacity(
                                                  0.6,
                                                ), // Warna teks berdasarkan editability
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Time: ${DateFormat('HH:mm').format(booking.bookingTime!.toLocal())}', // Format waktu 24 jam
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            canEdit
                                                ? _iconGrey
                                                : _iconGrey.withOpacity(
                                                  0.6,
                                                ), // Warna teks berdasarkan editability
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp',
                                        decimalDigits: 0,
                                      ).format(booking.service?.price ?? 0),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Tampilkan status booking
                                    Text(
                                      'Status: ${booking.status ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            booking.status?.toLowerCase() ==
                                                    'pending'
                                                ? Colors
                                                    .orange // Warna oranye untuk pending
                                                : booking.status
                                                        ?.toLowerCase() ==
                                                    'confirmed'
                                                ? Colors
                                                    .blue // Warna biru untuk confirmed
                                                : booking.status
                                                        ?.toLowerCase() ==
                                                    'completed'
                                                ? Colors
                                                    .green // Warna hijau untuk completed
                                                : _redDelete, // Warna merah untuk cancelled
                                      ),
                                    ),
                                    if (!canEdit) // Pesan jika tidak bisa diedit
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          disabledReason,
                                          style: TextStyle(
                                            color: _redDelete,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Tombol/Icon Delete
                              IconButton(
                                icon: Icon(
                                  Icons
                                      .delete_outline, // Ikon delete yang lebih modern
                                  color: _redDelete, // Warna merah untuk delete
                                  size: 28, // Ukuran ikon lebih besar
                                ),
                                tooltip: 'Delete Booking',
                                onPressed: () {
                                  if (booking.id != null) {
                                    _deleteBooking(booking.id!);
                                  } else {
                                    _showSnackBar(
                                      'Booking ID is not available for deletion.',
                                      Colors.orange.shade700,
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
