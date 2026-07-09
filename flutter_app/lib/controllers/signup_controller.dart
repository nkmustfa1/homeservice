import '../services/auth_service.dart';

class SignupController {
  final AuthService _authService = AuthService();

  Future<void> sendOTP(String email) async {
    await _authService.sendOTP(email);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    return await _authService.register(body);
  }
}
