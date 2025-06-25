import 'user_model.dart'; // Import the User model

/// Represents the data structure for authentication responses (login and register).
/// This model wraps the token and user information received from the API.
class AuthResponse {
  final String message;
  final AuthData? data;
  final Map<String, dynamic>? errors; // For error messages, if any

  AuthResponse({required this.message, this.data, this.errors});

  /// Factory constructor to create an AuthResponse instance from a JSON map.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      data:
          json['data'] != null
              ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Converts the AuthResponse instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data?.toJson(), 'errors': errors};
  }
}

/// Represents the data contained within the 'data' field of AuthResponse.
/// It holds the authentication token and the user's details.
class AuthData {
  final String? token; // The authentication token
  final User? user; // The user's details

  AuthData({this.token, this.user});

  /// Factory constructor to create an AuthData instance from a JSON map.
  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] as String?,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
    );
  }

  /// Converts the AuthData instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson()};
  }
}
