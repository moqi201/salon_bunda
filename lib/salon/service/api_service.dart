// lib/salon/service/api_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import XFile
// Import model-model terbaru
import 'package:salon_bunda/salon/model/auth_response.dart';
import 'package:salon_bunda/salon/model/base_response.dart'; // Pastikan ini adalah BaseResponse yang sudah disesuaikan (success: bool?)
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

  // Static methods (getToken, saveToken, saveCurrentUser, getCurrentUser, deleteToken)
  // Tidak ada perubahan di sini, mereka sudah cukup baik.
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

  // Helper untuk parsing respons dan menambahkan logika 'success'
  // Ini adalah bagian kunci yang disesuaikan untuk BaseResponse Anda.
  BaseResponse<T> _parseAndCreateBaseResponse<T>(
    http.Response response,
    T Function(Object? json) fromJsonT, {
    bool defaultSuccessOn2xx =
        true, // Default: Anggap sukses jika status 200-299
  }) {
    try {
      final jsonResponse = jsonDecode(response.body);

      // Tentukan status sukses secara eksplisit
      // Gunakan field 'success' dari JSON jika ada dan boolean.
      // Jika tidak ada, gunakan status HTTP code.
      // Perbaikan di sini: Menangani nullable bool dari jsonResponse['success']
      final bool isSuccessDetermined;
      if (jsonResponse['success'] is bool) {
        isSuccessDetermined = jsonResponse['success'] as bool;
      } else {
        isSuccessDetermined =
            (defaultSuccessOn2xx &&
                (response.statusCode >= 200 && response.statusCode < 300));
      }

      T? data;
      // Hanya coba parse 'data' jika dianggap sukses dan 'data' ada
      if (isSuccessDetermined && jsonResponse['data'] != null) {
        try {
          data = fromJsonT(jsonResponse['data']);
        } catch (e) {
          print('[ApiService] Warning: Failed to parse data on success: $e');
          // Jika gagal parse data, biarkan data null, tapi tetap tandai sebagai sukses
          data = null;
        }
      }

      // Karena BaseResponse.message bisa nullable sekarang, kita harus memastikan ada string.
      // Jika API tidak mengirim 'message', berikan default.
      final String message =
          (jsonResponse['message'] as String?) ?? // Langsung casting ke String?
          (isSuccessDetermined ? 'Operasi berhasil.' : 'Operasi gagal.');

      return BaseResponse<T>(
        message: message,
        data: data,
        errors:
            (jsonResponse['errors'] is Map)
                ? Map<String, dynamic>.from(jsonResponse['errors'] as Map)
                : null,
        success:
            isSuccessDetermined, // <<< Ini yang akan mengesampingkan default di BaseResponse
      );
    } catch (e) {
      print(
        '[ApiService] Error parsing API response: $e. Response body: ${response.body}',
      );
      // Jika ada error decoding JSON atau error lain, anggap gagal
      return BaseResponse<T>(
        message: 'Gagal memproses respons server: $e',
        success: false, // Pastikan ini false jika ada error parsing
      );
    }
  }

  // --- Metode Login ---
  Future<BaseResponse<AuthData>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('[ApiService] Login URL: $url');
      print('[ApiService] Login Status Code: ${response.statusCode}');
      print('[ApiService] Login Response Body: ${response.body}');

      final BaseResponse<AuthData> authBaseResponse =
          _parseAndCreateBaseResponse(
            response,
            (json) => AuthData.fromJson(json as Map<String, dynamic>),
          );

      // Logika token dan user disimpan jika login sukses
      // PERBAIKAN BARIS 144: Cek `authBaseResponse.success` secara eksplisit
      if (authBaseResponse.success == true) {
        // <--- PERBAIKAN DI SINI
        if (authBaseResponse.data?.token != null &&
            authBaseResponse.data?.user != null) {
          await saveToken(authBaseResponse.data!.token!);
          await saveCurrentUser(authBaseResponse.data!.user!);
        } else {
          // Jika success true tapi data token/user null, mungkin ada masalah di API
          print('[ApiService] Login success but token/user data missing.');
        }
      } else {
        print(
          '[ApiService] Login failed: ${response.statusCode} - ${response.body}',
        );
      }
      return authBaseResponse;
    } catch (e) {
      print('[ApiService] Error during login: $e');
      return BaseResponse<AuthData>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode Register ---
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

      // Gunakan debugPrint untuk logging dalam mode debug
      if (kDebugMode) {
        debugPrint('[ApiService] Register URL: $url');
        debugPrint('[ApiService] Register Status Code: ${response.statusCode}');
        debugPrint('[ApiService] Register Response Body: ${response.body}');
        debugPrint(
          '[ApiService] Register Response Headers: ${response.headers}',
        );
      }

      // --- PENANGANAN STATUS CODE 302 (REDIRECT) ---
      if (response.statusCode == 302) {
        final redirectLocation = response.headers['location'];
        debugPrint('[ApiService] !!! REDIRECT DETECTED (Status 302) !!!');
        debugPrint('Redirecting to: $redirectLocation');
        return BaseResponse<AuthData>(
          success: false,
          message:
              'Gagal mendaftar: Server melakukan pengalihan (redirect). '
              'Kemungkinan URL API salah atau konfigurasi server tidak tepat. '
              'Redirect ke: ${redirectLocation ?? 'URL tidak diketahui'}',
          errors: {
            'redirect_error': [
              'Server sent a 302 redirect. Expected JSON response.',
            ],
          },
        );
      }

      // --- PENANGANAN STATUS CODE SUKSES (200, 201) ---
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = jsonDecode(response.body);
          final BaseResponse<AuthData> authBaseResponse = BaseResponse.fromJson(
            jsonResponse,
            (json) => AuthData.fromJson(json as Map<String, dynamic>),
          );

          if (authBaseResponse.success == true) {
            if (authBaseResponse.data?.token != null &&
                authBaseResponse.data?.user != null) {
              await saveToken(authBaseResponse.data!.token!);
              await saveCurrentUser(authBaseResponse.data!.user!);
              debugPrint(
                '[ApiService] Register successful. Token and user data saved.',
              );
            } else {
              debugPrint(
                '[ApiService] Register success, but token or user data is missing in response.',
              );
            }
          } else {
            // Ini menangani kasus API mengembalikan success: false tetapi status 200/201
            debugPrint(
              '[ApiService] Register failed according to API response (success: false). Message: ${authBaseResponse.message}',
            );
          }
          return authBaseResponse;
        } on FormatException catch (e) {
          // Menangkap error parsing JSON jika body tidak valid JSON meskipun status 200/201
          debugPrint(
            '[ApiService] FormatException during JSON decode (Status ${response.statusCode}): $e',
          );
          debugPrint('Invalid JSON Body: ${response.body}');
          return BaseResponse<AuthData>(
            success: false,
            message:
                'Gagal memproses data pendaftaran dari server. Respons tidak valid.',
            errors: {
              'json_parse_error': [e.toString(), 'Raw body: ${response.body}'],
            },
          );
        } catch (e) {
          debugPrint(
            '[ApiService] Unexpected error after successful status code: $e',
          );
          return BaseResponse<AuthData>(
            success: false,
            message:
                'Terjadi kesalahan tak terduga setelah pendaftaran berhasil: $e',
          );
        }
      } else {
        // --- PENANGANAN STATUS CODE ERROR (4xx, 5xx) ---
        // Mencoba mengurai body sebagai JSON karena banyak API mengirim detail error dalam JSON
        try {
          final jsonResponse = jsonDecode(response.body);
          final BaseResponse<AuthData> errorResponse = BaseResponse.fromJson(
            jsonResponse,
            (json) => AuthData.fromJson(
              json as Map<String, dynamic>,
            ), // Mungkin AuthData ini tidak relevan untuk error, tapi kita pakai BaseResponsenya
          );
          debugPrint(
            '[ApiService] Register failed with status ${response.statusCode}. API message: ${errorResponse.message}',
          );
          return errorResponse; // Mengembalikan BaseResponse dengan pesan error dari API
        } on FormatException catch (e) {
          // Jika body respons error BUKAN JSON (misal HTML error page dari server)
          debugPrint(
            '[ApiService] FormatException during JSON decode for error status (Status ${response.statusCode}): $e',
          );
          debugPrint('Non-JSON Error Body: ${response.body}');
          return BaseResponse<AuthData>(
            success: false,
            message:
                'Gagal mendaftar: Kesalahan server (${response.statusCode}). Respons tidak valid atau bukan JSON. ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}',
            errors: {
              'http_error': [
                'Status: ${response.statusCode}',
                'Body: ${response.body}',
              ],
            },
          );
        } catch (e) {
          // Menangkap error lain saat memproses respons error
          debugPrint(
            '[ApiService] Unexpected error handling non-200 status: $e',
          );
          return BaseResponse<AuthData>(
            success: false,
            message:
                'Gagal mendaftar: Terjadi kesalahan tak terduga saat memproses respons error.',
          );
        }
      }
    } catch (e) {
      // --- PENANGANAN ERROR JARINGAN ATAU EXCEPTION LAINNYA ---
      debugPrint('[ApiService] Error during registration: $e');
      return BaseResponse<AuthData>(
        message:
            'Gagal terhubung ke server atau terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode getServices ---
  Future<BaseResponse<List<Service>>?> getServices() async {
    final url = Uri.parse('$baseUrl/services');
    final token = await getToken();
    if (token == null) {
      print(
        '[ApiService] No token available for getServices. User not logged in.',
      );
      // Mengembalikan BaseResponse yang valid dengan status gagal
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ApiService] URL for getServices: $url');
      print(
        '[ApiService] Request Headers for getServices: ${response.request?.headers}',
      );
      print('[ApiService] Status Code for getServices: ${response.statusCode}');
      print('[ApiService] Response Body for getServices: ${response.body}');

      final BaseResponse<List<Service>> serviceListResponse =
          _parseAndCreateBaseResponse(response, (dataJson) {
            if (dataJson is List) {
              return List<Service>.from(
                dataJson.map(
                  (x) => Service.fromJson(x as Map<String, dynamic>),
                ),
              );
            }
            return [];
          });
      print(
        '[ApiService] Parsed Services Data Count: ${serviceListResponse.data?.length ?? 0} items',
      );
      return serviceListResponse;
    } catch (e) {
      print('[ApiService] Error getting services: $e');
      return BaseResponse<List<Service>>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode addService ---
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
      print(
        '[ApiService] No token available for addService. User not logged in.',
      );
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
    }

    Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'price': price,
      'employee_name': employeeName,
    };

    if (employeeImageFile != null) {
      try {
        Uint8List bytes = await employeeImageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        body['employee_photo'] = base64Image;
        print(
          '[ApiService] Employee image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        print('[ApiService] Error converting employee image to Base64: $e');
        return BaseResponse(
          message: 'Gagal memproses gambar karyawan.',
          success: false,
        );
      }
    }

    if (serviceImageFile != null) {
      try {
        Uint8List bytes = await serviceImageFile.readAsBytes();
        String base64Image = base64Encode(bytes);
        body['service_photo'] = base64Image;
        print(
          '[ApiService] Service image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        print('[ApiService] Error converting service image to Base64: $e');
        return BaseResponse(
          message: 'Gagal memproses gambar layanan.',
          success: false,
        );
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

      print('[ApiService] Add Service URL: $url');
      print('[ApiService] Add Service Status Code: ${response.statusCode}');
      print('[ApiService] Add Service Response Body: ${response.body}');

      final BaseResponse<Service> addServiceResponse =
          _parseAndCreateBaseResponse(
            response,
            (json) => Service.fromJson(json as Map<String, dynamic>),
          );
      print(
        '[ApiService] Service added successfully: ${addServiceResponse.message}',
      );
      return addServiceResponse;
    } catch (e) {
      print('[ApiService] Error adding service: $e');
      return BaseResponse<Service>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode createBooking ---
  Future<BaseResponse<Booking>?> createBooking(
    int serviceId,
    DateTime bookingTime, {
    XFile? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/bookings');
    final token = await getToken();
    if (token == null) {
      print(
        '[ApiService] No token available for createBooking. User not logged in.',
      );
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
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
        print(
          '[ApiService] Image converted to Base64. Size: ${base64Image.length} characters.',
        );
      } catch (e) {
        print('[ApiService] Error converting image to Base64: $e');
        return BaseResponse(
          message: 'Gagal memproses gambar booking.',
          success: false,
        );
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

      print('[ApiService] Create Booking URL: $url');
      print('[ApiService] Create Booking Status Code: ${response.statusCode}');
      print('[ApiService] Create Booking Response Body: ${response.body}');

      final BaseResponse<Booking> bookingResponse = _parseAndCreateBaseResponse(
        response,
        (json) => Booking.fromJson(json as Map<String, dynamic>),
      );
      print(
        '[ApiService] Booking created successfully: ${bookingResponse.message}',
      );
      return bookingResponse;
    } catch (e) {
      print('[ApiService] Error creating booking: $e');
      return BaseResponse<Booking>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode updateBooking ---
  Future<BaseResponse<Booking>?> updateBooking(
    int bookingId, {
    String? status,
    DateTime? bookingTime,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    final token = await getToken();
    if (token == null) {
      print(
        '[ApiService] No token available for updateBooking. User not logged in.',
      );
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
    }

    Map<String, dynamic> body = {};
    if (status != null) {
      body['status'] = status;
    }
    if (bookingTime != null) {
      body['booking_time'] = bookingTime.toIso8601String();
    }

    if (body.isEmpty) {
      print('[ApiService] No data provided for booking update.');
      return BaseResponse(
        message: 'Tidak ada data untuk diperbarui',
        success: false,
      );
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

      print('[ApiService] Update Booking URL: $url');
      print('[ApiService] Update Booking Status Code: ${response.statusCode}');
      print('[ApiService] Update Booking Response Body: ${response.body}');

      final BaseResponse<Booking> updateBookingResponse =
          _parseAndCreateBaseResponse(
            response,
            (json) => Booking.fromJson(json as Map<String, dynamic>),
          );
      print(
        '[ApiService] Booking updated successfully: ${updateBookingResponse.message}',
      );
      return updateBookingResponse;
    } catch (e) {
      print('[ApiService] Error updating booking: $e');
      return BaseResponse<Booking>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode getRiwayatBooking ---
  Future<BaseResponse<List<riwayat_alias.Datum>>?> getRiwayatBooking() async {
    final url = Uri.parse('$baseUrl/bookings');
    final token = await getToken();
    if (token == null) {
      print(
        '[ApiService] No token available for getRiwayatBooking. User not logged in.',
      );
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ApiService] Get Riwayat Booking URL: $url');
      print(
        '[ApiService] Get Riwayat Booking Status Code: ${response.statusCode}',
      );
      print('[ApiService] Get Riwayat Booking Response Body: ${response.body}');

      final BaseResponse<List<riwayat_alias.Datum>> riwayatListResponse =
          _parseAndCreateBaseResponse(response, (dataJson) {
            if (dataJson is List) {
              return List<riwayat_alias.Datum>.from(
                dataJson.map(
                  (x) =>
                      riwayat_alias.Datum.fromJson(x as Map<String, dynamic>),
                ),
              );
            }
            return [];
          });
      print(
        '[ApiService] Parsed Riwayat Booking Data Count: ${riwayatListResponse.data?.length ?? 0} items',
      );
      return riwayatListResponse;
    } catch (e) {
      print('[ApiService] Error getting riwayat booking: $e');
      return BaseResponse<List<riwayat_alias.Datum>>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }

  // --- Metode deleteBooking ---
  Future<BaseResponse<dynamic>?> deleteBooking(int bookingId) async {
    final url = Uri.parse('$baseUrl/bookings/$bookingId');
    final token = await getToken();
    if (token == null) {
      print(
        '[ApiService] No token available for deleteBooking. User not logged in.',
      );
      return BaseResponse(message: 'Autentikasi diperlukan.', success: false);
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[ApiService] Delete Booking URL: $url');
      print('[ApiService] Delete Booking Status Code: ${response.statusCode}');
      print('[ApiService] Delete Booking Response Body: ${response.body}');

      // Gunakan helper _parseAndCreateBaseResponse, dengan fromJsonT yang mengembalikan null karena tidak ada data yang diharapkan
      final BaseResponse<dynamic> deleteResponse = _parseAndCreateBaseResponse(
        response,
        (json) => null, // Data tidak diharapkan setelah delete
      );

      print(
        '[ApiService] Booking deleted successfully: ${deleteResponse.message}',
      );
      return deleteResponse;
    } catch (e) {
      print('[ApiService] Error deleting booking: $e');
      return BaseResponse<dynamic>(
        message: 'Terjadi kesalahan jaringan: $e',
        success: false,
      );
    }
  }
}
