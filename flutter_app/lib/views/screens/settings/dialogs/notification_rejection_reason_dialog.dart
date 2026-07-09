import 'package:flutter/material.dart';

class NotificationRejectionReasonDialog extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationRejectionReasonDialog({
    super.key,
    required this.notification,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              Text(
                "الطلب مرفوض",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                notification["service_name"] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "المزود: ${notification["provider_name"] ?? ""}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "سبب الرفض: ${notification['provider_reject_reason'] ?? 'لا يوجد سبب مسجل'}",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("إغلاق"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
