import 'dart:convert';
import 'package:salon_bunda/salon/model/service_model.dart'; // Import Service model

// Definisi typedef untuk Datum agar sesuai dengan penggunaan di riwayat_booking.dart
typedef Datum = Booking;

// Fungsi helper untuk mengkonversi JSON string ke objek RiwayatBookingResponse
RiwayatBookingResponse riwayatBookingResponseFromJson(String str) =>
    RiwayatBookingResponse.fromJson(json.decode(str));

// Fungsi helper untuk mengkonversi objek RiwayatBookingResponse ke JSON string
String riwayatBookingResponseToJson(RiwayatBookingResponse data) =>
    json.encode(data.toJson());

class RiwayatBookingResponse {
  String? message;
  // Mengubah tipe data 'data' menjadi List<Booking> karena API mengembalikan daftar booking
  List<Booking>? data;

  RiwayatBookingResponse({this.message, this.data});

  factory RiwayatBookingResponse.fromJson(Map<String, dynamic> json) =>
      RiwayatBookingResponse(
        message: json["message"],
        // Mem-*parse* list dari JSON menjadi List<Booking>
        data:
            json["data"] == null
                ? null
                : List<Booking>.from(
                  (json["data"] as List<dynamic>).map<Booking>(
                    (x) => Booking.fromJson(x as Map<String, dynamic>),
                  ),
                ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    // Mengubah List<Booking> menjadi List<Map<String, dynamic>> untuk JSON
    "data":
        data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Booking {
  int? id;
  int? userId;
  int? serviceId;
  DateTime? bookingTime;
  String? status;
  String? bookingImage; // Path file di server
  DateTime? createdAt;
  DateTime? updatedAt;
  Service? service; // Objek Service yang bersarang
  String? bookingImageUrl; // URL lengkap untuk gambar booking

  Booking({
    this.id,
    this.userId,
    this.serviceId,
    this.bookingTime,
    this.status,
    this.bookingImage,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.bookingImageUrl,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json["id"] as int?,
    userId: json["user_id"] as int?,
    serviceId: json["service_id"] as int?,
    bookingTime:
        json["booking_time"] == null
            ? null
            : DateTime.parse(json["booking_time"] as String),
    status: json["status"] as String?,
    bookingImage: json["booking_image"] as String?,
    createdAt:
        json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"] as String),
    updatedAt:
        json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"] as String),
    service:
        json["service"] == null
            ? null
            : Service.fromJson(json["service"] as Map<String, dynamic>),
    bookingImageUrl:
        json["booking_image_url"] as String?, // Pastikan properti ini diparse
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "service_id": serviceId,
    "booking_time": bookingTime?.toIso8601String(),
    "status": status,
    "booking_image": bookingImage,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "service": service?.toJson(),
    "booking_image_url": bookingImageUrl,
  };
}
