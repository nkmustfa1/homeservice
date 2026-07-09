import 'package:flutter/material.dart';

class ContactErrorOption extends StatelessWidget {
  final String text;
  final String? selectedError;
  final VoidCallback onTap;

  const ContactErrorOption({
    super.key,
    required this.text,
    required this.selectedError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = selectedError == text;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Color(0xFF5464FD) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
