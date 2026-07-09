import 'package:flutter/material.dart';

class CategoryServiceTabs extends StatelessWidget {
  final List<dynamic> services;
  final String? selectedServiceId;
  final ValueChanged<dynamic> onServiceSelected;

  const CategoryServiceTabs({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("لا توجد خدمات فرعية متاحة."),
      );
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final srv = services[index];
          final isSelected = srv['id'].toString() == selectedServiceId;
          return GestureDetector(
            onTap: () => onServiceSelected(srv),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                srv['service_name'] ?? '',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
