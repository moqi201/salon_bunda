import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/custom_text_field.dart';

class AddServiceDialog extends StatefulWidget {
  const AddServiceDialog({super.key});

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
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
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isEmployeeImage);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isEmployeeImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addService() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _employeeNameController.text.isEmpty) {
      // Validasi nama karyawan
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi.')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Layanan berhasil ditambahkan!'),
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Kembali dan beritahu ServiceListScreen untuk refresh
    } else {
      String errorMessage =
          result?.message ?? 'Gagal menambahkan layanan. Silakan coba lagi.';
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Layanan Baru', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Nama Layanan',
            ),
            CustomTextField(
              controller: _descriptionController,
              labelText: 'Deskripsi Layanan',
              keyboardType: TextInputType.multiline,
            ),
            CustomTextField(
              controller: _priceController,
              labelText: 'Harga',
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              controller: _employeeNameController,
              labelText: 'Nama Karyawan', // Field untuk nama karyawan
            ),
            const SizedBox(height: 20),
            // Bagian Foto Karyawan
            const Text(
              'Foto Karyawan (Opsional):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context, true),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
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
            const SizedBox(height: 20),
            // Bagian Foto Layanan
            const Text(
              'Foto Layanan (Opsional):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context, false),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
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
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tambah Layanan',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
