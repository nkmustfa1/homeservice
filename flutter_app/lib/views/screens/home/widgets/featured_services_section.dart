import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:homeservice/core/storage/app_preferences.dart';
import 'package:homeservice/views/screens/home/screens/all_popular_services_screen.dart';
import 'package:homeservice/views/screens/provider/service_providers_screen.dart';

class FeaturedServicesSection extends StatelessWidget {
  final List<dynamic> popularServices;

  const FeaturedServicesSection({super.key, required this.popularServices});

  @override
  Widget build(BuildContext context) {
    final top3 = popularServices.take(5).toList();

    if (popularServices.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: const Text(
          "لا توجد خدمات مميزة حالياً",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("الخدمة المميزة", context),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: top3.length,
              itemBuilder: (context, index) {
                final service = top3[index];
                String serviceName = service['service_name'] ?? '';
                String? categoryName = service['category_name'] ?? 'غير محدد';
                String? categoryImage = service['category_icon'];

                return GestureDetector(
                  onTap: () async {
                    final clientId = await AppPreferences.getUserId();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProvidersScreen(
                          categoryId: service['category_id'].toString(),
                          categoryName: categoryName!,
                          clientId: clientId.toString(),
                          selectedServiceName: serviceName,
                          selectedServiceId: service['service_id'].toString(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: categoryImage?.isNotEmpty == true
                                ? _buildCategoryIcon(categoryImage)
                                : null),
                        const SizedBox(height: 5),
                        Text(
                          serviceName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String? base64Icon) {
    if (base64Icon == null || base64Icon.isEmpty) {
      return const Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
    try {
      Uint8List imageBytes = base64Decode(base64Icon);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllPopularServicesScreen(
                    allServices: popularServices,
                  ),
                ),
              );
            },
            child: const Text(
              "عرض الكل",
              style: TextStyle(color: Color(0xFF5464FD)),
            ),
          ),
        ],
      ),
    );
  }
}
