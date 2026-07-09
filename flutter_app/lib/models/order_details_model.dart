class OrderDetailsModel {
  final int orderId;
  final String serviceName;
  final String orderDate;
  final String orderTime;
  final String clientAddress;
  final String categoryName;
  final String serviceDescription;
  final int price;
  final String providerName;
  final String providerExperience;
  final String providerEmail;
  final String providerImage;
  final double averageRating;
  final String providerPhone;
  final String providerAddress;
  final String problemPhoto;
  final String serviceReplayDetails;
  final String orderDetails;
  final bool isRejected;
  final String providerRejectReason;
  final String clientRejectReason;

  final List<ReviewModel> reviews;

  OrderDetailsModel({
    required this.orderId,
    required this.serviceName,
    required this.orderDate,
    required this.orderTime,
    required this.clientAddress,
    required this.categoryName,
    required this.serviceDescription,
    required this.providerName,
    required this.providerExperience,
    required this.providerEmail,
    required this.providerImage,
    required this.averageRating,
    required this.providerPhone,
    required this.providerAddress,
    required this.reviews,
    required this.problemPhoto,
    required this.serviceReplayDetails,
    required this.orderDetails,
    required this.isRejected,
    required this.providerRejectReason,
    required this.clientRejectReason,
    required this.price,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final reviewsJson = json["reviews"] as List? ?? [];
    return OrderDetailsModel(
      orderId: json["order_id"] ?? 0,
      serviceName: json["service_name"] ?? "",
      orderDate: json["order_date"] ?? "",
      orderTime: json["order_time"] ?? "",
      clientAddress: json["client_address"] ?? "",
      categoryName: json["category_name"] ?? "",
      serviceDescription: json["order_details"] ?? "",
      providerName: json["provider_name"] ?? "",
      providerExperience: json["service_experties"] ?? "",
      providerEmail: json["provider_email"] ?? "",
      providerImage: json["provider_image"] ?? "",
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0.0,
      providerPhone: json["provider_phone"] ?? "",
      providerAddress: json["provider_address"] ?? "",
      problemPhoto: json["problem_photo"] ?? "",
      serviceReplayDetails: json["service_replay_details"] ?? "",
      orderDetails: json["order_details"] ?? "",
      isRejected: json["is_rejected"] ?? false,
      providerRejectReason: json["provider_reject_reason"] ?? "",
      clientRejectReason: json["client_reject_reason"] ?? "",
      price: json["price"] ?? 0,
      reviews: reviewsJson.map((r) => ReviewModel.fromJson(r)).toList(),
    );
  }
}

class ReviewModel {
  final String reviewerName;
  final String comment;
  final double rating;

  ReviewModel({
    required this.reviewerName,
    required this.comment,
    required this.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewerName: json["reviewer_name"] ?? "",
      comment: json["comment"] ?? "",
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}
