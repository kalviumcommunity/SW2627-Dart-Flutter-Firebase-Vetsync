import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsync/models/pet.dart';

/// Service for centralized pet operations across all clinic branches.
class PetService {
  final FirebaseFirestore? _customFirestore;

  PetService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  CollectionReference get _petsCollection =>
      (_customFirestore ?? FirebaseFirestore.instance).collection('pets');

  /// Streams all pets in real-time, ordered by most recently added first.
  Stream<List<Pet>> streamAllPets() {
    return _petsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    });
  }

  /// Streams pets filtered by a specific clinic branch ID.
  Stream<List<Pet>> streamPetsByBranch(String branchId) {
    return _petsCollection
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map((snapshot) {
      final pets = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
      pets.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return pets;
    });
  }

  /// Adds a new pet record to the centralized database with registered branch attribution.
  Future<String> addPet({
    required String name,
    required String species,
    required String breed,
    required int age,
    required String ownerName,
    String gender = 'Unknown',
    String branchId = 'BRANCH_DELHI',
    String branchName = 'Delhi Central Clinic',
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
      branchId: branchId,
      branchName: branchName,
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
