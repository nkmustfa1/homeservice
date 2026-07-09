import 'package:flutter/material.dart';

class OrderMessageField extends StatelessWidget {
  final TextEditingController controller;

  const OrderMessageField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "الرسالة المخصصة",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "اكتب هنا...",
              border: InputBorder.none,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "*أضف أي أشياء إضافية قد ترغب في إحضارها.",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
