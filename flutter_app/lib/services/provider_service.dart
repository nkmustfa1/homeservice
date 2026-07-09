import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';
import '../models/service_model.dart';

class ProviderService {
  Future<Map<String, dynamic>> fetchProviderDetails({
    required String providerId,
    String? serviceId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/provider_details.php"
        "?provider_id=$providerId&service_id=${serviceId ?? ''}",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch provider details");
    }

    return jsonDecode(response.body);
  }

  Future<bool> addFavorite({
    required String clientId,
    required String providerServiceId,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/add_favorite.php"),
      body: {
        "client_id": clientId,
        "provider_service_id": providerServiceId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }

  Future<bool> removeFavorite({
    required String clientId,
    required String providerServiceId,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/remove_favorite.php"),
      body: {
        "client_id": clientId,
        "provider_service_id": providerServiceId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }

  Future<Map<String, dynamic>> fetchServicesForCategory({
    required String categoryId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/services.php?category_id=$categoryId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch services");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchProviders({
    required String categoryId,
    String? serviceId,
  }) async {
    final uri = (serviceId == null || serviceId.isEmpty)
        ? Uri.parse(
            "${ApiConstants.baseUrl}/providers.php?category=$categoryId",
          )
        : Uri.parse(
            "${ApiConstants.baseUrl}/providers.php?category=$categoryId&service=$serviceId",
          );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch providers");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchFavorites({
    required String clientId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/favorites.php?client_id=$clientId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch favorites");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchClientLocation({
    required String clientId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/getClientLocation.php?clientId=$clientId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch client location");
    }

    return jsonDecode(response.body);
  }

  Future<List<ServiceModel>> searchServices({
    String? search,
  }) async {
    final String url = (search != null && search.isNotEmpty)
        ? "${ApiConstants.baseUrl}/search.php?search=${Uri.encodeComponent(search)}"
        : "${ApiConstants.baseUrl}/search.php";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to search services");
    }

    final Map<String, dynamic> responseMap = jsonDecode(response.body);

    if (responseMap['providers'] != null && responseMap['providers'] is List) {
      return (responseMap['providers'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchReviews({
    required String clientId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${ApiConstants.baseUrl}/get_evaluations.php?client_id=$clientId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch reviews");
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<bool> submitReview({
    required String clientId,
    required String providerId,
    required String serviceId,
    required String providerServiceId,
    required double rating,
    required String comment,
    String? reviewId,
  }) async {
    final url = reviewId != null
        ? Uri.parse("${ApiConstants.baseUrl}/update_evaluation.php")
        : Uri.parse("${ApiConstants.baseUrl}/create_evaluation.php");

    final response = await http.post(
      url,
      body: {
        "client_id": clientId,
        "provider_id": providerId,
        "service_id": serviceId,
        "provider_service_id": providerServiceId,
        "eva_byno": rating.toString(),
        "comment": comment,
        if (reviewId != null) "review_id": reviewId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }

  Future<bool> deleteReview({
    required String reviewId,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/delete_review.php"),
      body: {
        "review_id": reviewId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }
}
