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
                  'Detail booking with ID ${widget.bookingId} not found.';
            });
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error finding booking in list: $e');
          }
          setState(() {
            _bookingDetail = null;
            _errorMessage = 'Failed to process booking data: $e';
          });
        }
      } else {
        setState(() {
          _errorMessage =
              response?.message ?? 'Failed to load booking details.';
          _bookingDetail = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching booking detail: $e');
      setState(() {
        _errorMessage = 'Network or server error occurred: $e';
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
    Color iconColor;
    IconData iconData;
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        iconColor = Colors.green; // Black for confirmed/completed
        iconData = Icons.check_circle_outline_rounded;
        break;
      case 'pending':
        iconColor = Colors.grey.shade700; // Dark grey for pending
        iconData = Icons.hourglass_empty_rounded;
        break;
      case 'cancelled':
      case 'rejected':
        iconColor = Colors.black; // Black for cancelled/rejected
        iconData = Icons.cancel_outlined;
        break;
      default:
        iconColor = Colors.grey; // Medium grey for unknown
        iconData = Icons.info_outline;
        break;
    }
    return Icon(iconData, color: iconColor, size: 100); // Larger icon
  }

  // Helper Widget untuk membuat baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6.0,
      ), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Increased width for label
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600, // Semi-bold
                fontSize: 16, // Slightly larger font
                color: Colors.black, // Black for label text
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ), // Black for colon separator
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54, // Dark grey for value text
                height: 1.4, // Line height for better readability
              ),
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
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.black, // Black title
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // White AppBar
        elevation: 1, // Subtle elevation
        shadowColor: Colors.grey.withOpacity(0.3), // Subtle grey shadow
        iconTheme: const IconThemeData(color: Colors.black), // Black back icon
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black,
                  ), // Black loading indicator
                  strokeWidth: 4,
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.black, // Black for error icon
                        size: 70,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Oops! An error occurred:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Black for error title
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.grey, // Grey for error message details
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _fetchBookingDetail,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ), // White icon
                        label: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ), // White text
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black, // Black button for error screen
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _bookingDetail == null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off_rounded, // Icon for not found
                        color: Colors.grey, // Grey
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Booking details not found.',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ), // Darker grey
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          ); // Pop with true to indicate a potential change/refresh needed
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Back to Booking History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black, // Black button for not found
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
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
                          ? 'Booking Confirmed Successfully!'
                          : _bookingDetail?.status == 'pending'
                          ? 'Booking Awaiting Confirmation'
                          : 'Booking Cancelled/Rejected',
                      style: TextStyle(
                        fontSize: 26, // Larger font for status text
                        fontWeight: FontWeight.w900, // Black font weight
                        color:
                            _bookingDetail?.status == 'confirmed' ||
                                    _bookingDetail?.status == 'completed'
                                ? Colors
                                    .black // Black for confirmed
                                : _bookingDetail?.status == 'pending'
                                ? Colors
                                    .grey
                                    .shade700 // Dark grey for pending
                                : const Color.fromARGB(
                                  255,
                                  255,
                                  0,
                                  0,
                                ), // Black for cancelled
                        letterSpacing: 0.8,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(25), // More padding
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for details box
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // More rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(
                              0.3,
                            ), // Lighter shadow
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Service',
                            _bookingDetail?.service?.name ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Booking ID',
                            _bookingDetail?.id?.toString() ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Booking Time',
                            _bookingDetail?.bookingTime != null
                                ? DateFormat(
                                  'EEE, dd MMM yyyy, HH:mm',
                                ).format(_bookingDetail!.bookingTime!.toLocal())
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Status',
                            _bookingDetail?.status?.toUpperCase() ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Price',
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp',
                              decimalDigits: 0,
                            ).format(_bookingDetail?.service?.price),
                            // 'Rp ${NumberFormat('#,##0').format(_bookingDetail?.service?.price ?? 0.0)}',
                          ),
                          _buildDetailRow(
                            'Karyawan',
                            _bookingDetail?.service!.employeeName ?? 'N/A',
                          ),
                          if (_bookingDetail!.service!.description != null &&
                              _bookingDetail!.service!.description!.isNotEmpty)
                            _buildDetailRow(
                              'Description',
                              _bookingDetail!.service!.description!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
