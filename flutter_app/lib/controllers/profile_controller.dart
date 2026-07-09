import '../services/profile_service.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  Future<bool> hasOngoingOrders(String userId) async {
    return await _profileService.hasOngoingOrders(userId);
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    return await _profileService.fetchUserData(userId);
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String userId,
    required String password,
  }) async {
    return await _profileService.deleteAccount(
      userId: userId,
      password: password,
    );
  }
}
