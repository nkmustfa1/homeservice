import '../services/auth_service.dart';

class ForgetPasswordController {
  final AuthService _authService = AuthService();

  Future<bool> checkEmailExists(String email) async {
    return await _authService.checkEmailExists(email);
  }

  Future<void> sendOTP(String email) async {
    await _authService.sendOTP(email);
  }
}
