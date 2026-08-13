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
        const Pet(
          id: "pet004", 
          name: "Tetee", 
          species: "Cat", 
          breed: "Lesbian", 
          age: 1
        ),
        const Pet(
          id: "pet005", 
          name: "Heraaa Beta", 
          species: "Dog", 
          breed: "Gay", 
          age: 9
        ),
        
      ];


      return Scaffold(
        appBar: AppBar(
          title: Text("My Pets"),
        ),

        body : ListView.builder(
          itemCount: pets.length,

          itemBuilder: (context, index) {
            final Pet pet = pets[index];

            return Card(
              margin : const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8
              ),

              child : ListTile(

                leading: const Icon(
                  Icons.pets,
                  size: 32,
                ),

                title: Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  '${pet.breed} • Species : ${pet.species}  • Age: ${pet.age}',
                ),

              )
            );

          }
        ),
      );
  }

}