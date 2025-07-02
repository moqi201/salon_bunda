import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/booking_dialog.dart'; // Pastikan widget ini ada dan menggunakan Datum

class BookingManagementScreen extends StatefulWidget {
  final int? bookingId;

  const BookingManagementScreen({super.key, this.bookingId});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final ApiService _apiService = ApiService();
  Datum? _currentBooking;
  bool _isLoadingInitial = true;

  // Tambahkan variabel untuk melacak apakah ada perubahan yang terjadi
  bool _hasChanges = false;

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
  static const Color _redError = Color(
    0xFFD32F2F,
  ); // A clear red for error/cancel
  static const Color _greenSuccess = Color(
    0xFF2E7D32,
  ); // Darker green for confirmed
  static const Color _orangePending = Color(
    0xFFEF6C00,
  ); // Darker orange for pending
  // static const Color _blueCompleted = Color(
  //   0xFF1976D2,
  // ); // A shade of blue for completed

  @override
  void initState() {
    super.initState();
    _initializeBookingData();
  }

  void _initializeBookingData() {
    if (widget.bookingId != null) {
      _fetchSingleBooking(widget.bookingId!);
    } else {
      setState(() {
        _isLoadingInitial = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // NOTE: Fungsi ini sekarang mengambil semua riwayat dan mencari ID.
  // Idealnya, API Anda harus memiliki endpoint untuk mengambil booking berdasarkan ID.
  // Contoh: await _apiService.getBookingById(id);
  Future<void> _fetchSingleBooking(int id) async {
    if (!mounted) return;

    setState(() {
      _isLoadingInitial = true;
    });

    try {
      final BaseResponse<List<Datum>>? response =
          await _apiService.getRiwayatBooking();

      if (!mounted) return;

      if (response != null &&
          response.success == true &&
          response.data != null) {
        try {
          final booking = response.data!.firstWhere(
            (b) => b.id == id,
            orElse: () {
              throw StateError('Booking not found');
            },
          );

          if (!mounted) return;
          setState(() {
            _currentBooking = booking;
          });
        } catch (e) {
          debugPrint('Error finding booking with ID $id in list: $e');
          _showSnackBar(
            'Terjadi kesalahan saat mencari booking: $e',
            _redError,
          );
          if (!mounted) return;
          setState(() {
            _currentBooking = null;
          });
        }
      } else {
        _showSnackBar(
          response?.message ??
              'Gagal memuat detail booking. Data kosong atau gagal.',
          _redError,
        );
        if (!mounted) return;
        setState(() {
          _currentBooking = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching single booking: $e');
      _showSnackBar(
        'Terjadi kesalahan saat memuat detail booking: $e',
        _redError,
      );
      setState(() {
        _currentBooking = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitial = false;
        });
      }
    }
  }

  void _showSnackBar(String message, [Color? color]) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: color ?? _darkCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          elevation: 8,
        ),
      );
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return _greenSuccess;
      case 'pending':
        return _orangePending;
      case 'cancelled':
        return _redError;
      // case 'completed':
      //   return _blueCompleted;
      default:
        return _iconGrey;
    }
  }

  void _showBookingDetailEditDialog(Datum booking) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BookingDetailEditDialog(
          bookingDatum: booking,
          onBookingUpdated: () {
            // Tutup dialog
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }

            // Refresh data booking di layar ini
            if (mounted && widget.bookingId != null) {
              _fetchSingleBooking(widget.bookingId!);
              // Set flag bahwa ada perubahan
              _hasChanges = true; // <--- Tandai ada perubahan
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Biarkan PopScope mengizinkan pop default
      onPopInvoked: (didPop) {
        // Jika pop dipicu oleh gesture back atau tombol sistem,
        // dan belum ada Navigator.pop yang mengembalikan nilai _hasChanges,
        // kita mengembalikannya di sini.
        if (didPop) {
          if (mounted && Navigator.canPop(context)) {
            // Hanya pop jika memang ada rute yang bisa di-pop
            // dan pastikan tidak pop ganda.
            // Gunakan addPostFrameCallback untuk menghindari isu _debugLocked
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Periksa mounted lagi setelah callback
                Navigator.pop(context, _hasChanges);
              }
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: _lightGreyBackground,
        appBar: AppBar(
          title: Text(
            'Manage Booking ID: ${widget.bookingId ?? "N/A"}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: _darkCharcoal, // Darker AppBar color
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Kembali dengan nilai _hasChanges.
              // Wrap dengan addPostFrameCallback untuk menghindari _debugLocked.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pop(context, _hasChanges);
                }
              });
            },
          ),
        ),
        body:
            _isLoadingInitial
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _primaryAccentBlue,
                    ),
                  ),
                )
                : _currentBooking == null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .sentiment_dissatisfied, // Icon yang lebih sesuai
                          color: _iconGrey,
                          size: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.bookingId == null
                              ? 'No Booking ID provided.'
                              : 'Booking details for ID ${widget.bookingId} not found.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: _mediumGreyText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Kembali dengan nilai false karena tidak ada booking
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                Navigator.pop(context, false);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryAccentBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Back to Booking History'),
                        ),
                      ],
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(20.0), // Padding lebih besar
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service: ${_currentBooking!.service?.name ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 24, // Ukuran font lebih besar
                            fontWeight: FontWeight.bold,
                            color: _darkCharcoal, // Warna utama untuk judul
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Booking ID',
                          '${_currentBooking!.id ?? 'N/A'}',
                        ),
                        _buildDetailRow(
                          'Booking Time',
                          _currentBooking!.bookingTime != null
                              ? DateFormat(
                                'dd MMM yyyy, HH:mm',
                              ).format(_currentBooking!.bookingTime!.toLocal())
                              : 'N/A',
                        ),
                        _buildDetailRow(
                          'Status',
                          _currentBooking!.status ?? 'N/A',
                          color: _getStatusColor(_currentBooking!.status),
                        ),
                        _buildDetailRow(
                          'Price',
                          'Rp ${NumberFormat('#,##0').format(_currentBooking!.service?.price ?? 0)}',
                        ),
                        _buildDetailRow(
                          'Barber',
                          _currentBooking!.service?.employeeName ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Service Description',
                          _currentBooking!.service?.description ?? 'N/A',
                        ),
                        const SizedBox(height: 30), // Spasi lebih besar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_currentBooking != null) {
                                _showBookingDetailEditDialog(_currentBooking!);
                              } else {
                                _showSnackBar(
                                  'Booking details not available for editing.',
                                  Colors.orange.shade700,
                                );
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit Booking Details', // Teks tombol diubah
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _primaryAccentBlue, // Warna tombol utama
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ), // Padding lebih besar
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Sudut lebih membulat
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Padding vertikal lebih besar
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Lebar label sedikit lebih besar
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _darkCharcoal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? _mediumGreyText),
            ),
          ),
        ],
      ),
    );
  }
}
