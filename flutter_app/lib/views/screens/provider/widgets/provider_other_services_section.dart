import 'package:flutter/material.dart';

import '../../../../core/utils/category_image_helper.dart';
import '../provider_details_screen.dart';

class ProviderOtherServicesSection extends StatelessWidget {
  final List<dynamic> otherServices;
  final String providerId;
  final String clientId;

  const ProviderOtherServicesSection({
    super.key,
    required this.otherServices,
    required this.providerId,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "خدمات أخرى مقدّمة",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        if (otherServices.isEmpty)
          Text(
            "لا توجد خدمات إضافية.",
            style: TextStyle(color: Colors.grey[600]),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: otherServices.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final srv = otherServices[index];
                final srvName = srv['service_name'] ?? '';
                final srvDescription = srv['service_description'] ?? '';
                final serviceId = srv['service_id'].toString();
                final catName = srv['category_name'] ?? '';
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderDetailsScreen(
                          providerId: providerId,
                          clientId: clientId,
                          serviceId: serviceId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.asset(
                            getCategoryImage(catName),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            srvName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            srvDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
