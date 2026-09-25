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
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  // Bumping this forces the inner Firestore StreamBuilder to resubscribe,
  // used to let the user manually retry after an error.
  int _retryToken = 0;

  void _retry() {
    setState(() {
      _retryToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        // While Firebase is determining initial auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;

        // Not authenticated at all: show LoginScreen
        if (user == null) {
          return const LoginScreen();
        }

        // User is authenticated, verify their staff record exists in the
        // Firestore 'vets' collection.
        return StreamBuilder<DocumentSnapshot>(
          key: ValueKey('${user.uid}_$_retryToken'),
          stream: FirebaseFirestore.instance
              .collection('vets')
              .doc(user.uid)
              .snapshots(),
          builder: (context, vetSnapshot) {
            if (vetSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            // Missing error boundary fix: surface Firestore/network errors
            // instead of silently falling back to LoginScreen.
            if (vetSnapshot.hasError) {
              return _AuthErrorScreen(
                message: vetSnapshot.error.toString(),
                onRetry: _retry,
                onSignOut: () => _authService.signOut(),
              );
            }

            // Grant access if the vet has a registered profile in Firestore
            if (vetSnapshot.hasData &&
                vetSnapshot.data != null &&
                vetSnapshot.data!.exists) {
              return const MainNavigationScreen();
            }

            // Registration race-condition fix:
            // authStateChanges() emits the new User the instant Firebase Auth
            // creates the account, which happens *before* SignupScreen has
            // finished writing the matching 'vets' document. Without this
            // branch, that split second reads as "authenticated but not
            // registered" and briefly rebuilds LoginScreen underneath
            // SignupScreen. Every legitimate signed-in user in this app is
            // expected to end up with a 'vets' document, so treat
            // "authenticated but no doc yet" as still provisioning and keep
            // showing a loading state instead of bouncing to LoginScreen.
            return const _LoadingScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _AuthErrorScreen({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Could not load your staff profile.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onSignOut,
                    child: const Text('Sign Out'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}