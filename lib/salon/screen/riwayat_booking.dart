// lib/salon/screen/riwayat_booking_screen.dart

import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import untuk format tanggal dan mata uang
import 'package:lottie/lottie.dart'; // Import Lottie
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/screen/riwayat_list_screen.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class RiwayatBookingScreen extends StatefulWidget {
  const RiwayatBookingScreen({super.key});

  @override
  State<RiwayatBookingScreen> createState() => _RiwayatBookingScreenState();
}

class _RiwayatBookingScreenState extends State<RiwayatBookingScreen> {
  List<Datum> _riwayatBookings = [];
  List<Datum> _filteredRiwayatBookings = []; // Added for search filtering
  bool _isLoading = false;
  String? _errorMessage;

  // Map untuk melacak booking yang sudah diedit. Key: bookingId, Value: isEdited
  final Map<int, bool> _editedBookings = {};

  final ApiService _apiService = ApiService();

  // Search related variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRiwayatBooking();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Helper function to get image path based on service name or the photoUrl from Datum
  String _getServiceImagePath(Datum booking) {
    // Fallback to local assets if photoUrl is not a local asset or is null/empty
    final serviceName = booking.service?.name?.toLowerCase() ?? '';
    if (serviceName.contains('rambut') || serviceName.contains('potong')) {
      return 'assets/images/rambut.jpg';
    } else if (serviceName.contains('jenggot') ||
        serviceName.contains('kumis')) {
      return 'assets/images/jenggot.jpg';
    } else if (serviceName.contains('creambath') ||
        serviceName.contains('masker')) {
      return 'assets/images/creambath.jpg';
    }
    return 'assets/images/Corte de pelo.png'; // Default if no specific match
  }

  // Helper function to determine if the image is a network image
  bool _isNetworkImage(Datum booking) {
    final photoUrl = booking.photoUrl;
    return photoUrl != null &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));
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
          _filteredRiwayatBookings =
              _riwayatBookings; // Initialize filtered list
          _errorMessage = null;
          // Inisialisasi _editedBookings untuk booking baru jika diperlukan
          for (var booking in _riwayatBookings) {
            if (booking.id != null) {
              // Pastikan ID tidak null
              if (!_editedBookings.containsKey(booking.id)) {
                _editedBookings[booking.id!] = false; // Default: belum diedit
              }
            }
          }
        });
      } else {
        setState(() {
          _errorMessage =
              response?.message ??
              'Failed to load booking history. Data is empty or failed.';
          _riwayatBookings = [];
          _filteredRiwayatBookings = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching riwayat booking: $e');
      setState(() {
        _errorMessage = 'Network or server error occurred: $e';
        _riwayatBookings = [];
        _filteredRiwayatBookings = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Search logic
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRiwayatBookings =
          _riwayatBookings.where((booking) {
            final serviceName = booking.service?.name?.toLowerCase() ?? '';
            final employeeName =
                booking.service?.employeeName?.toLowerCase() ?? '';
            final bookingDate =
                booking.bookingTime != null
                    ? DateFormat(
                      'EEE, dd MMM yyyy',
                    ).format(booking.bookingTime!).toLowerCase()
                    : '';
            final bookingTime =
                booking.bookingTime != null
                    ? DateFormat(
                      'HH:mm',
                    ).format(booking.bookingTime!).toLowerCase()
                    : '';
            return serviceName.contains(query) ||
                employeeName.contains(query) ||
                bookingDate.contains(query) ||
                bookingTime.contains(query);
          }).toList();
    });
  }

  void _toggleSearching() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredRiwayatBookings =
            _riwayatBookings; // Reset filter when search is closed
      }
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking successfully deleted!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black54, // Dark grey for success
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.all(20),
          ),
        );
        // Refresh daftar booking setelah penghapusan berhasil
        _fetchRiwayatBooking();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response?.message ?? 'Failed to delete booking.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700, // Red for error
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while deleting booking: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700, // Red for error
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: const EdgeInsets.all(20),
        ),
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
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search booking history...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                  ),
                )
                : const Text(
                  'Booking History',
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
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: _toggleSearching,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Lottie.asset(
                  'assets/lottie/Animation - 1751259356339.json', // Path ke animasi Lottie Anda
                  width: 150, // Sesuaikan ukuran sesuai kebutuhan
                  height: 150, // Sesuaikan ukuran sesuai kebutuhan
                  fit: BoxFit.contain,
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700, // Red for error
                        size: 70,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Oops! An error occurred:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
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
                        onPressed: _fetchRiwayatBooking,
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
                          backgroundColor: Colors.black, // Black button
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
              : _filteredRiwayatBookings.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_note, // Icon for no bookings
                        color: Colors.grey, // Grey icon
                        size: 100,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No booking history yet.',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ), // Darker grey for primary text
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Start by scheduling your first distinguished service!',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey, // Grey for secondary text
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchRiwayatBooking,
                color: Colors.black, // Black refresh indicator
                backgroundColor: Colors.white, // White background for refresh
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredRiwayatBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _filteredRiwayatBookings[index];
                    // Periksa apakah booking ini sudah ditandai sebagai diedit
                    final bool isEdited = _editedBookings[booking.id] ?? false;

                    // Determine the image provider based on whether it's a network URL or a local asset
                    ImageProvider imageProvider;
                    if (_isNetworkImage(booking)) {
                      imageProvider = NetworkImage(booking.photoUrl!);
                    } else {
                      imageProvider = AssetImage(_getServiceImagePath(booking));
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 5, // Subtle elevation
                      color: Colors.white, // White card background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color:
                              isEdited
                                  ? Colors
                                      .black // Black border if edited
                                  : Colors
                                      .grey
                                      .shade300, // Light grey subtle border
                          width: 1, // Thinner border for minimalist look
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (booking.id != null) {
                            // Navigasi ke DetailRiwayatBookingScreen
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
                                content: Text(
                                  'Booking ID not available.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Align items vertically center
                            children: [
                              // Service Image/Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors.black, // Black border for image
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                        0.3,
                                      ), // Subtle grey shadow
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  // Use ClipOval to ensure the image is circular
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to an icon if image fails to load
                                      return Container(
                                        color:
                                            Colors
                                                .grey
                                                .shade200, // Very light grey background for fallback icon
                                        child: const Icon(
                                          Icons.cut_rounded,
                                          color:
                                              Colors
                                                  .black, // Black fallback icon
                                          size: 35,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.service?.name ??
                                          'Unknown Service',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w800, // Extra bold
                                        color:
                                            Colors.black, // Black service name
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Karyawan: ${booking.service?.employeeName ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors
                                                .grey
                                                .shade700, // Darker grey for employee
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Menggunakan bookingTime dari model
                                    if (booking.bookingTime != null)
                                      Text(
                                        'Date: ${DateFormat('EEE, dd MMM yyyy').format(booking.bookingTime!)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade600, // Medium grey for date
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    // Menggunakan bookingTime dari model
                                    if (booking.bookingTime != null)
                                      Text(
                                        'Time: ${DateFormat('HH:mm').format(booking.bookingTime!)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade600, // Medium grey for time
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      // 'Price: Rp ${NumberFormat('#,##0').format(booking.service?.price ?? 0)}',
                                      // style: const TextStyle(
                                      //   fontSize: 18,
                                      //   fontWeight: FontWeight.bold,
                                      //   color: Colors.black, // Black price
                                      //   letterSpacing: 0.3,
                                      // ),
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
                                  ],
                                ),
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
