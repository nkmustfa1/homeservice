import '../services/home_service.dart';

class HomeController {
  final HomeService _homeService = HomeService();

  Future<Map<String, dynamic>> fetchCategories() async {
    return await _homeService.fetchCategories();
  }

  Future<Map<String, dynamic>> fetchPopularServices() async {
    return await _homeService.fetchPopularServices();
  }

  Future<Map<String, dynamic>> fetchTopProviders() async {
    return await _homeService.fetchTopProviders();
  }

  Future<Map<String, dynamic>> fetchLocation(String userId) async {
    return await _homeService.fetchLocation(userId);
  }
}
