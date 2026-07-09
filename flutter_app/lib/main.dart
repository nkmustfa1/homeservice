import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/shared/splash_screen.dart';

void main() {
  runApp(HomeServicesApp());
}

class HomeServicesApp extends StatelessWidget {
  const HomeServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق الخدمات المنزلية',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // اختيار الخط الرئيسي
        fontFamily: 'Roboto',
      ),

      home: SplashScreen(), // شاشة السبلاش
    );
  }
}
