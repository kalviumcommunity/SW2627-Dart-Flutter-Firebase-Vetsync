import 'package:flutter/material.dart';
import 'package:vetsync/screen/signup_screen.dart';
// import 'package:vetsync/screen/home_screen.dart';
// import 'package:vetsync/screen/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetSync',
      home: SignupScreen(),
    );
  }
}
