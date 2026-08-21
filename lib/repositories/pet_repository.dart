import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsync/models/pet.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Pet>> getPets() async {
    final QuerySnapshot snapshot =
        await _firestore.collection("pets").get();

    return snapshot.docs.map((doc) {
      return Pet.fromFirestore(doc);
    }).toList();
  }
}