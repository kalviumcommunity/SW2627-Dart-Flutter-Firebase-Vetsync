import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsync/firebase_options.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/screen/main_navigation_screen.dart';
import 'package:vetsync/screen/login_screen.dart';
import 'package:vetsync/theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

/// Reactively listens to user authentication and registration changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // While Firebase is determining initial auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = authSnapshot.data;

        // If user is authenticated, verify their staff record exists in Firestore 'vets' collection
        if (user != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vets')
                .doc(user.uid)
                .snapshots(),
            builder: (context, vetSnapshot) {
              if (vetSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Only grant access if the doctor has a registered profile in Firestore
              if (vetSnapshot.hasData &&
                  vetSnapshot.data != null &&
                  vetSnapshot.data!.exists) {
                return const MainNavigationScreen();
              }

              // Otherwise, account is not registered as veterinary staff
              return const LoginScreen();
            },
          );
        }

        // Otherwise, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}

