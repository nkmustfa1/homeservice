import 'package:flutter/material.dart';

class ContactSuccessDialog extends StatelessWidget {
  const ContactSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("نجاح"),
      content: Text("تم إرسال المشكلة بنجاح."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("موافق"),
        ),
      ],
    );
  }
}
