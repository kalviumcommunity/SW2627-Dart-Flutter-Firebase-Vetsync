import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
  });

  factory Pet.fromFirestore(DocumentSnapshot doc){

    final data = doc.data() as Map<String , dynamic>;

    return Pet(
      id: data["id"],
      name: data["name"],
      species: data["species"],
      breed: data["breed"],
      age: data["age"],
    );

  }
}