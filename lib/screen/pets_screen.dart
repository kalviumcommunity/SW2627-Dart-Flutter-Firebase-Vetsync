import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';

class PetsScreen extends StatelessWidget {

  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {

      final List<Pet> pets = [
        const Pet(
          id: "pet001", 
          name: "Bruno", 
          species: "Dog", 
          breed: "Golden Retriver", 
          age: 3
        ),
        const Pet(
          id: "pet002", 
          name: "Milo", 
          species: "Cat", 
          breed: "Persian", 
          age: 2
        ),
        const Pet(
          id: "pet003", 
          name: "Tommy", 
          species: "Dog", 
          breed: "Labrador", 
          age: 5
        ),
      ];


      return Scaffold(
        appBar: AppBar(
          title: const Text("My Pets"),
        ),
        body: Center(
          child: Text(
            'Total Pets: ${pets.length}',
            style: TextStyle(
              fontSize: 24
            ), 
          ),
        ),
      );
  }

}