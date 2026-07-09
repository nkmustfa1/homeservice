class ServiceModel {
  final int id;
  final String userName;
  final double rating;
  final String serviceTitle;
  final String description;
  final String userImage;
  final String price;
  final String? originalPrice;
  final String? discount;
  final String serviceImage;
  final String time;
  final String minStaff;
  final int servceid;
  final String categoryName;

  ServiceModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.serviceTitle,
    required this.description,
    required this.categoryName,
    this.userImage = '',
    this.price = '',
    this.originalPrice,
    this.discount,
    this.serviceImage = '',
    this.time = '',
    this.minStaff = '',
    required this.servceid,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['provider_id'] ?? 0,
      userName: json['provider_name'] ?? '',
      rating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      serviceTitle: json['service_name'] ?? '',
      description: json['service_description'] ?? '',
      userImage: json['provider_image'] ?? '',
      price: '',
      originalPrice: null,
      discount: null,
      serviceImage: '',
      time: '',
      minStaff: '',
      servceid: json['service_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
    );
  }
}
