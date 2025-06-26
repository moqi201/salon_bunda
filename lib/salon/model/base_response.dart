// lib/salon/model/base_response.dart

/// A generic base response model for API calls.
/// This model handles the common structure of API responses, including a message,
/// data (which can be of any type), an optional errors map, and a success status.
class BaseResponse<T> {
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final bool? success;

  BaseResponse({this.message, this.data, this.errors, this.success});

  /// Factory constructor to create a BaseResponse instance from a JSON map.
  /// The [fromJsonT] function is crucial for deserializing the generic [T] type.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors:
          (json['errors'] is Map)
              ? Map<String, dynamic>.from(json['errors'] as Map)
              : null,
      success: json['success'] as bool?,
    );
  }

  /// Converts the BaseResponse instance to a JSON map.
  /// The [toJsonT] function is used for serializing the generic [T] type.
  Map<String, dynamic> toJson(Object? Function(T? data)? toJsonT) {
    // <--- PERUBAHAN DI SINI
    return {
      'message': message,
      'data':
          toJsonT != null
              ? toJsonT(data)
              : data, // <--- Gunakan toJsonT jika disediakan
      'errors': errors,
      'success': success,
    };
  }
}
