// lib/salon/screen/booking_detail_edit_dialog.dart (File Baru)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/booking_model.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart'
    as riwayat_alias;
import 'package:salon_bunda/salon/service/api_service.dart';

// Ini adalah dialog untuk mengelola detail satu booking (mengambil alih logika dari BookingManagementScreen sebelumnya)
class BookingDetailEditDialog extends StatefulWidget {
  final riwayat_alias.Datum
  bookingDatum; // Menerima Datum dari riwayat_booking_model
  final Function()
  onBookingUpdated; // Callback untuk memberitahu jika booking diupdate/hapus

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String?
  _selectedStatus; // Untuk status booking (pending, confirmed, cancelled)
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan data booking yang ada
    _selectedDate = widget.bookingDatum.bookingTime?.toLocal();
    _selectedTime =
        widget.bookingDatum.bookingTime != null
            ? TimeOfDay.fromDateTime(widget.bookingDatum.bookingTime!.toLocal())
            : null;
    _selectedStatus = widget.bookingDatum.status;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
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
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateBooking() async {
    if (widget.bookingDatum.id == null) {
      _showSnackBar('ID Booking tidak tersedia.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    DateTime? updatedDateTime;
    if (_selectedDate != null && _selectedTime != null) {
      updatedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    BaseResponse<Booking>? result = await _apiService.updateBooking(
      widget.bookingDatum.id!,
      status: _selectedStatus,
      bookingTime: updatedDateTime,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result.data != null) {
      _showSnackBar(result.message ?? 'Booking berhasil diperbarui.');
      widget
          .onBookingUpdated(); // Panggil callback untuk refresh di halaman sebelumnya
      Navigator.of(context).pop(); // Tutup dialog
    } else {
      _showSnackBar(
        result?.message ?? 'Gagal memperbarui booking. Silakan coba lagi.',
      );
    }
  }

  Future<void> _deleteBooking() async {
    if (widget.bookingDatum.id == null) {
      _showSnackBar('ID Booking tidak tersedia.');
      return;
    }

    // Konfirmasi penghapusan
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus booking ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) {
      return; // Batal menghapus
    }

    setState(() {
      _isLoading = true;
    });

    BaseResponse<dynamic>? result = await _apiService.deleteBooking(
      widget.bookingDatum.id!,
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null &&
        (result.message != null && result.message!.isNotEmpty)) {
      _showSnackBar(result.message!);
      widget
          .onBookingUpdated(); // Panggil callback untuk refresh di halaman sebelumnya
      Navigator.of(context).pop(); // Tutup dialog
    } else {
      _showSnackBar('Gagal menghapus booking. Silakan coba lagi.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Manajemen Booking',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(height: 30),
              Text(
                'Layanan: ${widget.bookingDatum.service?.name ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Harga: Rp ${widget.bookingDatum.service?.price?.toStringAsFixed(2) ?? 'N/A'}', // Menggunakan toStringAsFixed
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const Divider(height: 30),
              const Text(
                'Ubah Detail Booking',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Pilih Waktu'
                      : 'Waktu: ${_selectedTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status Booking',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items:
                    <String>[
                      'pending',
                      'confirmed',
                      'cancelled',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _updateBooking,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Perbarui Booking',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _deleteBooking,
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus Booking',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
