import 'dart:convert';
import 'dart:typed_data'; // Untuk Uint8List

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import XFile
// Import model-model terbaru
import 'package:salon_bunda/salon/model/auth_response.dart';
import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/booking_model.dart';
import 'package:salon_bunda/salon/model/riwayat_booking_model.dart'
    as riwayat_alias;
import 'package:salon_bunda/salon/model/service_model.dart';
import 'package:salon_bunda/salon/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://appsalon.mobileprojp.com/api';
  static String? _token;
  static User? _currentUser;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
    _currentUser = user;
  }

  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString('current_user');
    if (userJsonString != null) {
      _currentUser = User.fromJson(jsonDecode(userJsonString));
      return _currentUser;
    }
    return null;
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    _token = null;
    _currentUser = null;
  }

  Future<BaseResponse<AuthData>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // ignore: avoid_print
      print('[ApiService] Login URL: $url');
      // ignore: avoid_print
      print('[ApiService] Login Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<AuthData> authBaseResponse = BaseResponse.fromJson(
          jsonResponse,
          (json) => AuthData.fromJson(json as Map<String, dynamic>),
        );
        if (authBaseResponse.data?.token != null &&
            authBaseResponse.data?.user != null) {
          await saveToken(authBaseResponse.data!.token!);
          await saveCurrentUser(authBaseResponse.data!.user!);
        }
        return authBaseResponse;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<AuthData> errorResponse = BaseResponse.fromJson(
          jsonResponse,
          (json) => AuthData.fromJson(json as Map<String, dynamic>),
        );
        // ignore: avoid_print
        print(
          '[ApiService] Login failed: ${response.statusCode} - ${response.body}',
        );
        return errorResponse;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error during login: $e');
      return null;
    }
  }

  Future<BaseResponse<AuthData>?> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      // ignore: avoid_print
      print('[ApiService] Register URL: $url');
      // ignore: avoid_print
      print('[ApiService] Register Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<AuthData> authBaseResponse = BaseResponse.fromJson(
          jsonResponse,
          (json) => AuthData.fromJson(json as Map<String, dynamic>),
        );
        if (authBaseResponse.data?.token != null &&
            authBaseResponse.data?.user != null) {
          await saveToken(authBaseResponse.data!.token!);
          await saveCurrentUser(authBaseResponse.data!.user!);
        }
        return authBaseResponse;
      } else {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<AuthData> errorResponse = BaseResponse.fromJson(
          jsonResponse,
          (json) => AuthData.fromJson(json as Map<String, dynamic>),
        );
        // ignore: avoid_print
        print(
          '[ApiService] Register failed: ${response.statusCode} - ${response.body}',
        );
        return errorResponse;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error during registration: $e');
      return null;
    }
  }

  Future<BaseResponse<List<Service>>?> getServices() async {
    final url = Uri.parse('$baseUrl/services');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for getServices. User not logged in.',
      );
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ignore: avoid_print
      print('[ApiService] URL for getServices: $url');
      // ignore: avoid_print
      print(
        '[ApiService] Request Headers for getServices: ${response.request?.headers}',
      );
      // ignore: avoid_print
      print('[ApiService] Status Code for getServices: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Response Body for getServices: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<List<Service>>
        serviceListResponse = BaseResponse.fromJson(jsonResponse, (dataJson) {
          if (dataJson is List) {
            return List<Service>.from(
              dataJson.map((x) => Service.fromJson(x as Map<String, dynamic>)),
            );
          }
          return []; // Mengembalikan list kosong jika dataJson bukan list atau null
        });
        // ignore: avoid_print
        print(
          '[ApiService] Parsed Services Data Count: ${serviceListResponse.data?.length ?? 0} items',
        );
        return serviceListResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to load services: ${response.statusCode} - ${response.body}',
        );
        try {
          final jsonResponse = jsonDecode(response.body);
          return BaseResponse(
            message: jsonResponse['message'] ?? 'Failed to load services.',
            errors:
                jsonResponse['errors'] is Map
                    ? Map<String, dynamic>.from(jsonResponse['errors'])
                    : null,
            data: null, // Set data to null explicitly for error cases
          );
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error getting services: $e');
      return null;
    }
  }

  // Metode addService yang sudah mendukung pengiriman gambar Base64 dan nama karyawan
  Future<BaseResponse<Service>?> addService(
    String name,
    String description,
    String price,
    String employeeName, {
    XFile? employeeImageFile,
    XFile? serviceImageFile,
  }) async {
    final url = Uri.parse('$baseUrl/services');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for addService. User not logged in.',
      );
      return null;
    }

    Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'price': price,
      'employee_name': employeeName, // Tambahkan employee_name
    };

    if (employeeImageFile != null) {
      try {
        Uint8List bytes = await employeeImageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        body['employee_photo'] =
            base64Image; // Tambahkan employee_photo (Base64)
        // ignore: avoid_print
        print(
          '[ApiService] Employee image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        // ignore: avoid_print
        print('[ApiService] Error converting employee image to Base64: $e');
      }
    }

    if (serviceImageFile != null) {
      try {
        Uint8List bytes = await serviceImageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        body['service_photo'] = base64Image; // Tambahkan service_photo (Base64)
        // ignore: avoid_print
        print(
          '[ApiService] Service image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        // ignore: avoid_print
        print('[ApiService] Error converting service image to Base64: $e');
      }
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // ignore: avoid_print
      print('[ApiService] Add Service URL: $url');
      // ignore: avoid_print
      print('[ApiService] Add Service Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Add Service Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<Service> addServiceResponse = BaseResponse.fromJson(
          jsonResponse,
          (json) => Service.fromJson(json as Map<String, dynamic>),
        );
        // ignore: avoid_print
        print(
          '[ApiService] Service added successfully: ${addServiceResponse.message}',
        );
        return addServiceResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to add service: ${response.statusCode} - ${response.body}',
        );
        try {
          final jsonResponse = jsonDecode(response.body);
          return BaseResponse(
            message: jsonResponse['message'] ?? 'Failed to add service.',
            errors:
                jsonResponse['errors'] is Map
                    ? Map<String, dynamic>.from(jsonResponse['errors'])
                    : null,
            data: null, // Set data to null explicitly for error cases
          );
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error adding service: $e');
      return null;
    }
  }

  Future<BaseResponse<Booking>?> createBooking(
    int serviceId,
    DateTime bookingTime, {
    XFile? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/bookings');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for createBooking. User not logged in.',
      );
      return null;
    }

    Map<String, dynamic> body = {
      'service_id': serviceId,
      'booking_time': bookingTime.toIso8601String(),
    };

    if (imageFile != null) {
      try {
        Uint8List bytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        body['booking_image'] = base64Image;
        // ignore: avoid_print
        print(
          '[ApiService] Image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        // ignore: avoid_print
        print('[ApiService] Error converting image to Base64: $e');
      }
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // ignore: avoid_print
      print('[ApiService] Create Booking URL: $url');
      // ignore: avoid_print
      print('[ApiService] Create Booking Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Create Booking Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      final BaseResponse<Booking> bookingResponse = BaseResponse.fromJson(
        jsonResponse,
        (json) => Booking.fromJson(json as Map<String, dynamic>),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: avoid_print
        print(
          '[ApiService] Booking created successfully: ${bookingResponse.message}',
        );
        return bookingResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to create booking: ${response.statusCode} - ${response.body}',
        );
        return bookingResponse;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error creating booking: $e');
      return null;
    }
  }

  Future<BaseResponse<Booking>?> updateBooking(
    int bookingId, {
    String? status,
    DateTime? bookingTime,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for updateBooking. User not logged in.',
      );
      return null;
    }

    Map<String, dynamic> body = {};
    if (status != null) {
      body['status'] = status;
    }
    if (bookingTime != null) {
      body['booking_time'] = bookingTime.toIso8601String();
    }

    if (body.isEmpty) {
      // ignore: avoid_print
      print('[ApiService] No data provided for booking update.');
      return BaseResponse(message: 'Tidak ada data untuk diperbarui');
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // ignore: avoid_print
      print('[ApiService] Update Booking URL: $url');
      // ignore: avoid_print
      print('[ApiService] Update Booking Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Update Booking Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      final BaseResponse<Booking> updateBookingResponse = BaseResponse.fromJson(
        jsonResponse,
        (json) => Booking.fromJson(json as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        // ignore: avoid_print
        print(
          '[ApiService] Booking updated successfully: ${updateBookingResponse.message}',
        );
        return updateBookingResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to update booking: ${response.statusCode} - ${response.body}',
        );
        return updateBookingResponse;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error updating booking: $e');
      return null;
    }
  }

  Future<BaseResponse<List<riwayat_alias.Datum>>?> getRiwayatBooking() async {
    // MEMBETULKAN: URL endpoint untuk riwayat booking
    final url = Uri.parse('$baseUrl/bookings');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for getRiwayatBooking. User not logged in.',
      );
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ignore: avoid_print
      print('[ApiService] Get Riwayat Booking URL: $url');
      // ignore: avoid_print
      print(
        '[ApiService] Get Riwayat Booking Status Code: ${response.statusCode}',
      );
      // ignore: avoid_print
      print('[ApiService] Get Riwayat Booking Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final BaseResponse<List<riwayat_alias.Datum>>
        riwayatListResponse = BaseResponse.fromJson(jsonResponse, (dataJson) {
          if (dataJson is List) {
            return List<riwayat_alias.Datum>.from(
              dataJson.map(
                (x) => riwayat_alias.Datum.fromJson(x as Map<String, dynamic>),
              ),
            );
          }
          return []; // Mengembalikan list kosong jika dataJson bukan list atau null
        });
        // ignore: avoid_print
        print(
          '[ApiService] Parsed Riwayat Booking Data Count: ${riwayatListResponse.data?.length ?? 0} items',
        );
        return riwayatListResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to load riwayat booking: ${response.statusCode} - ${response.body}',
        );
        try {
          final jsonResponse = jsonDecode(response.body);
          return BaseResponse(
            message:
                jsonResponse['message'] ?? 'Failed to load riwayat booking.',
            errors:
                jsonResponse['errors'] is Map
                    ? Map<String, dynamic>.from(jsonResponse['errors'])
                    : null,
            data: null, // Set data to null explicitly for error cases
          );
        } catch (_) {
          return null;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error getting riwayat booking: $e');
      return null;
    }
  }

  Future<BaseResponse<dynamic>?> deleteBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    final token = await getToken();
    if (token == null) {
      // ignore: avoid_print
      print(
        '[ApiService] No token available for deleteBooking. User not logged in.',
      );
      return null;
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ignore: avoid_print
      print('[ApiService] Delete Booking URL: $url');
      // ignore: avoid_print
      print('[ApiService] Delete Booking Status Code: ${response.statusCode}');
      // ignore: avoid_print
      print('[ApiService] Delete Booking Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      final BaseResponse<dynamic> deleteResponse = BaseResponse.fromJson(
        jsonResponse,
        (json) => null, // Ini akan mengatur data di BaseResponse menjadi null
      );

      if (response.statusCode == 200) {
        // ignore: avoid_print
        print(
          '[ApiService] Booking deleted successfully: ${deleteResponse.message}',
        );
        return deleteResponse;
      } else {
        // ignore: avoid_print
        print(
          '[ApiService] Failed to delete booking: ${response.statusCode} - ${response.body}',
        );
        return deleteResponse;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ApiService] Error deleting booking: $e');
      return null;
    }
  }
}
