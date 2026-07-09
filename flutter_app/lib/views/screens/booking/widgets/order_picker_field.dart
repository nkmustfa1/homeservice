import 'package:flutter/material.dart';

class OrderPickerField extends StatelessWidget {
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const OrderPickerField({
    super.key,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
            Icon(icon, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
