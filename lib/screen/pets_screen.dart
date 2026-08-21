import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/repositories/pet_repository.dart';
import 'package:vetsync/screen/add_pet_screen.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final PetRepository repository = PetRepository();

  List<Pet> pets = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    final data = await repository.getPets();

    setState(() {
      pets = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: pets.length,

              itemBuilder: (context, index) {
                final Pet pet = pets[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  child: ListTile(
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
                      "${pet.breed} • Species: ${pet.species} • Age: ${pet.age}",
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPetScreen(),
                  ),
                );

                loadPets();
              },
              child: const Icon(Icons.add),
            ),
    );
    
  }
}