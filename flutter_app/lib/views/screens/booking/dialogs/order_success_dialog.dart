import 'package:flutter/material.dart';

import '../booking_screen.dart';

class OrderSuccessDialog extends StatelessWidget {
  final String clientId;

  const OrderSuccessDialog({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Color(0xFF5464FD),
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            "تم الحجز بنجاح",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "تم تأكيد حجزك. يمكنك التحقق من الحالة في قائمة الحجوزات.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    userId: clientId,
                    isLoggedIn: true,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text("انتقل إلى قائمة الحجوزات"),
          ),
        ],
      ),
    );
  }
}
