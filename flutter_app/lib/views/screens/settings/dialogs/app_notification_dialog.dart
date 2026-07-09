import 'package:flutter/material.dart';

class AppNotificationDialog extends StatelessWidget {
  final Map<String, dynamic> notification;

  const AppNotificationDialog({super.key, required this.notification});

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
              Icon(Icons.info_outline, size: 60, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                notification["notification_title"] ?? "لا يوجد نص للإشعار",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                notification["notification_text"] ?? "لا يوجد نص للإشعار",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
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
