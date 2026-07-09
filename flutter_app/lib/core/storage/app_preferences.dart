import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.setBool('isLoggedIn', false);
  }

  static String _favoriteKey({
    required String clientId,
    required String providerId,
    String? serviceId,
  }) {
    return 'favorites_${clientId}_${providerId}_${serviceId ?? ""}';
  }

  static Future<void> setFavoriteState({
    required String clientId,
    required String providerId,
    String? serviceId,
    required bool isFavorite,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _favoriteKey(
        clientId: clientId,
        providerId: providerId,
        serviceId: serviceId,
      ),
      isFavorite,
    );
  }

  static Future<bool?> getFavoriteState({
    required String clientId,
    required String providerId,
    String? serviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
      _favoriteKey(
        clientId: clientId,
        providerId: providerId,
        serviceId: serviceId,
      ),
    );
  }
}
