import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const InternEduApp());
}

class InternEduApp extends StatelessWidget {
  const InternEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Edu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const SplashScreen(),
    );
  }
}
