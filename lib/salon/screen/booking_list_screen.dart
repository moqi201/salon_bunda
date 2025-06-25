import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/booking_model.dart';
import 'package:salon_bunda/salon/model/service_model.dart'; // Mengimport Service model secara langsung
import 'package:salon_bunda/salon/service/api_service.dart';
// MENAMBAHKAN: Import BaseResponse

class BookingScreen extends StatefulWidget {
  final Service service; // Menggunakan kelas Service secara langsung

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

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

  Future<void> _submitBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal dan waktu booking.'),
        ),
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

    if (result != null && result.data != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      Navigator.pop(context, true);
    } else {
      String errorMessage =
          result?.message ?? 'Booking gagal. Silakan coba lagi.';
      if (result != null && result.errors != null) {
        result.errors?.forEach((key, value) {
          errorMessage += '\n${value[0]}';
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Booking'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Tambahkan SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Layanan
              if (widget.service.servicePhotoUrl != null &&
                  widget.service.servicePhotoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.service.servicePhotoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                'Layanan: ${widget.service.name ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Deskripsi: ${widget.service.description ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Harga: ${widget.service.price ?? 'N/A'}',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const Divider(height: 30),

              // Bagian Informasi Karyawan
              if (widget.service.employeeName != null &&
                  widget.service.employeeName!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Karyawan:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.service.employeePhotoUrl != null &&
                            widget.service.employeePhotoUrl!.isNotEmpty)
                          ClipOval(
                            child: Image.network(
                              widget.service.employeePhotoUrl!,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        const SizedBox(width: 15),
                        Text(
                          'Nama Karyawan: ${widget.service.employeeName}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                  ],
                ),

              // Bagian Pemilihan Tanggal dan Waktu
              const Text(
                'Pilih Tanggal dan Waktu Booking:',
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
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi Booking',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
