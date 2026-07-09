import 'package:flutter/material.dart';

class NotificationPaymentDialog extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onReviewPressed;

  const NotificationPaymentDialog({
    super.key,
    required this.notification,
    required this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt_sharp, size: 60, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                notification["service_name"] ?? "تم الدفع",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "لقد تم الدفع واكتمل الطلب بنجاح. هل تريد تقييم التجربة؟",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onReviewPressed,
                child: Text("تقييم"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
