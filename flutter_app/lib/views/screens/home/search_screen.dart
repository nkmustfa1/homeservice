import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/service_model.dart';
import '../../../services/provider_service.dart';
import '../provider/provider_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<ServiceModel>>? _searchResult;
  Timer? _debounce;
  final ProviderService _providerService = ProviderService();
  Future<List<ServiceModel>> _fetchServices({String? search}) async {
    return _providerService.searchServices(
      search: search,
    );
  }

  Widget _buildInitialSearchUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الصورة
          Image.asset(
            'assets/images/empty_states/no_results.png',
            width: 300,
            height: 300,
          ),
          SizedBox(height: 24),
          Text(
            'لم تقم بأي بحث بعد!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابدأ بالبحث عن الخدمة المناسبة لجعل منزلك أفضل.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_states/no_results.png',
            width: 300,
            height: 300,
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد نتائج مطابقة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'حاول البحث مرة أخرى بكلمات أكثر عمومية.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _searchResult = q.trim().isEmpty ? null : _fetchServices(search: q);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "البحث",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "ابحث هنا",
                          border: InputBorder.none,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(height: 10),
              Expanded(
                child: _searchResult == null
                    ? _buildInitialSearchUI()
                    : FutureBuilder<List<ServiceModel>>(
                        future: _searchResult,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('خطأ: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return _buildNoResults();
                          } else {
                            final services = snapshot.data!;
                            return ListView.builder(
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final service = services[index];
                                return _buildServiceCard(
                                  context,
                                  service.userName,
                                  service.userImage,
                                  service.rating,
                                  service.serviceTitle,
                                  service.price,
                                  service.originalPrice,
                                  service.discount,
                                  service.serviceImage,
                                  service.time,
                                  service.minStaff,
                                  service.description,
                                  service.id,
                                  service.servceid,
                                  service.categoryName,
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context,
      String userName,
      String userImage,
      double rating,
      String serviceTitle,
      String price,
      String? originalPrice,
      String? discount,
      String serviceImage,
      String time,
      String minStaff,
      String description,
      int providerId,
      int serviceId,
      String categoryName) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final String userId = prefs.getInt('userId')?.toString() ?? '';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderDetailsScreen(
              providerId: providerId.toString(),
              serviceId: serviceId.toString(),
              clientId: userId,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  _buildUserImage(userImage),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      userName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCategoryImage(categoryName),
                ),
                if (discount != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discount,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (originalPrice != null)
                            Text(
                              originalPrice,
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                              ),
                            ),
                          SizedBox(width: 5),
                          Text(
                            price,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green, size: 16),
                      SizedBox(width: 5),
                      Text(time),
                      SizedBox(width: 15),
                      Text(
                        minStaff,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String categoryName) {
    String imagePath = getCategoryImage(categoryName);
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: 150,
      fit: BoxFit.cover,
    );
  }

  Widget _buildUserImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.blue.shade50,
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            decodedBytes,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 70,
                height: 70,
                color: Colors.blue.shade50,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
          ),
        );
      } catch (e) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 70,
            height: 70,
            color: Colors.blue.shade50,
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 40,
            ),
          ),
        );
      }
    }
  }

  String getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'تنظيف':
        return 'assets/images/services/cleaning_image.png';
      case 'سباكة':
        return 'assets/images/services/plumbing_image.png';
      case 'كهرباء':
        return 'assets/images/services/electrical_image.png';
      case 'طلاء':
        return 'assets/images/services/painter.jpg';
      case 'نقل':
        return 'assets/images/services/movement.jpeg';
      case 'نجارة':
        return 'assets/images/services/carpenter.jpg';
      case 'صيانة اجهزة':
        return 'assets/images/services/ac.jpg';
      case 'صالون':
        return 'assets/images/services/salon.jpg';
      case 'طبخ':
        return 'assets/images/services/cooking.jpeg';
      default:
        return 'assets/images/services/default_image.png';
    }
  }
}
