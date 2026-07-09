import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:homeservice/controllers/home_controller.dart';
import 'package:homeservice/core/storage/app_preferences.dart';
import 'package:homeservice/views/screens/home/screens/all_providers_screen.dart';
import 'package:homeservice/views/screens/provider/provider_details_screen.dart';

class ExpertServicerSection extends StatefulWidget {
  const ExpertServicerSection({super.key});

  @override
  _ExpertServicerSectionState createState() => _ExpertServicerSectionState();
}

class _ExpertServicerSectionState extends State<ExpertServicerSection> {
  List<dynamic> providers = [];
  int clientId = 0;
  final HomeController _controller = HomeController();
  @override
  void initState() {
    super.initState();
    _fetchTopProviders();
    _loadClientId();
  }

  Future<void> _loadClientId() async {
    final id = await AppPreferences.getUserId();

    setState(() {
      clientId = id ?? 0;
    });
  }

  Future<void> _fetchTopProviders() async {
    try {
      final data = await _controller.fetchTopProviders();

      if (data['success'] == true) {
        setState(() {
          providers = data['providers'];
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final limitedProviders = providers.take(3).toList();

    if (providers.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        child: const Center(child: Text("لا يوجد مزودو خدمة حالياً")),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("أفضل مقدمي الخدمة", context),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: limitedProviders.length,
            itemBuilder: (context, index) {
              var provider = limitedProviders[index];
              return _buildProviderCard(provider);
            },
          ),
        ],
      ),
    );
  }

  ImageProvider _buildProviderImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
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
        return const AssetImage('assets/images/services/default_image.png');
      }
    }
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
                _buildProviderImage(provider['provider_image'] ?? ""),
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
                    (provider['average_rating'] ?? 0.0.toString())),
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
                  const Icon(Icons.location_on, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(provider['provider_addrress'] ?? "غير معروف"),
                ],
              ),
            ],
          ),
          onTap: () {
            final providerId = provider['provider_id']?.toString() ?? '';
            final serviceId = provider['service_id']?.toString() ?? '';

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
      ),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllProvidersScreen(providers: providers),
              ),
            );
          },
          child: const Text(
            "عرض الكل",
            style: TextStyle(color: Color(0xFF5464FD)),
          ),
        ),
      ],
    );
  }
}
