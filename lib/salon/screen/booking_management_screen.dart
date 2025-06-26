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
          _showSnackBar('Terjadi kesalahan saat mencari booking: $e');
          if (!mounted) return;
          setState(() {
            _currentBooking = null;
          });
        }
      } else {
        _showSnackBar(
          response?.message ??
              'Gagal memuat detail booking. Data kosong atau gagal.',
        );
        if (!mounted) return;
        setState(() {
          _currentBooking = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching single booking: $e');
      _showSnackBar('Terjadi kesalahan saat memuat detail booking: $e');
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

  void _showSnackBar(String message) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'completed':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
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
              _hasChanges = true; // <--- PENTING: Tandai ada perubahan
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Kembalikan _hasChanges saat PopScope dipicu (tombol kembali fisik/gesture)
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          // Hanya pop dengan nilai jika ada perubahan
          if (mounted && _hasChanges) {
            Navigator.pop(context, true);
          } else if (mounted) {
            // Jika tidak ada perubahan, pop tanpa nilai (atau false)
            Navigator.pop(context, false);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manajemen Booking ID: ${widget.bookingId ?? "N/A"}'),
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Kembali dengan nilai _hasChanges
              Navigator.pop(
                context,
                _hasChanges,
              ); // <--- PENTING: Gunakan _hasChanges
            },
          ),
        ),
        body:
            _isLoadingInitial
                ? const Center(child: CircularProgressIndicator())
                : _currentBooking == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.bookingId == null
                            ? 'Tidak ada ID Booking yang diberikan.'
                            : 'Detail Booking dengan ID ${widget.bookingId} tidak ditemukan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            false,
                          ); // <--- Kembali dengan false jika tidak ada booking
                        },
                        child: const Text('Kembali ke Riwayat Booking'),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Layanan: ${_currentBooking!.service?.name ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'ID Booking',
                          '${_currentBooking!.id ?? 'N/A'}',
                        ),
                        _buildDetailRow(
                          'Waktu Booking',
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
                          'Harga',
                          'Rp ${_currentBooking!.service?.price?.toStringAsFixed(0) ?? 'N/A'}',
                        ),
                        _buildDetailRow(
                          'Karyawan',
                          _currentBooking!.service?.employeeName ?? 'N/A',
                        ),
                        _buildDetailRow(
                          'Deskripsi Layanan',
                          _currentBooking!.service?.description ?? 'N/A',
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_currentBooking != null) {
                                _showBookingDetailEditDialog(_currentBooking!);
                              } else {
                                _showSnackBar(
                                  'Detail booking tidak tersedia untuk diedit.',
                                );
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit atau Hapus Booking',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 15, color: color)),
          ),
        ],
      ),
    );
  }
}
