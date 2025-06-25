// To parse this JSON data, do
//
//     final delete = deleteFromJson(jsonString);

import 'dart:convert';

Delete deleteFromJson(String str) => Delete.fromJson(json.decode(str));

String deleteToJson(Delete data) => json.encode(data.toJson());

class Delete {
  String? message;
  dynamic data;

  Delete({
    this.message,
    this.data,
  });

  factory Delete.fromJson(Map<String, dynamic> json) => Delete(
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
      };
}