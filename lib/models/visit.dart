import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a clinical medical visit recorded at any clinic branch.
class Visit {
  final String id;
  final String petId;
  final String branchId;
  final String vetId;
  final String vetName;
  final DateTime date;
  final String notes;
  final List<String> medications;
  final String vaccination;
  final DateTime? nextFollowUpDate;

  const Visit({
    required this.id,
    required this.petId,
    required this.branchId,
    required this.vetId,
    required this.vetName,
    required this.date,
    required this.notes,
    required this.medications,
    this.vaccination = '',
    this.nextFollowUpDate,
  });

  /// Factory constructor to deserialize a Firestore document snapshot.
  factory Visit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime visitDate = DateTime.now();
    if (data['date'] is Timestamp) {
      visitDate = (data['date'] as Timestamp).toDate();
    }

    DateTime? followUpDate;
    if (data['nextFollowUpDate'] is Timestamp) {
      followUpDate = (data['nextFollowUpDate'] as Timestamp).toDate();
    }

    List<String> meds = [];
    if (data['medications'] is List) {
      meds = List<String>.from(data['medications'].map((e) => e.toString()));
    }

    return Visit(
      id: doc.id,
      petId: data['petId'] ?? '',
      branchId: data['branchId'] ?? 'BRANCH_UNKNOWN',
      vetId: data['vetId'] ?? '',
      vetName: data['vetName'] ?? 'Attending Veterinarian',
      date: visitDate,
      notes: data['notes'] ?? '',
      medications: meds,
      vaccination: data['vaccination'] ?? '',
      nextFollowUpDate: followUpDate,
    );
  }

  /// Serializes the Visit object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'branchId': branchId,
      'vetId': vetId,
      'vetName': vetName,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'medications': medications,
      'vaccination': vaccination,
      'nextFollowUpDate': nextFollowUpDate != null
          ? Timestamp.fromDate(nextFollowUpDate!)
          : null,
    };
  }
}
