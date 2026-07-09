import 'package:flutter/material.dart';

import 'provider_image.dart';

class ProviderInfoSection extends StatelessWidget {
  final String providerImage;
  final String providerName;
  final double averageRating;
  final int totalReviewsCount;
  final String providerAddrress;
  final String experience;

  const ProviderInfoSection({
    super.key,
    required this.providerImage,
    required this.providerName,
    required this.averageRating,
    required this.totalReviewsCount,
    required this.providerAddrress,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProviderImage(base64String: providerImage),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(providerName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(averageRating.toStringAsFixed(1),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 12),
                      Text('$totalReviewsCount تقييم',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('الموقع: $providerAddrress',
                      style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text('الخبرة: $experience',
                      style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
