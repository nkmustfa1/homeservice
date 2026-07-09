import '../services/auth_service.dart';
import '../core/storage/app_preferences.dart';

class LoginController {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(
      email: email,
      password: password,
    );

    if (response['success'] == true) {
      await AppPreferences.setLoggedIn(true);
      await AppPreferences.setUserId(response['user_id']);
    }

    return response;
  }
}
