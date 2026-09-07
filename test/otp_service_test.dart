import 'package:flutter_test/flutter_test.dart';
import 'package:vetsync/services/otp_service.dart';

void main() {
  group('OtpService Unit Tests', () {
    late OtpService otpService;

    setUp(() {
      otpService = OtpService();
    });

    test('generateOtp should produce a 6-digit numeric string', () {
      final otp = otpService.generateOtp();
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);
      expect(int.parse(otp), greaterThanOrEqualTo(100000));
      expect(int.parse(otp), lessThanOrEqualTo(999999));
    });

    test('Short or incomplete OTP should fail verification', () async {
      final result = await otpService.verifyOtp(
        email: 'doctor@vetclinic.com',
        otp: '123',
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('6-digit'));
    });

    test('Incorrect OTP should return failure error message', () async {
      final email = 'test_${DateTime.now().millisecondsSinceEpoch}@vet.com';
      await otpService.sendOtpToEmail(email);

      final result = await otpService.verifyOtp(
        email: email,
        otp: '000000', // incorrect OTP
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('Incorrect OTP'));
    });

    test('Password reset validation with short password should fail', () async {
      final result = await otpService.resetPassword(
        email: 'test@vet.com',
        newPassword: '123',
        resetToken: 'token_123',
      );
      expect(result.isSuccess, isFalse);
      expect(result.message, contains('at least 6 characters'));
    });
  });
}
