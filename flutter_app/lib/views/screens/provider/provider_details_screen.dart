import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/utils/category_image_helper.dart';
import '../auth/login_screen.dart';
import '../booking/order_screen.dart';
import 'dart:ui' as ui show TextDirection;
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/provider_service.dart';
import 'widgets/provider_info_section.dart';
import 'widgets/provider_other_services_section.dart';
import 'widgets/provider_reviews_section.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  final String? serviceId;
  final String clientId;
  const ProviderDetailsScreen({
    super.key,
    required this.providerId,
    required this.clientId,
    this.serviceId,
  });

  @override
  _ProviderDetailsScreenState createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  bool isLoading = true;
  bool isFavorite = false;
  bool showAllReviews = false;
  String providerName = '';
  String providerImage = '';
  double averageRating = 0.0;
  String serviceName = '';
  String categoryName = '';
  String serviceDescription = '';
  String experience = '';
  String providerAddrress = '';
  int totalReviewsCount = 0;
  final ProviderService _providerService = ProviderService();
  List<dynamic> reviews = [];

  List<dynamic> otherServices = [];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    _loadFavoriteState();

    fetchProviderDetails();
  }

  Future<void> _loadFavoriteState() async {
    final favState = await AppPreferences.getFavoriteState(
      clientId: widget.clientId,
      providerId: widget.providerId,
      serviceId: widget.serviceId,
    );

    if (favState != null) {
      setState(() {
        isFavorite = favState;
      });
    }
  }

  int? givenServiceId;

  Future<void> fetchProviderDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _providerService.fetchProviderDetails(
        providerId: widget.providerId,
        serviceId: widget.serviceId,
      );

      if (data['success'] == true) {
        final providerData = data['provider_details'];

        setState(() {
          providerName = providerData['provider_name'] ?? '';
          providerImage = providerData['provider_image'] ?? '';
          serviceName = providerData['service_name'] ?? '';
          categoryName = providerData['category_name'] ?? '';
          serviceDescription = providerData['service_description'] ?? '';
          experience = providerData['service_experties'] ?? '';
          providerAddrress = providerData['provider_addrress'] ?? '';

          averageRating = double.tryParse(
                  providerData['average_rating']?.toString() ?? '0') ??
              0.0;

          totalReviewsCount =
              int.tryParse(providerData['total_reviews']?.toString() ?? '0') ??
                  0;

          givenServiceId =
              int.tryParse(providerData['given_service_id']?.toString() ?? '');

          reviews = data['reviews'] ?? [];
          otherServices = data['other_services'] ?? [];
        });
      } else {}
    } catch (e) {}

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> addFavorite() async {
    try {
      final providerServiceId = givenServiceId?.toString() ?? '';

      if (providerServiceId.isEmpty) {
        return false;
      }

      final success = await _providerService.addFavorite(
        clientId: widget.clientId,
        providerServiceId: providerServiceId,
      );

      if (success) {
        await AppPreferences.setFavoriteState(
          clientId: widget.clientId,
          providerId: widget.providerId,
          serviceId: widget.serviceId,
          isFavorite: true,
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite() async {
    try {
      final providerServiceId = givenServiceId?.toString() ?? '';

      if (providerServiceId.isEmpty) {
        return false;
      }

      final success = await _providerService.removeFavorite(
        clientId: widget.clientId,
        providerServiceId: providerServiceId,
      );

      if (success) {
        await AppPreferences.setFavoriteState(
          clientId: widget.clientId,
          providerId: widget.providerId,
          serviceId: widget.serviceId,
          isFavorite: false,
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    expandedHeight: 250,
                    pinned: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          String? clientId = prefs.getInt('userId').toString();

                          if (clientId == 'null' || clientId.isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          } else {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                            bool success;
                            if (isFavorite) {
                              success = await addFavorite();
                            } else {
                              success = await removeFavorite();
                            }
                            if (!success) {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("حدث خطأ أثناء تحديث المفضلة.")),
                              );
                            }
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        getCategoryImage(categoryName),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName.isNotEmpty ? serviceName : 'اسم الخدمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          // الفئة
                          Row(
                            children: [
                              Text(
                                "الفئة: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                categoryName.isNotEmpty
                                    ? categoryName
                                    : 'اسم الفئة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "الوصف: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  serviceDescription.isNotEmpty
                                      ? serviceDescription
                                      : 'لا يوجد وصف',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          ProviderInfoSection(
                            providerImage: providerImage,
                            providerName: providerName,
                            averageRating: averageRating,
                            totalReviewsCount: totalReviewsCount,
                            providerAddrress: providerAddrress,
                            experience: experience,
                          ),
                          SizedBox(height: 16),
                          ProviderReviewsSection(
                            reviews: reviews,
                            showAllReviews: showAllReviews,
                            averageRating: averageRating,
                            totalReviewsCount: totalReviewsCount,
                            clientId: widget.clientId,
                            providerId: widget.providerId,
                            serviceId: widget.serviceId,
                            onReviewChanged: fetchProviderDetails,
                          ),
                          SizedBox(height: 16),
                          if (otherServices.isNotEmpty) ...[
                            ProviderOtherServicesSection(
                              otherServices: otherServices,
                              providerId: widget.providerId,
                              clientId: widget.clientId,
                            ),
                            SizedBox(height: 20),
                          ],

                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  String? clientId =
                                      prefs.getInt('userId').toString();
                                  if (clientId == 'null' || clientId.isEmpty) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderScreen(
                                          clientId: widget.clientId,
                                          providerId: widget.providerId,
                                          serviceId: widget.serviceId!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text("طلب الآن"),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
