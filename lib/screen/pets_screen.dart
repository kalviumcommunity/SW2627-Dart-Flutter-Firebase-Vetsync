import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/repositories/pet_repository.dart';

class PetsScreen extends StatelessWidget {

  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {

      final List<Pet> pets = PetRepository.pets;


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