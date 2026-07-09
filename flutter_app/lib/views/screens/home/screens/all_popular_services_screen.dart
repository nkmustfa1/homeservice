import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:homeservice/core/storage/app_preferences.dart';
import 'package:homeservice/views/screens/provider/service_providers_screen.dart';

class AllPopularServicesScreen extends StatelessWidget {
  final List<dynamic> allServices;

  const AllPopularServicesScreen({super.key, required this.allServices});

  @override
  Widget build(BuildContext context) {
    if (allServices.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("الخدمات المميزة"),
            backgroundColor: const Color(0xFF5464FD),
          ),
          body: const Center(
            child: Text("لا توجد خدمات مميزة حالياً"),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("جميع الخدمات المميزة"),
          backgroundColor: const Color(0xFF5464FD),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: allServices.length,
            itemBuilder: (context, index) {
              final service = allServices[index];
              String serviceName = service['service_name'] ?? '';
              String? base64Icon = service['category_icon'];
              String? categoryName = service['category_name'] ?? 'غير محدد';

              return GestureDetector(
                onTap: () async {
                  final clientId =
                      (await AppPreferences.getUserId()).toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProvidersScreen(
                        categoryId: service['category_id'].toString(),
                        categoryName: categoryName!,
                        clientId: clientId,
                        selectedServiceName: serviceName,
                        selectedServiceId: service['service_id'].toString(),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildCategoryIcon(base64Icon),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      serviceName,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
}
