import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsync/services/otp_service.dart';

/// Service responsible for managing all authentication operations in VetSync.
class AuthService {
  final FirebaseAuth? _customAuth;
  final OtpService _otpService;

  AuthService({
    FirebaseAuth? auth,
    OtpService? otpService,
  })  : _customAuth = auth,
        _otpService = otpService ?? OtpService();

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

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

