import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/custom_text_field.dart';

// Mengubah nama kelas dari AddServiceDialog menjadi AddServiceScreen
class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _employeeNameController =
      TextEditingController(); // Controller untuk nama karyawan

  XFile? _employeeImage; // Untuk foto karyawan
  XFile? _serviceImage; // Untuk foto layanan

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Definisikan palet warna yang konsisten
  static const Color _primaryBlue = Color(0xFF0A2342); // Deep blue
  static const Color _lightGreyBackground = Color(
    0xFFF5F5F5,
  ); // Light background grey
  static const Color _darkText = Color(0xFF333333); // Dark text color
  static const Color _lightBorder = Color(
    0xFFCCCCCC,
  ); // Light border for inputs
  static const Color _errorRed = Color(0xFFE57373); // Error red

  Future<void> _pickImage(ImageSource source, bool isEmployeeImage) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isEmployeeImage) {
          _employeeImage = pickedFile;
        } else {
          _serviceImage = pickedFile;
        }
      });
    }
  }

  Future<void> _showImageSourceActionSheet(
    BuildContext context,
    bool isEmployeeImage,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Latar belakang putih untuk bottom sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _darkText,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: _primaryBlue),
                title: Text('Kamera', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isEmployeeImage);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: _primaryBlue),
                title: Text('Galeri', style: TextStyle(color: _darkText)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isEmployeeImage);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? _primaryBlue,
        behavior: SnackBarBehavior.floating, // Muncul di atas konten
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Sudut membulat
        ),
        margin: const EdgeInsets.all(20), // Margin dari tepi
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ), // Padding konten
        elevation: 8, // Efek shadow
      ),
    );
  }

  Future<void> _addService() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _employeeNameController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi.', backgroundColor: _errorRed);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Panggil API service dengan data gambar
    BaseResponse<Service>? result = await _apiService.addService(
      _nameController.text,
      _descriptionController.text,
      _priceController.text,
      _employeeNameController.text, // Kirim nama karyawan
      employeeImageFile: _employeeImage, // Kirim file foto karyawan
      serviceImageFile: _serviceImage, // Kirim file foto layanan
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result.data != null) {
      _showSnackBar(
        result.message ?? 'Layanan berhasil ditambahkan!',
        backgroundColor: Colors.green,
      );
      // Kembali dan beritahu ServiceListScreen untuk refresh
      Navigator.pop(context, true);
    } else {
      String errorMessage =
          result?.message ?? 'Gagal menambahkan layanan. Silakan coba lagi.';
      if (result != null && result.errors != null) {
        result.errors?.forEach((key, value) {
          errorMessage += '\n${value[0]}';
        });
      }
      _showSnackBar(errorMessage, backgroundColor: _errorRed);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Layanan Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87, // Warna AppBar
        elevation: 0, // Hapus shadow AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          24.0,
        ), // Tambahkan padding ke seluruh konten
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Agar elemen mengisi lebar
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Nama Layanan',
            ),
            const SizedBox(height: 15), // Spasi antar field
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Deskripsi Layanan',
              keyboardType: TextInputType.multiline,
              maxLines: 3, // Izinkan multi-baris untuk deskripsi
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _priceController,
              labelText: 'Harga',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _employeeNameController,
              labelText: 'Nama Karyawan',
            ),
            const SizedBox(height: 25), // Spasi sebelum bagian foto
            // Bagian Foto Karyawan
            Text(
              'Foto Karyawan (Opsional):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context, true),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: _lightGreyBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _lightBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    _employeeImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_employeeImage!.path),
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          ),
                        )
                        : Icon(
                          Icons.person_add_alt_1,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
              ),
            ),
            const SizedBox(height: 25),

            // Bagian Foto Layanan
            Text(
              'Foto Layanan (Opsional):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context, false),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: _lightGreyBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _lightBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    _serviceImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_serviceImage!.path),
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          ),
                        )
                        : Icon(
                          Icons.business_center,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
              ),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: _primaryBlue),
                )
                : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87, // Warna tombol utama
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5, // Tambahkan sedikit shadow pada tombol
                    ),
                    child: const Text(
                      'Tambah Layanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
