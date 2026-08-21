import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final docRef = _firestore.collection("pets").doc();

    await docRef.set({
      "id": docRef.id,
      "name": _nameController.text,
      "species": _speciesController.text,
      "breed": _breedController.text,
      "age": int.parse(_ageController.text),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pet Added Successfully 🐾")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Pet"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Register New Pet 🐶",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Pet Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter pet name"
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: "Species",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter species"
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: "Breed",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "Enter breed"
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter age";
                  }

                  if (int.tryParse(value) == null) {
                    return "Age must be a number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addPet,
                  child: const Text("Add Pet"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}