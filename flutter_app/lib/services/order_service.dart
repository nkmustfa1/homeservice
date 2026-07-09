import '../models/order_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';
import '../models/order_details_model.dart';

class OrderService {
  Future<List<OrderModel>> fetchOrders(String userId) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/fetch_orders.php?user_id=$userId",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((orderJson) => OrderModel.fromJson(orderJson)).toList();
    } else {
      throw Exception('فشل في جلب الطلبات');
    }
  }

  static Future<OrderDetailsModel> fetchOrderDetails(int orderId) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/get_order_details.php?order_id=$orderId",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("فشل في جلب تفاصيل الطلب");
    }

    final data = jsonDecode(response.body);
    return OrderDetailsModel.fromJson(data);
  }

  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> bodyData,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/create_order.php"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create order");
    }

    return jsonDecode(response.body);
  }

  Future<bool> createOrderNotification({
    required dynamic orderId,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/create_notification.php"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "order_id": orderId,
      }),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }
}
