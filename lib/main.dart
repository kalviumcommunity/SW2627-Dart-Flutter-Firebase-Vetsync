import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsync/firebase_options.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/screen/home_screen.dart';
import 'package:vetsync/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

/// Root widget of VetSync
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Reactively listens to user authentication changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While Firebase is determining initial auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated, direct to HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Otherwise, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}

