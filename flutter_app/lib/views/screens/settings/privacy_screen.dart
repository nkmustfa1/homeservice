import 'package:flutter/material.dart';

import 'widgets/privacy_card_content.dart';
import 'widgets/privacy_section.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سياسة الخصوصية'),
        backgroundColor: Colors.blue,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا في سياسة الخصوصية الخاصة بنا!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),

              // مقدمة
              PrivacyCardContent(
                text:
                    'نحن نحترم خصوصيتك ونلتزم بحمايتها. في هذه الصفحة، نوضح كيف نجمع ونستخدم معلوماتك الشخصية.',
              ),
              SizedBox(height: 20),

              PrivacySection(
                title: '1. المعلومات التي نقوم بجمعها',
                content:
                    'نقوم بجمع البيانات التالية: اسم المستخدم، البريد الإلكتروني، الموقع الجغرافي، والمزيد.',
              ),
              SizedBox(height: 20),

              PrivacySection(
                title: '2. كيف نستخدم بياناتك',
                content:
                    'نستخدم بياناتك لتحسين تجربتك في التطبيق، وتوفير خدمات مخصصة لك بناءً على اهتماماتك.',
              ),
              SizedBox(height: 20),

              PrivacySection(
                title: '3. كيف نحمي بياناتك',
                content:
                    'نحن نستخدم تقنيات أمان لحماية بياناتك من الوصول غير المصرح به.',
              ),
              SizedBox(height: 20),

              PrivacySection(
                title: '4. تحديثات السياسة',
                content:
                    'قد نقوم بتحديث هذه السياسة من وقت لآخر، لذا ننصحك بمراجعتها بشكل دوري.',
              ),
              SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'موافق',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
