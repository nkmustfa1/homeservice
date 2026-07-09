import 'dart:convert';

import 'package:flutter/material.dart';

class CategoryProviderCard extends StatelessWidget {
  final String providerName;
  final String providerAddress;
  final String serviceTitle;
  final String serviceDescription;
  final String providerImageBase64;
  final String formattedDistance;
  final double rating;
  final bool showServiceTitle;
  final bool showDistance;
  final VoidCallback onOrderPressed;

  const CategoryProviderCard({
    super.key,
    required this.providerName,
    required this.providerAddress,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.providerImageBase64,
    required this.formattedDistance,
    required this.rating,
    required this.showServiceTitle,
    required this.showDistance,
    required this.onOrderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryProviderImage(base64String: providerImageBase64),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (showDistance)
                          _CategoryDistanceTag(distance: formattedDistance),
                        _CategoryRating(rating: rating),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (showServiceTitle && serviceTitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          serviceTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        serviceDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      providerAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: onOrderPressed,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text("طلب"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryProviderImage extends StatelessWidget {
  final String base64String;

  const _CategoryProviderImage({required this.base64String});

  @override
  Widget build(BuildContext context) {
    if (base64String.isEmpty) {
      return _buildPlaceholder();
    }

    try {
      final decodedBytes = base64Decode(base64String);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          decodedBytes,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    } catch (e) {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
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

class _CategoryDistanceTag extends StatelessWidget {
  final String distance;

  const _CategoryDistanceTag({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        distance,
        style: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CategoryRating extends StatelessWidget {
  final double rating;

  const _CategoryRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
