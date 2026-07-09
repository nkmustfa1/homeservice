import 'dart:convert';

import 'package:flutter/material.dart';

class ProviderImage extends StatelessWidget {
  final String base64String;

  const ProviderImage({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
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
}
