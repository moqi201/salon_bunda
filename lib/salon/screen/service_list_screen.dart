import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/screen/booking_list_screen.dart';
// Menggunakan BookingScreen
import 'package:salon_bunda/salon/service/api_service.dart';
import 'package:salon_bunda/salon/widget/add_service_list.dart';
// MEMBETULKAN: Import dialog baru dengan path yang benar

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<BaseResponse<List<Service>>?> _services;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() {
    setState(() {
      _services = _apiService.getServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 15.0,
                ),
              ),
              onChanged: (value) {
                // TODO: Implementasi logika pencarian/filtering layanan dari data API di sini
              },
            ),
            const SizedBox(height: 20),
            // Grid untuk menampilkan layanan dari API
            Expanded(
              child: FutureBuilder<BaseResponse<List<Service>>?>(
                future: _services,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // ignore: avoid_print
                    print('Error loading services: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}\nPastikan API aktif dan ada layanan.',
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data?.data == null ||
                      snapshot.data!.data!.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada layanan tersedia dari API.'),
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.85,
                          ),
                      itemCount:
                          snapshot
                              .data!
                              .data!
                              .length, // Mengakses data yang sebenarnya
                      itemBuilder: (context, index) {
                        final service =
                            snapshot
                                .data!
                                .data![index]; // Mendapatkan objek Service
                        return GestureDetector(
                          onTap: () async {
                            final bool? shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        BookingScreen(service: service),
                              ),
                            );
                            if (shouldRefresh == true) {
                              _fetchServices();
                            }
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      height: 100,
                                                      width: 100,
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                          )
                                          : Container(
                                            // Placeholder jika tidak ada servicePhotoUrl
                                            height: 100,
                                            width: 100,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.brush,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    service.name ?? 'No Name',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.brown.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    'Rp ${service.price ?? 'N/A'}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
          // Menampilkan dialog tambah layanan
          final bool? shouldRefresh = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return const AddServiceDialog();
            },
          );
          // Jika dialog ditutup dan ada penambahan berhasil, refresh daftar layanan
          if (shouldRefresh == true) {
            _fetchServices();
          }
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
