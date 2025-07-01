import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/booking_model.dart';
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Define a consistent color palette for a gentleman's barber
  static const Color _primaryAccentBlue = Color(
    0xFF0A2342,
  ); // Deep, sophisticated blue
  static const Color _darkCharcoal = Color(
    0xFF212121,
  ); // Deep charcoal (unchanged, good for professionalism)
  static const Color _lightGreyBackground = Color(
    0xFFF5F5F5,
  ); // Lighter grey for background (unchanged)
  static const Color _mediumGreyText = Color(
    0xFF424242,
  ); // Darker grey for details (unchanged)
  static const Color _lightDivider = Color(
    0xFFE0E0E0,
  ); // Lighter grey for dividers (unchanged)
  static const Color _iconGrey = Color(
    0xFF757575,
  ); // Slightly darker grey for icons (unchanged)
  static const Color _goldAccent = Color(
    0xFFD4AF37,
  ); // Optional: A subtle gold for highlights if desired

  @override
  void initState() {
    super.initState();
    // Initialize selected date and time to sensible defaults if needed
    // For example, if you want today's date and current time pre-selected
    // _selectedDate = DateTime.now();
    // _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryAccentBlue, // Deep blue for primary
              onPrimary: Colors.white,
              surface: _darkCharcoal, // Darker, almost black surface
              onSurface: Colors.white,
              // Background for selected date bubble in month view
              secondary:
                  _lightGreyBackground, // Use primary accent for secondary too
              onSecondary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Blue text buttons
              ),
            ),
            // Ensure other text styles within the date picker match
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            // Perbaikan di sini: Ganti DialogTheme menjadi DialogThemeData
            dialogTheme: const DialogThemeData(backgroundColor: _darkCharcoal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primaryAccentBlue, // Deep blue for primary
              onPrimary: Colors.white,
              surface: _darkCharcoal, // Darker, almost black surface
              onSurface: Colors.white,
              // For the selected time circle in time picker
              secondary:
                  _primaryAccentBlue, // Use primary accent for secondary too
              onSecondary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Blue text buttons
              ),
            ),
            // Ensure other text styles within the time picker match
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            // Perbaikan di sini: Ganti DialogTheme menjadi DialogThemeData
            dialogTheme: const DialogThemeData(backgroundColor: _darkCharcoal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (widget.service.id == null) {
      _showSnackBar(
        'Service ID is invalid. Cannot create booking.',
        Colors.red.shade700,
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showSnackBar(
        'Please select both date and time for your booking.',
        Colors.orange.shade700,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final DateTime bookingDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    BaseResponse<Booking>? result = await _apiService.createBooking(
      widget.service.id!,
      bookingDateTime,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result.success == true) {
      _showSnackBar(
        result.message ?? 'Booking successfully created!',
        _primaryAccentBlue, // Blue for success
      );
      Navigator.pop(context, true);
    } else {
      String errorMessage =
          result?.message ?? 'Booking failed. Please try again.';
      if (result != null && result.errors != null) {
        result.errors?.forEach((key, value) {
          if (value is List) {
            errorMessage += '\n${value.join(', ')}';
          } else {
            errorMessage += '\n$value';
          }
        });
      }
      _showSnackBar(errorMessage, Colors.red.shade700);
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
      backgroundColor:
          _lightGreyBackground, // Lighter grey for professional background
      appBar: AppBar(
        title: const Text(
          'Schedule Your Grooming', // More sophisticated title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700, // Slightly bolder for professionalism
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: _darkCharcoal, // Deep charcoal for a premium feel
        elevation: 8, // Deeper shadow for AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 20.0,
        ), // Generous padding
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Photo Card
              Card(
                elevation: 10, // Even deeper shadow for premium look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // More rounded corners
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      widget.service.servicePhotoUrl != null &&
                              widget.service.servicePhotoUrl!.isNotEmpty
                          ? Image.network(
                            widget.service.servicePhotoUrl!,
                            height: 240, // Taller image for better presentation
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 240,
                                  color: const Color(
                                    0xFFE0E0E0,
                                  ), // Lighter grey for placeholder
                                  child: Icon(
                                    Icons.content_cut,
                                    size: 90, // Larger icon
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                          )
                          : Container(
                            height: 240,
                            color: const Color(0xFFE0E0E0),
                            child: Icon(
                              Icons.content_cut,
                              size: 90,
                              color: Colors.grey.shade700,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 30),

              // Service Details Section
              Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 26, // Larger heading
                  fontWeight: FontWeight.w700, // Stronger bold
                  color: _darkCharcoal, // Dark charcoal
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                icon: Icons.cut_outlined, // Outlined icon for modern touch
                label: 'Service:',
                value: widget.service.name ?? 'Not Specified',
                valueColor: _mediumGreyText, // Darker grey for details
              ),
              _buildDetailRow(
                icon: Icons.article_outlined, // Outlined icon
                label: 'Description:',
                value: widget.service.description ?? 'No description provided.',
                valueColor: Colors.grey.shade700,
              ),
              _buildDetailRow(
                icon: Icons.payments_outlined, // Outlined icon
                label: 'Price:',
                value: NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                ).format(widget.service.price ?? 0),
                valueColor: Colors.black87, // Deep blue for price
                isPrice: true,
              ),
              const Divider(
                height: 50,
                color: _lightDivider,
                thickness: 1.5,
              ), // Thicker, lighter divider
              // Employee Information (only if available)
              if (widget.service.employeeName != null &&
                  widget.service.employeeName!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Professional Barber', // More "pro" wording
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _darkCharcoal,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.2,
                                ), // Darker shadow
                                spreadRadius: 3,
                                blurRadius: 8,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                widget.service.employeePhotoUrl != null &&
                                        widget
                                            .service
                                            .employeePhotoUrl!
                                            .isNotEmpty
                                    ? Image.network(
                                      widget.service.employeePhotoUrl!,
                                      height: 80, // Larger employee image
                                      width: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => CircleAvatar(
                                            radius: 40,
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            child: Icon(
                                              Icons
                                                  .person_outline, // Outlined person icon
                                              size: 50,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                    )
                                    : CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey.shade300,
                                      child: Icon(
                                        Icons.person_outline,
                                        size: 50,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Text(
                          widget.service.employeeName ?? 'N/A',
                          style: TextStyle(
                            fontSize: 20, // Larger font for name
                            fontWeight: FontWeight.w600,
                            color: _darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 50,
                      color: _lightDivider,
                      thickness: 1.5,
                    ),
                  ],
                ),

              // Date and Time Selection Section
              Text(
                'Schedule Your Appointment', // More professional wording
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _darkCharcoal,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 20),
              _buildDateTile(
                context,
                title:
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${DateFormat('EEEE, MMMM d, y').format(_selectedDate!)}', // Full date format
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 15), // Slightly more spacing
              _buildTimeTile(
                context,
                title:
                    _selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)}',
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 50),

              // Confirmation Button
              _isLoading
                  ? Center(
                    child: Lottie.asset(
                      'assets/lottie/Animation - 1751259356339.json',
                    ),
                  )
                  : SizedBox(
                    width: double.infinity,
                    height: 60, // Taller button
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _primaryAccentBlue, // Deep blue for button
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Rounded button
                        ),
                        elevation: 8, // Deeper button shadow
                        textStyle: const TextStyle(
                          fontSize: 20, // Larger text
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0, // More letter spacing
                        ),
                      ),
                      child: const Text(
                        'Confirm Appointment',
                      ), // More formal text
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // More padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: _iconGrey, // Slightly darker grey icon
          ),
          const SizedBox(width: 15), // More spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17, // Slightly larger label
                    fontWeight: FontWeight.w600, // Stronger label weight
                    color: _mediumGreyText,
                  ),
                ),
                const SizedBox(height: 4), // More spacing
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isPrice ? 22 : 17, // Larger price/value
                    fontWeight:
                        isPrice
                            ? FontWeight.w800
                            : FontWeight.w500, // Heavier weight for price
                    color: valueColor,
                    letterSpacing: isPrice ? 0.5 : 0,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build consistent date/time tiles
  Widget _buildDateTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5, // Deeper card shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // More rounded
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 20.0,
          ), // More padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                // Use Flexible to prevent overflow if title is long
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: _darkCharcoal,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: _primaryAccentBlue, // Blue accent
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: _darkCharcoal,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.access_time_filled_outlined,
                color: _primaryAccentBlue, // Blue accent
              ),
            ],
          ),
        ),
      ),
    );
  }
}
