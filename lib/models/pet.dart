import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Pet in the VetSync centralized system.
class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String ownerName;
  final String gender;
  final DateTime? createdAt;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.ownerName,
    this.gender = 'Unknown',
    this.createdAt,
  });

  /// Factory constructor to deserialize a Firestore document snapshot.
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime? createdDateTime;
    if (data['createdAt'] is Timestamp) {
      createdDateTime = (data['createdAt'] as Timestamp).toDate();
    }

    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] is int
          ? data['age']
          : (int.tryParse(data['age']?.toString() ?? '0') ?? 0),
      ownerName: data['ownerName'] ?? 'Unknown Owner',
      gender: data['gender'] ?? 'Unknown',
      createdAt: createdDateTime,
    );
  }

  /// Serializes the Pet object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'ownerName': ownerName,
      'gender': gender,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}