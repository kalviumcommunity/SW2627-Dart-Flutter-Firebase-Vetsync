import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/models/visit.dart';
import 'package:vetsync/services/visit_service.dart';
import 'package:vetsync/screen/forgot_password_screen.dart';
import 'package:vetsync/screen/branch_selection_screen.dart';
import 'package:vetsync/screen/login_screen.dart';
import 'package:vetsync/screen/signup_screen.dart';

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

  test('Branch model default branches are populated with full metadata', () {
    final branches = Branch.defaultBranches;
    expect(branches.isNotEmpty, true);
    expect(branches.length, greaterThanOrEqualTo(5));

    final delhiBranch = branches.firstWhere((b) => b.id == 'BRANCH_DELHI');
    expect(delhiBranch.name, 'Delhi Central Clinic');
    expect(delhiBranch.city, 'Delhi NCR');
    expect(delhiBranch.address.isNotEmpty, true);
    expect(delhiBranch.phone.isNotEmpty, true);
  });

  test('Branch serialization and deserialization works correctly', () {
    const branch = Branch(
      id: 'BRANCH_TEST',
      name: 'Test Animal Clinic',
      city: 'Test City',
      address: '123 Test Street',
      phone: '9999999999',
      operatingHours: '10:00 AM - 06:00 PM',
      isMainBranch: false,
    );

    final map = branch.toMap();
    expect(map['id'], 'BRANCH_TEST');
    expect(map['name'], 'Test Animal Clinic');
    expect(map['city'], 'Test City');

    final reconstructed = Branch.fromMap(map);
    expect(reconstructed.id, 'BRANCH_TEST');
    expect(reconstructed.name, 'Test Animal Clinic');
    expect(reconstructed.city, 'Test City');
  });

  test('Pet model retains branchId and branchName properly', () {
    const pet = Pet(
      id: 'pet_1',
      name: 'Buddy',
      species: 'Dog',
      breed: 'Golden Retriever',
      age: 4,
      ownerName: 'Alice',
      gender: 'Male',
      branchId: 'BRANCH_MUMBAI',
      branchName: 'Mumbai Pet Specialty Hospital',
    );

    final map = pet.toMap();
    expect(map['branchId'], 'BRANCH_MUMBAI');
    expect(map['branchName'], 'Mumbai Pet Specialty Hospital');
    expect(map['name'], 'Buddy');
  });

  test('Visit model retains branchId, branchName, and date properly', () {
    final visitDate = DateTime(2026, 9, 12, 14, 30);
    final visit = Visit(
      id: 'visit_1',
      petId: 'pet_1',
      branchId: 'BRANCH_BLR',
      branchName: 'Bengaluru Veterinary Care Center',
      vetId: 'vet_1',
      vetName: 'Dr. John Doe',
      date: visitDate,
      notes: 'Routine health checkup and vaccination.',
      medications: ['Amoxicillin 250mg'],
      vaccination: 'Rabies',
    );

    final map = visit.toMap();
    expect(map['branchId'], 'BRANCH_BLR');
    expect(map['branchName'], 'Bengaluru Veterinary Care Center');
    expect(map['vetName'], 'Dr. John Doe');
    expect(map['vaccination'], 'Rabies');
  });

  testWidgets('BranchSelectionScreen renders search and city filter chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BranchSelectionScreen(
          currentBranchId: 'BRANCH_DELHI',
          returnSelectedOnly: true,
          customBranchStream: Stream.value(Branch.defaultBranches),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Clinic Branches'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Delhi Central Clinic'), findsOneWidget);
  });

  test('VisitService evaluateSafetyFlags detects overdue follow-ups and <14d medications', () {
    final visitService = VisitService();
    final now = DateTime.now();

    final visit1 = Visit(
      id: 'v1',
      petId: 'pet1',
      branchId: 'BRANCH_DELHI',
      branchName: 'Delhi Central Clinic',
      vetId: 'vet1',
      vetName: 'Dr. Sharma',
      date: now.subtract(const Duration(days: 5)),
      notes: 'Initial evaluation',
      medications: ['Amoxicillin 250mg'],
      vaccination: 'Rabies',
      nextFollowUpDate: now.subtract(const Duration(days: 1)), // Overdue
    );

    final visit2 = Visit(
      id: 'v2',
      petId: 'pet1',
      branchId: 'BRANCH_MUMBAI',
      branchName: 'Mumbai Pet Specialty Hospital',
      vetId: 'vet2',
      vetName: 'Dr. Patel',
      date: now.subtract(const Duration(days: 20)),
      notes: 'Old checkup',
      medications: ['Old Med 50mg'],
      vaccination: '',
      nextFollowUpDate: null,
    );

    final report = visitService.evaluateSafetyFlags([visit1, visit2]);

    expect(report.isFollowUpOverdue, true);
    expect(report.overdueDate, isNotNull);
    expect(report.recentMedications.length, 1);
    expect(report.recentMedications.first.medicationName, 'Amoxicillin 250mg');
    expect(report.recentMedications.first.branchName, 'Delhi Central Clinic');
  });

  testWidgets('LoginScreen renders credentials form and sign in CTA',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('VetSync'), findsOneWidget);
    expect(find.text('Staff Medical Portal'), findsOneWidget);
    expect(find.text('Sign In to VetSync'), findsOneWidget);
    expect(find.text('Register Account'), findsOneWidget);
  });

  testWidgets('SignupScreen renders full registration inputs and branch dropdown',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignupScreen(),
      ),
    );

    expect(find.text('Staff Registration'), findsOneWidget);
    expect(find.text('Create Staff Account'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}


