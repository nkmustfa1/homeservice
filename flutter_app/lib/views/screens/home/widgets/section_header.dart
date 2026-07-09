import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget nextScreen;

  const SectionHeader(
      {super.key, required this.title, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => nextScreen),
              );
            },
            child: const Text(
              "عرض الكل",
              style: TextStyle(color: Color(0xFF5464FD)),
            ),
          ),
        ],
      ),
    );
  }
}
