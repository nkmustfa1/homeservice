import 'package:flutter/material.dart';

class CategoryProvidersEmptyState extends StatelessWidget {
  const CategoryProvidersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "لا يوجد مزوّدون متاحون لهذه الخدمة.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
