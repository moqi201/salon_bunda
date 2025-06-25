import 'dart:convert';

import 'package:salon_bunda/salon/model/service_model.dart'; // Import the Service model

RiwayatBooking riwayatBookingFromJson(String str) =>
    RiwayatBooking.fromJson(json.decode(str));

String riwayatBookingToJson(RiwayatBooking data) => json.encode(data.toJson());

class RiwayatBooking {
  String? message;
  List<Datum>? data;

  RiwayatBooking({this.message, this.data});

  factory RiwayatBooking.fromJson(Map<String, dynamic> json) => RiwayatBooking(
    message: json["message"] as String?, // Added explicit cast for safety
    data:
        json["data"] == null
            ? []
            : List<Datum>.from(
              (json["data"] as List<dynamic>).map(
                (x) => Datum.fromJson(x as Map<String, dynamic>),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  int? userId; // Diubah menjadi int?
  int? serviceId; // Diubah menjadi int?
  DateTime? bookingTime;
  String? status;
  String? employeeName;
  DateTime? createdAt;
  DateTime? updatedAt;
  Service? service; // Pastikan ini mengacu pada model Service yang diperbarui

  Datum({
    this.id,
    this.userId,
    this.serviceId,
    this.bookingTime,
    this.status,
    this.employeeName,
    this.createdAt,
    this.updatedAt,
    this.service,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] as int?,
    // MEMBETULKAN: Menggunakan int.tryParse karena user_id bisa berupa string atau int dari API
    userId:
        json["user_id"] != null
            ? int.tryParse(json["user_id"].toString())
            : null,
    // MEMBETULKAN: Menggunakan int.tryParse karena service_id bisa berupa string atau int dari API
    serviceId:
        json["service_id"] != null
            ? int.tryParse(json["service_id"].toString())
            : null,
    // MEMBETULKAN: Mengatasi format booking_time dengan mengganti spasi menjadi 'T'
    bookingTime:
        json["booking_time"] != null
            ? DateTime.tryParse(
              (json["booking_time"] as String).replaceAll(' ', 'T'),
            )
            : null,
    status: json["status"] as String?,
    employeeName: json["employee_name"] as String?,
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
            : null, // Parse nested Service
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "service_id": serviceId,
    "booking_time": bookingTime?.toIso8601String(),
    "status": status,
    "employee_name": employeeName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "service": service?.toJson(),
  };
}
