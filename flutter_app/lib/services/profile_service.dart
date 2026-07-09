import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';

class ProfileService {
  Future<bool> hasOngoingOrders(String userId) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/check_ongoing_orders.php?client_id=$userId",
      ),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return (data['ongoing_orders'] as int) > 0;
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/get_client_data.php?user_id=$userId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch user data");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String userId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/delete_account.php"),
      body: {
        "user_id": userId,
        "password": password,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Server error");
    }

    return json.decode(response.body);
  }
}
