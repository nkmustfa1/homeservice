import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:homeservice/core/storage/app_preferences.dart';
import 'package:homeservice/views/screens/provider/provider_details_screen.dart';

class AllProvidersScreen extends StatelessWidget {
  final List<dynamic> providers;

  const AllProvidersScreen({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getClientId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("كل مقدمي الخدمة"),
                backgroundColor: const Color(0xFF5464FD),
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("كل مقدمي الخدمة"),
                backgroundColor: const Color(0xFF5464FD),
              ),
              body: const Center(child: Text("لم يتم العثور على المعرف.")),
            ),
          );
        }

        final clientId = snapshot.data!;
        ImageProvider buildProviderImage(String? base64String) {
          if (base64String == null || base64String.isEmpty) {
            // لا توجد صورة، عرض افتراضي
            return const AssetImage('assets/images/services/default_image.png');
          } else {
            final prefix = "data:image";
            String pureBase64 = base64String;
            if (pureBase64.startsWith(prefix)) {
              final index = pureBase64.indexOf('base64,');
              if (index != -1) {
                pureBase64 = pureBase64.substring(index + 7);
              }
            }

            try {
              final decodedBytes = base64Decode(pureBase64);
              return MemoryImage(decodedBytes);
            } catch (e) {
              return const AssetImage(
                  'assets/images/services/default_image.png');
            }
          }
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("كل مقدمي الخدمة"),
              backgroundColor: const Color(0xFF5464FD),
            ),
            body: ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                var provider = providers[index];
                final providerId = provider['provider_id']?.toString() ?? '';
                final serviceId = provider['service_id']?.toString() ?? '';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage:
                          buildProviderImage(provider['provider_image'] ?? ""),
                    ),
                    title: Text(
                      provider['provider_name'] ?? "غير معروف",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider['service_name'] ?? "الخدمة غير محددة"),
                        const SizedBox(height: 4),
                        RatingBarIndicator(
                          rating: double.parse(
                              provider['average_rating'] ?? 0.0.toString()),
                          itemCount: 5,
                          itemSize: 18.0,
                          direction: Axis.horizontal,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.grey, size: 18),
                            const SizedBox(width: 4),
                            Text(provider['provider_addrress'] ?? "غير معروف"),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderDetailsScreen(
                            providerId: providerId,
                            serviceId: serviceId,
                            clientId: clientId.toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<int> _getClientId() async {
    return await AppPreferences.getUserId() ?? 0;
  }
}
