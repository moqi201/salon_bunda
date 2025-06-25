import 'dart:convert';

// Fungsi helper untuk mengkonversi JSON string ke objek ServiceResponse
ServiceResponse serviceResponseFromJson(String str) =>
    ServiceResponse.fromJson(json.decode(str));

// Fungsi helper untuk mengkonversi objek ServiceResponse ke JSON string
String serviceResponseToJson(ServiceResponse data) =>
    json.encode(data.toJson());

class ServiceResponse {
  final String? message;
  final List<Service>? data; // Untuk respons list layanan (getServices)

  ServiceResponse({this.message, this.data});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      message: json["message"] as String?,
      // Periksa apakah 'data' adalah List, jika ya, parse sebagai List<Service>
      // Jika 'data' adalah Object tunggal (seperti pada respons addService), bungkus dalam List
      // Jika null, kembalikan list kosong
      data:
          json["data"] is List
              ? List<Service>.from(
                (json["data"] as List<dynamic>).map<Service>(
                  (x) => Service.fromJson(x as Map<String, dynamic>),
                ),
              )
              : (json["data"] != null
                  ? [Service.fromJson(json["data"] as Map<String, dynamic>)]
                  : []),
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

// Model untuk objek Service individu
class Service {
  int? id;
  String? name;
  String? description;
  double? price; // PERBAIKAN DI SINI: Menggunakan double? untuk harga desimal
  String? employeeName;
  String? employeePhoto; // Ini adalah path file di server
  String? servicePhoto; // Ini adalah path file di server
  DateTime? createdAt;
  DateTime? updatedAt;
  String? employeePhotoUrl; // Ini adalah URL lengkap untuk ditampilkan
  String? servicePhotoUrl; // Ini adalah URL lengkap untuk ditampilkan

  Service({
    this.id,
    this.name,
    this.description,
    this.price,
    this.employeeName,
    this.employeePhoto,
    this.servicePhoto,
    this.createdAt,
    this.updatedAt,
    this.employeePhotoUrl,
    this.servicePhotoUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    // PERBAIKAN DI SINI: Menggunakan double.tryParse untuk mengkonversi string harga
    final String? priceString = json["price"]?.toString();
    final double? parsedPrice =
        priceString != null && priceString.isNotEmpty
            ? double.tryParse(priceString)
            : null;

    return Service(
      id: json["id"] as int?,
      name: json["name"] as String?,
      description: json["description"] as String?,
      price: parsedPrice, // Menggunakan nilai double yang sudah diparse
      employeeName: json["employee_name"] as String?,
      employeePhoto: json["employee_photo"] as String?,
      servicePhoto: json["service_photo"] as String?,
      createdAt:
          json["created_at"] == null
              ? null
              : DateTime.parse(json["created_at"] as String),
      updatedAt:
          json["updated_at"] == null
              ? null
              : DateTime.parse(json["updated_at"] as String),
      employeePhotoUrl: json["employee_photo_url"] as String?,
      servicePhotoUrl: json["service_photo_url"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    // Konversi kembali ke string jika API mengharapkan string untuk harga
    "price": price?.toStringAsFixed(
      2,
    ), // Contoh: format 2 angka di belakang koma
    "employee_name": employeeName,
    "employee_photo": employeePhoto,
    "service_photo": servicePhoto,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "employee_photo_url": employeePhotoUrl,
    "service_photo_url": servicePhotoUrl,
  };
}
