import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';

class HomeService {
  Future<Map<String, dynamic>> fetchCategories() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/categories.php"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch categories");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchPopularServices() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/top_services.php"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch popular services");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchTopProviders() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/top_providers.php"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch top providers");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchLocation(String userId) async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/get_location.php?user_id=$userId"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch location");
    }

    return jsonDecode(response.body);
  }
}
