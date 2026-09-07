import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetsync/screen/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen renders email input and send OTP button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );

    // Verify title and prompt
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Reset Your Password'), findsOneWidget);
    expect(find.text('Send OTP Code'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
