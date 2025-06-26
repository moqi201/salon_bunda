// lib/salon/screen/detail_riwayat_booking_screen.dart

import 'package:flutter/foundation.dart'; // Import ini untuk kDebugMode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import ini untuk DateFormat
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class DetailRiwayatBookingScreen extends StatefulWidget {
  final int bookingId;

  const DetailRiwayatBookingScreen({super.key, required this.bookingId});

  @override
  State<DetailRiwayatBookingScreen> createState() =>
      _DetailRiwayatBookingScreenState();
}

class _DetailRiwayatBookingScreenState
    extends State<DetailRiwayatBookingScreen> {
  final ApiService _apiService = ApiService();
  Datum? _bookingDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final BaseResponse<List<Datum>>? response =
          await _apiService.getRiwayatBooking();

      if (kDebugMode) {
        debugPrint(
          '--- DEBUG: API Response for DetailRiwayatBookingScreen (ID: ${widget.bookingId}) ---',
        );
        debugPrint(
          'Full API Response Body: ${response?.toJson((dataList) => dataList?.map((datum) => datum.toJson()).toList())}',
        );
      }

      if (!mounted) return;

      if (response != null &&
          response.success == true &&
          response.data != null) {
        try {
          final booking = response.data!.firstWhereOrNull(
            (b) => b.id == widget.bookingId,
          );

          if (booking != null) {
            setState(() {
              _bookingDetail = booking;
            });
            if (kDebugMode) {
              debugPrint(
                'Booking with ID ${widget.bookingId} found. Details: $_bookingDetail',
              );
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                'Booking with ID ${widget.bookingId} not found in response data.',
              );
            }
            setState(() {
              _bookingDetail = null;
              _errorMessage =
                  'Detail booking dengan ID ${widget.bookingId} tidak ditemukan.';
            });
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error finding booking in list: $e');
          }
          setState(() {
            _bookingDetail = null;
            _errorMessage = 'Gagal memproses data booking: $e';
          });
        }
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Gagal memuat detail booking.';
          _bookingDetail = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching booking detail: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan atau server: $e';
        _bookingDetail = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper untuk mendapatkan ikon status dinamis
  Widget _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 90);
      case 'pending':
        return const Icon(
          Icons.pending_actions,
          color: Colors.orange,
          size: 90,
        );
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red, size: 90);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red, size: 90);
      default:
        return const Icon(Icons.info_outline, color: Colors.grey, size: 90);
    }
  }

  // Helper Widget untuk membuat baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(' : ', style: TextStyle(fontSize: 15)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Booking'),
        backgroundColor: Colors.purple.shade100,
        centerTitle: true,
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
                        onPressed: _fetchBookingDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : _bookingDetail == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Detail booking tidak ditemukan.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _getStatusIcon(_bookingDetail?.status),
                    const SizedBox(height: 20),
                    Text(
                      _bookingDetail?.status == 'confirmed' ||
                              _bookingDetail?.status == 'completed'
                          ? 'Booking Berhasil Dikonfirmasi!'
                          : _bookingDetail?.status == 'pending'
                          ? 'Booking Menunggu Konfirmasi'
                          : 'Booking Dibatalkan/Ditolak',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            _bookingDetail?.status == 'confirmed' ||
                                    _bookingDetail?.status == 'completed'
                                ? Colors.green
                                : _bookingDetail?.status == 'pending'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Layanan',
                            _bookingDetail?.service?.name ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'ID Booking',
                            _bookingDetail?.id?.toString() ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Waktu Booking',
                            _bookingDetail?.bookingTime != null
                                ? DateFormat(
                                  'dd MMM yyyy HH:mm',
                                ).format(_bookingDetail!.bookingTime!.toLocal())
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Status',
                            _bookingDetail?.status ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Harga',
                            'Rp ${(_bookingDetail?.service?.price ?? 0.0).toStringAsFixed(0)}',
                          ),
                          _buildDetailRow(
                            'Karyawan',
                            _bookingDetail?.service!.employeeName ?? 'N/A',
                          ),
                          if (_bookingDetail!.service!.description != null &&
                              _bookingDetail!.service!.description!.isNotEmpty)
                            _buildDetailRow(
                              'Deskripsi',
                              _bookingDetail!.service!.description!,
                            ),
                          // Bagian untuk foto layanan telah dihapus
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Kembali ke Riwayat Booking',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

// Extension untuk firstWhereOrNull, pastikan ini ada atau tambahkan jika belum
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
