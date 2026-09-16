import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsync/models/visit.dart';

/// Helper model for safety flag analysis.
class SafetyReport {
  final bool isFollowUpOverdue;
  final DateTime? overdueDate;
  final List<RecentMedicationInfo> recentMedications;

  const SafetyReport({
    required this.isFollowUpOverdue,
    this.overdueDate,
    required this.recentMedications,
  });
}

/// Helper model for a recently prescribed medication.
class RecentMedicationInfo {
  final String medicationName;
  final DateTime prescribedDate;
  final String branchId;
  final String branchName;
  final String vetName;

  const RecentMedicationInfo({
    required this.medicationName,
    required this.prescribedDate,
    required this.branchId,
    required this.branchName,
    required this.vetName,
  });
}

/// Service for managing cross-branch pet visit records and safety flags.
class VisitService {
  final FirebaseFirestore? _customFirestore;

  VisitService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  CollectionReference get _visitsCollection =>
      (_customFirestore ?? FirebaseFirestore.instance).collection('visits');

  /// Streams visits for a specific pet in real-time, newest visits first.
  Stream<List<Visit>> streamVisitsForPet(String petId) {
    return _visitsCollection
        .where('petId', isEqualTo: petId)
        .snapshots()
        .map((snapshot) {
      final visits = snapshot.docs
          .map((doc) => Visit.fromFirestore(doc))
          .toList();

      // Sort by date descending (newest first)
      visits.sort((a, b) => b.date.compareTo(a.date));
      return visits;
    });
  }

  /// Adds a new clinical visit record to the centralized database with branch & vet metadata.
  Future<String> addVisit({
    required String petId,
    required String branchId,
    String branchName = '',
    required String vetId,
    required String vetName,
    required String notes,
    required List<String> medications,
    String vaccination = '',
    DateTime? visitDate,
    DateTime? nextFollowUpDate,
  }) async {
    final docRef = _visitsCollection.doc();

    final visit = Visit(
      id: docRef.id,
      petId: petId,
      branchId: branchId,
      branchName: branchName.isNotEmpty ? branchName : branchId,
      vetId: vetId,
      vetName: vetName,
      date: visitDate ?? DateTime.now(),
      notes: notes.trim(),
      medications: medications,
      vaccination: vaccination.trim(),
      nextFollowUpDate: nextFollowUpDate,
    );

    await docRef.set(visit.toMap());
    return docRef.id;
  }

  /// Analyzes visit history to generate real-time Clinical Safety Flags.
  SafetyReport evaluateSafetyFlags(List<Visit> visits) {
    if (visits.isEmpty) {
      return const SafetyReport(
        isFollowUpOverdue: false,
        recentMedications: [],
      );
    }

    final now = DateTime.now();
    bool isOverdue = false;
    DateTime? overdueDate;

    // Check if the most recent follow-up date has passed
    for (final visit in visits) {
      if (visit.nextFollowUpDate != null) {
        if (visit.nextFollowUpDate!.isBefore(now)) {
          isOverdue = true;
          overdueDate = visit.nextFollowUpDate;
          break; // Found the latest overdue date
        }
      }
    }

    // Check for medications prescribed in the past 14 days
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final List<RecentMedicationInfo> recentMeds = [];

    for (final visit in visits) {
      if (visit.date.isAfter(fourteenDaysAgo)) {
        for (final med in visit.medications) {
          if (med.trim().isNotEmpty) {
            recentMeds.add(
              RecentMedicationInfo(
                medicationName: med.trim(),
                prescribedDate: visit.date,
                branchId: visit.branchId,
                branchName: visit.branchName,
                vetName: visit.vetName,
              ),
            );
          }
        }
      }
    }

    return SafetyReport(
      isFollowUpOverdue: isOverdue,
      overdueDate: overdueDate,
      recentMedications: recentMeds,
    );
  }
}
