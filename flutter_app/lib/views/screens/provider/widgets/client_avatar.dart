import 'dart:convert';

import 'package:flutter/material.dart';

class ClientAvatar extends StatelessWidget {
  final String base64Image;

  const ClientAvatar({super.key, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    if (base64Image.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(Icons.person, color: Colors.blue),
      );
    } else {
      try {
        final decodedBytes = base64Decode(base64Image);
        return CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          backgroundImage: MemoryImage(decodedBytes),
        );
      } catch (e) {
        return CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue),
        );
      }
    }
  }
}
