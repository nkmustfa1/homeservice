import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.login);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<void> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.sendOtp),
      body: {"email": email},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send OTP");
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyOtp),
      body: {
        "email": email,
        "otp_code": otp,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to verify OTP");
    }

    return jsonDecode(response.body);
  }

  Future<bool> checkEmailExists(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.checkEmail),
      body: {
        "email": email,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'];
    }

    return false;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiConstants.signup),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> resetPassword({
    required Map<String, String> requestBody,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.resetPassword),
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to reset password");
    }

    return jsonDecode(response.body);
  }
}
