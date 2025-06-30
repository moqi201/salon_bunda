import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/add_service_list.dart'; // Pastikan ini ada

class HapusService extends StatefulWidget {
  const HapusService({super.key});

  @override
  State<HapusService> createState() => _HapusServiceState();
}

class _HapusServiceState extends State<HapusService> {
  Future<BaseResponse<List<Service>>?>? _servicesFuture;
  List<Service> _services = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() {
    setState(() {
      _servicesFuture = _apiService
          .getServices()
          .then((response) {
            if (response != null && response.data != null) {
              _services = response.data!;
            } else {
              _services = [];
            }
            return response;
          })
          .catchError((error) {
            print('Error fetching services: $error');
            _services = [];
            throw error;
          });
    });
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      final int id = int.tryParse(serviceId) ?? -1;
      if (id == -1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid service ID.')));
        return;
      }
      final BaseResponse? response = await _apiService.deleteService(id);
      if (response != null && response.success == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully!')),
        );
        // Refresh the list of services
        _fetchServices();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete service: ${response?.message ?? "Unknown error"}',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting service: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting service: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Manage Services', // Changed title
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.3),
        // --- TAMBAH TOMBOL KEMBALI DI SINI ---
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Icon panah kembali iOS style
          onPressed: () {
            Navigator.of(
              context,
            ).pop(); // Ini akan menutup halaman saat ini dan kembali ke halaman sebelumnya
          },
        ),
        // --- AKHIR TAMBAHAN ---
        // automaticallyImplyLeading: false, // Hapus atau biarkan ini agar leading aktif
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<BaseResponse<List<Service>>?>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error loading services: ${snapshot.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.black,
                              size: 70,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Failed to load services. Please try again later.\n\nDetails: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _fetchServices,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Reload Services',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || _services.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.spa, color: Colors.grey, size: 80),
                            SizedBox(height: 20),
                            Text(
                              'No services available.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      service.servicePhotoUrl != null &&
                                              service
                                                  .servicePhotoUrl!
                                                  .isNotEmpty
                                          ? Image.network(
                                            service.servicePhotoUrl!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      color:
                                                          Colors.grey.shade100,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.content_cut,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service.name ?? 'Service Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        // 'Rp ${service.price ?? 'N/A'}',
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   color: Colors.black54,
                                        //   fontWeight: FontWeight.w600,
                                        // ),
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp',
                                          decimalDigits: 0,
                                        ).format(service.price ?? 0),
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
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Confirm deletion with a dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Service'),
                                          content: Text(
                                            'Are you sure you want to delete "${service.name ?? 'this service'}"?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Close dialog
                                                _deleteService(
                                                  service.id.toString(),
                                                ); // Call delete service
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? shouldRefresh = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const AddServiceScreen();
            },
          );
          if (shouldRefresh == true) {
            _fetchServices();
          }
        },
        backgroundColor: Colors.black, // Black FAB color
        child: const Icon(Icons.add, color: Colors.white), // White icon
      ),
    );
  }
}
