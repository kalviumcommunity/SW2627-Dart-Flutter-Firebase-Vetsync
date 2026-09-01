import 'package:firebase_auth/firebase_auth.dart';

/// Service responsible for managing all authentication operations in VetSync.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes.
  /// Emits [User] when logged in, and [null] when logged out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently logged in user (synchronous snapshot).
  User? get currentUser => _auth.currentUser;

  /// Registers a new veterinary staff member with email and password.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException {
      // Rethrow to let the UI layer handle user-friendly messages
      rethrow;
    }
  }

  /// Signs in an existing veterinary staff member with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException {
      // Rethrow to let the UI layer handle user-friendly messages
      rethrow;
    }
  }

  /// Signs out the current user session.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
