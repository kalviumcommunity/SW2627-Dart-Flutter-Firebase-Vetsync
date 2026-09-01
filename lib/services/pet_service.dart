import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsync/models/pet.dart';

/// Service for centralized pet operations across all clinic branches.
class PetService {
  final CollectionReference _petsCollection =
      FirebaseFirestore.instance.collection('pets');

  /// Streams all pets in real-time, ordered by most recently added first.
  Stream<List<Pet>> streamAllPets() {
    return _petsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    });
  }

  /// Adds a new pet record to the centralized database.
  Future<String> addPet({
    required String name,
    required String species,
    required String breed,
    required int age,
    required String ownerName,
    String gender = 'Unknown',
  }) async {
    final docRef = _petsCollection.doc();

    final pet = Pet(
      id: docRef.id,
      name: name.trim(),
      species: species.trim(),
      breed: breed.trim(),
      age: age,
      ownerName: ownerName.trim(),
      gender: gender,
      createdAt: DateTime.now(),
    );

    await docRef.set(pet.toMap());
    return docRef.id;
  }

  /// Fetches a single pet by ID.
  Future<Pet?> getPetById(String petId) async {
    final doc = await _petsCollection.doc(petId).get();
    if (!doc.exists) return null;
    return Pet.fromFirestore(doc);
  }
}
