import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/pet_service.dart';
import 'package:vetsync/theme/app_colors.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final PetService _petService = PetService();
  final BranchService _branchService = BranchService();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedBranchId = 'BRANCH_DELHI';
  String _selectedBranchName = 'Delhi Central Clinic';
  List<Branch> _availableBranches = Branch.defaultBranches;
  bool _isLoading = false;

  final List<String> _commonSpecies = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadBranchesAndCurrentVet();
  }

  Future<void> _loadBranchesAndCurrentVet() async {
    final branches = await _branchService.getBranches();
    setState(() {
      _availableBranches = branches;
    });

    final user = _authService.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('vets')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data();
          final bId = data?['branchID'] ?? 'BRANCH_DELHI';
          final bName = data?['branchName'] ??
              _branchService.getBranchByIdSync(bId).name;
          setState(() {
            _selectedBranchId = bId;
            _selectedBranchName = bName;
          });
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _submitPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _petService.addPet(
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        age: int.parse(_ageController.text.trim()),
        ownerName: _ownerNameController.text,
        gender: _selectedGender,
        branchId: _selectedBranchId,
        branchName: _selectedBranchName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${_nameController.text} registered at $_selectedBranchName!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register pet record: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Patient'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryUltraSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primarySoft),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.pets_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Registering a centralized medical chart accessible across all clinic branches in real-time.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Registering Clinic Branch
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBranchId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Registering Clinic Branch *',
                          prefixIcon: Icon(Icons.apartment_rounded),
                        ),
                        items: _availableBranches.map((branch) {
                          return DropdownMenuItem(
                            value: branch.id,
                            child: Text(
                              '${branch.name} (${branch.city})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final b = _branchService.getBranchByIdSync(val);
                            setState(() {
                              _selectedBranchId = val;
                              _selectedBranchName = b.name;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pet Name
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Pet Name *',
                          hintText: 'e.g. Max, Bella, Charlie',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter pet name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Owner / Guardian Name
                      TextFormField(
                        controller: _ownerNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Owner / Guardian Name *',
                          hintText: 'e.g. John Smith',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter owner name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Species Dropdown / Autocomplete
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _commonSpecies;
                          }
                          return _commonSpecies.where((species) => species
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _speciesController.text = selection;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          _speciesController.text = controller.text;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Species *',
                              hintText: 'Dog, Cat, Bird, etc.',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter or select species'
                                    : null,
                            onChanged: (val) {
                              _speciesController.text = val;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Breed
                      TextFormField(
                        controller: _breedController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Breed *',
                          hintText: 'e.g. Golden Retriever, Persian, Labrador',
                          prefixIcon: Icon(Icons.bubble_chart_outlined),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter breed'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Age & Gender Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Age (Years) *',
                                hintText: 'e.g. 3',
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter age';
                                }
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null || parsed < 0) {
                                  return 'Valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.transgender_rounded),
                              ),
                              items: ['Male', 'Female', 'Unknown'].map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitPet,
                    icon: const Icon(Icons.save_rounded),
                    label: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Text(
                            'Register Patient Record',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}