import 'dart:math';
import 'package:flutter/material.dart';

import '../../../services/provider_service.dart';
import 'provider_details_screen.dart';
import '../auth/login_screen.dart';
import 'widgets/category_provider_card.dart';
import 'widgets/category_providers_empty_state.dart';
import 'widgets/category_service_tabs.dart';

class CategoryProvidersScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String clientId;
  final String selectedServiceName;
  final String selectedServiceId;

  const CategoryProvidersScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.clientId,
    required this.selectedServiceName,
    required this.selectedServiceId,
  });

  @override
  _CategoryProvidersScreenState createState() =>
      _CategoryProvidersScreenState();
}

class _CategoryProvidersScreenState extends State<CategoryProvidersScreen> {
  bool isLoadingServices = true;
  bool isLoadingProviders = true;
  late double latitude = 0.0; // تعيين قيمة افتراضية
  late double longitude = 0.0; // تعيين قيمة افتراضية

  List<dynamic> services = [];
  List<dynamic> providers = [];
  final ProviderService _providerService = ProviderService();
  String? selectedServiceId;
  String? selectedServiceName;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
    fetchClientLocation();
  }

  Future<void> fetchClientLocation() async {
    try {
      final data = await _providerService.fetchClientLocation(
        clientId: widget.clientId,
      );

      if (data['success'] == true) {
        latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
        longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
      } else {}
    } catch (e) {}
  }

  Future<void> _initializeData() async {
    if (widget.selectedServiceId.isNotEmpty &&
        widget.selectedServiceName.isNotEmpty) {
      selectedServiceId = widget.selectedServiceId;
      selectedServiceName = widget.selectedServiceName;
    } else {
      selectedServiceId = '';
      selectedServiceName = '';
    }

    fetchServicesForCategory();
  }

  Future<void> fetchServicesForCategory() async {
    setState(() {
      isLoadingServices = true;
    });

    try {
      final data = await _providerService.fetchServicesForCategory(
        categoryId: widget.categoryId,
      );

      if (data['success'] == true && data['services'] != null) {
        services = data['services'];

        services.insert(0, {
          'id': '',
          'service_name': 'الكل',
        });

        if (selectedServiceId == null || selectedServiceId!.isEmpty) {
          selectedServiceId = '';
          selectedServiceName = 'الكل';
        }

        fetchProvidersForService();
      } else {}
    } catch (e) {}

    setState(() {
      isLoadingServices = false;
    });
  }

  Future<void> fetchProvidersForService() async {
    if (selectedServiceId == null) return;

    setState(() {
      isLoadingProviders = true;
      providers.clear();
    });

    try {
      final data = await _providerService.fetchProviders(
        categoryId: widget.categoryId,
        serviceId: selectedServiceId,
      );

      if (data['success'] == true) {
        if (data['success'] == true && data['providers'] != null) {
          List<dynamic> fetchedProviders = data['providers'];

          for (var provider in fetchedProviders) {
            final providerLatitude =
                double.tryParse(provider['latitude']?.toString() ?? '0.0') ??
                    0.0;
            final providerLongitude =
                double.tryParse(provider['longitude']?.toString() ?? '0.0') ??
                    0.0;

            bool invalidCoordinates = (latitude == 0.0 ||
                longitude == 0.0 ||
                providerLatitude == 0.0 ||
                providerLongitude == 0.0);

            if (invalidCoordinates) {
              provider['distance'] = 999999999.0;
            } else {
              double dist = calculateDistance(
                  latitude, longitude, providerLatitude, providerLongitude);
              provider['distance'] = dist;
            }
          }

          fetchedProviders.sort((a, b) {
            final distA = a['distance'] as double;
            final distB = b['distance'] as double;
            return distA.compareTo(distB);
          });

          setState(() {
            providers = fetchedProviders;
          });
        } else {
          setState(() {
            providers = [];
          });
        }
      }
    } catch (e) {}

    setState(() {
      isLoadingProviders = false;
    });
  }

  List<dynamic> get filteredProviders {
    if (searchQuery.isEmpty) return providers;
    return providers.where((prov) {
      final name = prov['provider_name']?.toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildServicesTabs() {
    return CategoryServiceTabs(
      services: services,
      selectedServiceId: selectedServiceId,
      onServiceSelected: (srv) {
        setState(() {
          selectedServiceId = srv['id'].toString();
          selectedServiceName = srv['service_name'];
        });
        fetchProvidersForService();
      },
    );
  }

  Widget _buildProvidersList() {
    if (filteredProviders.isEmpty) {
      return const CategoryProvidersEmptyState();
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = filteredProviders[index];
        return _buildProviderCard(provider);
      },
    );
  }

  double calculateDistance(double clientLat, double clientLon,
      double providerLat, double providerLon) {
    const double radius = 6371; // Radius of Earth in km

    double dLat = (providerLat - clientLat) * (pi / 180.0);
    double dLon = (providerLon - clientLon) * (pi / 180.0);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(clientLat * (pi / 180.0)) *
            cos(providerLat * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c; // Distance in kilometers
  }

  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      int distanceInMeters = (distanceInKm * 1000).round();
      return "$distanceInMeters م";
    } else {
      int distanceInKilometers = distanceInKm.round();
      return "$distanceInKilometers كم";
    }
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final providerName = provider['provider_name'] ?? 'Unknown';
    final provideraddrress = provider['provider_addrress'] ?? 'Unknown';

    final rating =
        double.tryParse(provider['average_rating']?.toString() ?? '0') ?? 0.0;
    final serviceTitle = provider['service_name'] ?? '';
    final serviceDescription =
        provider['service_description'] ?? 'وصف الخدمة غير متاح';

    final providerLatitude =
        double.tryParse(provider['latitude']?.toString() ?? '0.0') ?? 0.0;
    final providerLongitude =
        double.tryParse(provider['longitude']?.toString() ?? '0.0') ?? 0.0;

    final clientLatitude = latitude;
    final clientLongitude = longitude;
    final base64String = provider['provider_image'] ?? '';
    final distance = calculateDistance(
        clientLatitude, clientLongitude, providerLatitude, providerLongitude);
    final formattedDistance = formatDistance(distance);
    bool invalidCoordinates = (clientLatitude == 0.0 ||
        clientLongitude == 0.0 ||
        providerLatitude == 0.0 ||
        providerLongitude == 0.0);
    return CategoryProviderCard(
      providerName: providerName,
      providerAddress: provideraddrress,
      serviceTitle: serviceTitle,
      serviceDescription: serviceDescription,
      providerImageBase64: base64String,
      formattedDistance: formattedDistance,
      rating: rating,
      showServiceTitle: selectedServiceId == '',
      showDistance: !invalidCoordinates,
      onOrderPressed: () {
        if (widget.clientId.isEmpty ||
            widget.clientId == 0.toString() ||
            widget.clientId == 'null') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailsScreen(
                providerId: provider['provider_id'].toString(),
                serviceId: provider['service_id'].toString(),
                clientId: widget.clientId,
              ),
            ),
          );
        }
      },
    );
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
          title: Text(
            widget.categoryName,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "ابحث عن مزوّد",
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            if (isLoadingServices)
              Center(child: CircularProgressIndicator())
            else
              _buildServicesTabs(),
            Expanded(
              child: isLoadingProviders
                  ? Center(child: CircularProgressIndicator())
                  : _buildProvidersList(),
            ),
          ],
        ),
      ),
    );
  }
}
