import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsync/services/otp_service.dart';

/// Service responsible for managing all authentication operations in VetSync.
class AuthService {
  final FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final OtpService _otpService;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    OtpService? otpService,
  })  : _customAuth = auth,
        _customFirestore = firestore,
        _otpService = otpService ?? OtpService();

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;

  /// Stream of authentication state changes.
  /// Emits [User] when logged in, and [null] when logged out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently logged in user (synchronous snapshot).
  User? get currentUser => _auth.currentUser;

  /// Checks whether a veterinary staff profile exists for the given [uid] in Firestore.
  Future<bool> isVetRegistered(String uid) async {
    try {
      final doc = await _firestore.collection('vets').doc(uid).get();
      return doc.exists;
    } catch (_) {
      // In offline/test conditions where Firestore might be mocked
      return false;
    }
  }

  /// Fetches the veterinary staff profile document for the given [uid].
  Future<Map<String, dynamic>?> getVetProfile(String uid) async {
    try {
      final doc = await _firestore.collection('vets').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

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

  /// Ensures that a veterinary staff profile exists in Firestore for the given user.
  Future<void> ensureVetProfile(User user) async {
    try {
      final doc = await _firestore.collection('vets').doc(user.uid).get();
      if (!doc.exists) {
        String name = user.displayName ?? '';
        if (name.isEmpty && user.email != null && user.email!.contains('@')) {
          name = user.email!.split('@').first;
          if (name.isNotEmpty) {
            name = name[0].toUpperCase() + name.substring(1);
          }
        }
        if (name.isEmpty) name = 'Doctor';

        await _firestore.collection('vets').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': user.email ?? '',
          'branchID': 'BRANCH_DELHI',
          'branchName': 'Delhi Central Clinic',
          'role': 'veterinarian',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // In offline/test conditions where Firestore might be mocked, ignore
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
      if (credential.user != null) {
        await ensureVetProfile(credential.user!);
      }
      return credential;
    } on FirebaseAuthException {
      // Rethrow to let the UI layer handle user-friendly messages
      rethrow;
    }
  }

  /// Sends a 6-digit OTP to the user's email for password reset.
  Future<OtpResult> sendPasswordResetOtp(String email) async {
    return await _otpService.sendOtpToEmail(email);
  }

  /// Verifies the OTP code submitted by the user.
  Future<OtpResult> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    return await _otpService.verifyOtp(email: email, otp: otp);
  }

  /// Updates/resets the user password following successful OTP verification.
  Future<OtpResult> resetPasswordWithOtp({
    required String email,
    required String newPassword,
    required String resetToken,
  }) async {
    return await _otpService.resetPassword(
      email: email,
      newPassword: newPassword,
      resetToken: resetToken,
    );
  }

  /// Signs out the current user session.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}


