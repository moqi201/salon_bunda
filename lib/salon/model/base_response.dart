/// A generic base response model for API calls.
/// This model handles the common structure of API responses, including a message,
/// data (which can be of any type), and an optional errors map.
class BaseResponse<T> {
  final String message;
  final T? data; // Generic type for the data payload
  final Map<String, dynamic>? errors; // For validation or other errors

  BaseResponse({required this.message, this.data, this.errors});

  /// Factory constructor to create a BaseResponse instance from a JSON map.
  /// The [fromJsonT] function is crucial for deserializing the generic [T] type.
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors:
          (json['errors'] is Map)
              ? Map<String, dynamic>.from(json['errors'] as Map)
              : null,
    );
  }

  /// Converts the BaseResponse instance to a JSON map.
  /// Note: Serialization of generic [T] data needs to be handled by the caller
  /// if [T] itself is a complex object and needs to be converted to JSON.
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data':
          data, // Direct use, assuming T can be directly converted or is primitive
      'errors': errors,
    };
  }
}
