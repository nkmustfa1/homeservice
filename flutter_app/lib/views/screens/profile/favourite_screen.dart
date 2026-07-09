import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/storage/app_preferences.dart';
import '../../../services/provider_service.dart';
import '../provider/provider_details_screen.dart';

class FavouriteScreen extends StatefulWidget {
  final String clientId;

  const FavouriteScreen({super.key, required this.clientId});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  bool isLoading = true;
  List<dynamic> favorites = [];
  final ProviderService _providerService = ProviderService();

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _providerService.fetchFavorites(
        clientId: widget.clientId,
      );

      if (data['success'] == true) {
        setState(() {
          favorites = data['favorites'] ?? [];
        });
      } else {}
    } catch (e) {}

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeFavorite(int index) async {
    try {
      final fav = favorites[index];
      final providerServiceId = fav['provider_service_id']?.toString() ?? '';

      if (providerServiceId.isEmpty) {
        return;
      }

      final success = await _providerService.removeFavorite(
        clientId: widget.clientId,
        providerServiceId: providerServiceId,
      );

      if (success) {
        await AppPreferences.setFavoriteState(
          clientId: widget.clientId,
          providerId: fav['provider_id'].toString(),
          serviceId: fav['service_id'].toString(),
          isFavorite: false,
        );

        setState(() {
          favorites.removeAt(index);
        });
      }
    } catch (e) {}
  }

  Widget _buildProviderImage(String base64String) {
    if (base64String.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
      try {
        final decodedBytes = base64Decode(base64String);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "قائمة المفضلة",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                final providerName = fav['provider_name'] ?? '';
                final serviceName = fav['service_name'] ?? '';
                final serviceDescription = fav['service_description'] ?? '';
                final rating =
                    double.tryParse(fav['average_rating']?.toString() ?? '0') ??
                        0.0;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderDetailsScreen(
                          providerId: fav['provider_id'].toString(),
                          clientId: widget.clientId,
                          serviceId: fav['service_id']?.toString() ?? '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              removeFavorite(index);
                            },
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  providerName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "الخدمة: $serviceName",
                                  style: TextStyle(
                                      color: Colors.blueGrey, fontSize: 12),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  serviceDescription,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.yellow, size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            child: _buildProviderImage(
                                fav['provider_image'] ?? ''),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
