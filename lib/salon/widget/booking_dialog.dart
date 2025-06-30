import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class BookingDetailEditDialog extends StatefulWidget {
  final Datum bookingDatum;
  final VoidCallback onBookingUpdated;

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
  late DateTime _selectedDateTime;
  late String _selectedStatus;
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  // Definisikan palet warna konsisten
  static const Color _primaryAccentBlue = Color(
    0xFF0A2342,
  ); // Deep, sophisticated blue
  static const Color _darkCharcoal = Color(0xFF212121); // Deep charcoal
  static const Color _mediumGreyText = Color(
    0xFF424242,
  ); // Darker grey for details
  static const Color _redError = Color(
    0xFFD32F2F,
  ); // A clear red for error/cancel
  static const Color _disabledColor = Color(
    0xFFBDBDBD,
  ); // Warna untuk item yang dinonaktifkan

  final List<String> _statusOptions = [
    'Pending',
    'Confirmed',
    'Cancelled',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateTime =
        widget.bookingDatum.bookingTime?.toLocal() ?? DateTime.now();

    String? initialStatusFromDatum = widget.bookingDatum.status;
    if (initialStatusFromDatum != null) {
      _selectedStatus = _statusOptions.firstWhere(
        (statusOption) =>
            statusOption.toLowerCase() == initialStatusFromDatum.toLowerCase(),
        orElse:
            () => _statusOptions.first, // Fallback jika tidak ada yang cocok
      );
    } else {
      _selectedStatus = _statusOptions.first;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // 1 tahun ke belakang
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // 1 tahun ke depan
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _primaryAccentBlue, // Warna header date picker
            colorScheme: const ColorScheme.light(
              primary: _primaryAccentBlue,
            ), // Warna tombol
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _primaryAccentBlue, // Warna header time picker
            colorScheme: const ColorScheme.light(
              primary: _primaryAccentBlue,
            ), // Warna tombol
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _updateBooking() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final BaseResponse? response = await _apiService.updateBooking(
        widget.bookingDatum.id!,
        bookingTime: _selectedDateTime,
        status:
            _selectedStatus
                .toLowerCase(), // Tetap kirim ke API dalam huruf kecil
      );

      if (!mounted) return;

      if (response != null && response.success == true) {
        _showSnackBar('Booking updated successfully!', color: Colors.green);
        widget
            .onBookingUpdated(); // Panggil callback untuk refresh data di parent
        Navigator.of(context).pop(); // Pop dialog setelah berhasil diupdate
      } else {
        String errorMessage = response?.message ?? 'Failed to update booking.';
        if (response != null && response.errors != null) {
          response.errors?.forEach((key, value) {
            if (value is List) {
              errorMessage += '\n${(value).join(', ')}';
            } else {
              errorMessage += '\n$value';
            }
          });
        }
        _showSnackBar(errorMessage, color: _redError);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error updating booking: $e');
      _showSnackBar(
        'An error occurred while updating booking: $e',
        color: _redError,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {Color? color}) {
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

  @override
  Widget build(BuildContext context) {
    final String initialBookingStatus =
        widget.bookingDatum.status?.toLowerCase() ?? 'pending';

    // Logic untuk menonaktifkan input
    final bool disableDateTimePickers =
        initialBookingStatus == 'confirmed' ||
        initialBookingStatus == 'cancelled' ||
        initialBookingStatus == 'completed';

    // Logic untuk Dropdown Status
    // Jika status awal adalah 'confirmed', hanya opsi 'Cancelled' yang bisa dipilih.
    // Jika status awal adalah 'cancelled' atau 'completed', tidak ada opsi yang bisa dipilih.
    // Jika status awal adalah 'pending', semua opsi bisa dipilih.
    bool canChangeStatusToCancelledOnly = initialBookingStatus == 'confirmed';
    bool disableStatusDropdownCompletely =
        initialBookingStatus == 'cancelled' ||
        initialBookingStatus == 'completed';

    // Logika tombol Save Changes
    // Tombol Save aktif jika:
    // 1. Belum dalam proses saving.
    // 2. DAN (status awal 'pending' ATAU (status awal 'confirmed' DAN _selectedStatus adalah 'Cancelled')).
    // 3. DAN bukan status awal 'cancelled' atau 'completed'.
    bool isSaveButtonEnabled =
        !_isSaving &&
        (initialBookingStatus == 'pending' ||
            (initialBookingStatus == 'confirmed' &&
                _selectedStatus.toLowerCase() == 'cancelled')) &&
        !disableStatusDropdownCompletely;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        'Edit Booking ID: ${widget.bookingDatum.id}',
        style: const TextStyle(
          color: _darkCharcoal,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${widget.bookingDatum.service?.name ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: _mediumGreyText),
            ),
            const SizedBox(height: 10),
            Text(
              'Barber: ${widget.bookingDatum.service?.employeeName ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: _mediumGreyText),
            ),
            const SizedBox(height: 20),

            // Edit Booking Date
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                color:
                    disableDateTimePickers
                        ? _disabledColor
                        : _primaryAccentBlue,
              ),
              title: Text(
                'Booking Date',
                style: TextStyle(
                  color:
                      disableDateTimePickers ? _disabledColor : _darkCharcoal,
                ),
              ),
              subtitle: Text(
                DateFormat('EEEE, dd yyyy').format(_selectedDateTime),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      disableDateTimePickers ? _disabledColor : _mediumGreyText,
                ),
              ),
              onTap:
                  disableDateTimePickers
                      ? null
                      : () => _selectDate(context), // Nonaktifkan onTap
            ),
            const SizedBox(height: 10),

            // Edit Booking Time
            ListTile(
              leading: Icon(
                Icons.access_time,
                color:
                    disableDateTimePickers
                        ? _disabledColor
                        : _primaryAccentBlue,
              ),
              title: Text(
                'Booking Time',
                style: TextStyle(
                  color:
                      disableDateTimePickers ? _disabledColor : _darkCharcoal,
                ),
              ),
              subtitle: Text(
                DateFormat('HH:mm').format(_selectedDateTime),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      disableDateTimePickers ? _disabledColor : _mediumGreyText,
                ),
              ),
              onTap:
                  disableDateTimePickers
                      ? null
                      : () => _selectTime(context), // Nonaktifkan onTap
            ),
            const SizedBox(height: 20),

            // Edit Status
            Text(
              'Update Status:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        disableStatusDropdownCompletely
                            ? _disabledColor
                            : _primaryAccentBlue,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        disableStatusDropdownCompletely
                            ? _disabledColor
                            : _primaryAccentBlue,
                    width: 2,
                  ),
                ),
                fillColor:
                    disableStatusDropdownCompletely
                        ? Colors.grey.shade100
                        : null, // Warna latar belakang jika disabled
                filled: disableStatusDropdownCompletely,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              items:
                  _statusOptions.map((String status) {
                    // Determine if a status option should be enabled
                    bool isOptionEnabled = true;
                    if (disableStatusDropdownCompletely) {
                      isOptionEnabled =
                          false; // Disable all if dropdown completely disabled
                    } else if (canChangeStatusToCancelledOnly) {
                      isOptionEnabled =
                          status.toLowerCase() == 'cancelled' ||
                          status.toLowerCase() ==
                              initialBookingStatus; // Only 'Cancelled' or current status
                    }

                    return DropdownMenuItem<String>(
                      value: status,
                      enabled: isOptionEnabled,
                      child: Text(
                        status,
                        style: TextStyle(
                          color:
                              isOptionEnabled
                                  ? _mediumGreyText
                                  : _disabledColor,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged:
                  disableStatusDropdownCompletely
                      ? null // If completely disabled, no onChanged
                      : (String? newValue) {
                        if (canChangeStatusToCancelledOnly &&
                            newValue?.toLowerCase() != 'cancelled' &&
                            newValue?.toLowerCase() != initialBookingStatus) {
                          // If only 'Cancelled' is allowed, don't update for other values
                          return;
                        }
                        setState(() {
                          _selectedStatus = newValue!;
                        });
                      },
              style: TextStyle(
                color:
                    disableStatusDropdownCompletely
                        ? _disabledColor
                        : _darkCharcoal,
              ),
              dropdownColor: Colors.white, // Warna dropdown item
            ),
            if (disableDateTimePickers && initialBookingStatus != 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  initialBookingStatus == 'confirmed'
                      ? 'Hanya status yang dapat diubah menjadi "Cancelled". Tanggal dan waktu tidak dapat diedit.'
                      : 'Booking ini sudah ${initialBookingStatus == 'cancelled' ? 'dibatalkan' : 'selesai'} dan tidak dapat diedit lagi.',
                  style: const TextStyle(color: _redError, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: _redError),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSaveButtonEnabled ? _updateBooking : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryAccentBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('Save Changes'),
        ),
      ],
    );
  }
}
