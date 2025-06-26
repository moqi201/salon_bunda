// lib/salon/model/riwayat_booking_model.dart
import 'dart:convert';

import 'package:salon_bunda/salon/model/base_response.dart';
import 'package:salon_bunda/salon/model/service_model.dart'; // Import Service model

// Fungsi helper untuk mem-parsing BaseResponse<List<Datum>> dari JSON string
BaseResponse<List<Datum>> riwayatBookingResponseFromJson(
  String str,
) => BaseResponse.fromJson(
  json.decode(str) as Map<String, dynamic>,
  // Fungsi untuk mengubah 'data' (yang merupakan List<dynamic>) menjadi List<Datum>
  (json) => List<Datum>.from(
    (json as List<dynamic>).map(
      (x) => Datum.fromJson(x as Map<String, dynamic>),
    ),
  ),
);

// Fungsi helper untuk mengkonversi objek BaseResponse<List<Datum>> ke JSON string
String riwayatBookingResponseToJson(BaseResponse<List<Datum>> data) =>
    json.encode(
      data.toJson(
        // Fungsi untuk mengubah List<Datum> menjadi List<Map<String, dynamic>>
        (dataList) => dataList?.map((x) => x.toJson()).toList() ?? [],
      ),
    );

class Datum {
  final int? id;
  final int? userId;
  final int? serviceId;
  final DateTime? bookingTime;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Service? service; // Objek Service yang bersarang

  Datum({
    this.id,
    this.userId,
    this.serviceId,
    this.bookingTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.service,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] as int?,
    userId:
        json["user_id"] != null
            ? int.tryParse(json["user_id"].toString())
            : null,
    serviceId:
        json["service_id"] != null
            ? int.tryParse(json["service_id"].toString())
            : null,
    bookingTime:
        json["booking_time"] != null
            ? DateTime.tryParse(
              (json["booking_time"] as String).replaceAll(' ', 'T'),
            )
            : null,
    status: json["status"] as String?,
    createdAt:
        json["created_at"] != null
            ? DateTime.parse(json["created_at"] as String)
            : null,
    updatedAt:
        json["updated_at"] != null
            ? DateTime.parse(json["updated_at"] as String)
            : null,
    service:
        json["service"] != null
            ? Service.fromJson(json["service"] as Map<String, dynamic>)
            : null, // Parsing objek Service di sini
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "service_id": serviceId,
    "booking_time": bookingTime?.toIso8601String(),
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "service": service?.toJson(), // Serialisasi objek Service di sini
  };

  // --- GETTER UNTUK KEMUDAHAN AKSES FOTO ---
  // Getter ini akan mencari servicePhotoUrl terlebih dahulu,
  // jika null atau kosong, baru mencari employeePhotoUrl.
  String? get photoUrl {
    if (service?.servicePhotoUrl != null &&
        service!.servicePhotoUrl!.isNotEmpty) {
      return service!.servicePhotoUrl;
    }
    return null;
  }

  // --- AKHIR GETTER ---
}
