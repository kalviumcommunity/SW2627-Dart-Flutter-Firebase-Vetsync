import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/screen/home_screen.dart';
import 'package:vetsync/screen/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vetsync/firebase_options.dart';
// import 'package:vetsync/screen/signup_screen.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    
    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      return const HomeScreen();
    }

    return const LoginScreen();
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetSync',
      home: AuthWrapper(),
    );
  }
}
