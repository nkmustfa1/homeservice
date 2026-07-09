/// نموذج الطلب
class OrderModel {
  final int orderId;
  final int? providerConfirm;
  final int? clientConfirm;
  final int? paymentStatus;
  final String serviceName;
  final String categoryName;
  final int price;
  final DateTime orderDate;
  final String? orderTime;
  final String? orderDetails;
  final String? providerName;
  final double? providerRating;
  final String? providerImage;
  final String? providerRejectReason;
  final String? clientRejectReason;

  OrderModel({
    required this.orderId,
    this.providerConfirm,
    this.clientConfirm,
    this.paymentStatus,
    required this.serviceName,
    required this.categoryName,
    required this.price,
    required this.orderDate,
    this.orderTime,
    this.orderDetails,
    this.providerName,
    this.providerRating,
    this.providerRejectReason,
    this.clientRejectReason,
    this.providerImage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json["order_id"] ?? 0,
      providerConfirm: json["provider_confirm"],
      clientConfirm: json["client_confirm"],
      paymentStatus: json["Payment_status"],
      serviceName: json["service_name"] ?? "",
      categoryName: json["category_name"] ?? "",
      price: (json["price"] as num).toInt(),
      orderDate: DateTime.parse(json["order_date"]),
      orderTime: json["order_time"],
      orderDetails: json["order_details"],
      providerName: json["provider_name"],
      providerRating: json["provider_rating"] == null
          ? null
          : (json["provider_rating"] as num).toDouble(),
      providerRejectReason: json["provider_reject_reason"],
      clientRejectReason: json["client_reject_reason"],
      providerImage: json["provider_image"],
    );
  }
}
