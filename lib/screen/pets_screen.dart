import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/pet_service.dart';
import 'package:vetsync/screen/add_pet_screen.dart';
import 'package:vetsync/screen/branch_selection_screen.dart';
import 'package:vetsync/screen/pet_details_screen.dart';
import 'package:vetsync/theme/app_colors.dart';
import 'package:vetsync/widgets/clinic_badge.dart';
import 'package:vetsync/widgets/empty_state_view.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final PetService _petService = PetService();
  final BranchService _branchService = BranchService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedBranchFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getSpeciesIcon(String species) {
    final s = species.toLowerCase();
    if (s.contains('dog') || s.contains('canine')) {
      return Icons.pets_rounded;
    } else if (s.contains('cat') || s.contains('feline')) {
      return Icons.cruelty_free_rounded;
    } else if (s.contains('bird') || s.contains('avian')) {
      return Icons.flutter_dash_rounded;
    }
    return Icons.pets_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Directory'),
        actions: [
          IconButton(
            tooltip: 'Clinic Branches',
            icon: const Icon(Icons.location_city_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BranchSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Branch>>(
        stream: _branchService.streamBranches(),
        builder: (context, branchSnapshot) {
          final branches = branchSnapshot.data ?? Branch.defaultBranches;

          return Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by pet name, owner, breed or ID...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),

              // Clinic Branch Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('All Clinics'),
                      selected: _selectedBranchFilter == 'ALL',
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedBranchFilter == 'ALL'
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: _selectedBranchFilter == 'ALL'
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _selectedBranchFilter == 'ALL'
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedBranchFilter = 'ALL';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...branches.map((b) {
                      final isSelected = _selectedBranchFilter == b.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${b.city} (${b.name.split(' ').first})'),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedBranchFilter = b.id;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Real-Time Pets List
              Expanded(
                child: StreamBuilder<List<Pet>>(
                  stream: _petService.streamAllPets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return EmptyStateView(
                        icon: Icons.error_outline_rounded,
                        title: 'Unable to Load Records',
                        description: 'Please check your connection and try again.',
                        isError: true,
                        actionLabel: 'Retry',
                        onAction: () => setState(() {}),
                      );
                    }

                    final allPets = snapshot.data ?? [];

                    // Filter pets based on branch selection and search query
                    final filteredPets = allPets.where((pet) {
                      final matchesBranch = _selectedBranchFilter == 'ALL' ||
                          pet.branchId.toLowerCase() ==
                              _selectedBranchFilter.toLowerCase();

                      if (!matchesBranch) return false;

                      if (_searchQuery.isEmpty) return true;
                      final nameMatches =
                          pet.name.toLowerCase().contains(_searchQuery);
                      final ownerMatches =
                          pet.ownerName.toLowerCase().contains(_searchQuery);
                      final breedMatches =
                          pet.breed.toLowerCase().contains(_searchQuery);
                      final idMatches =
                          pet.id.toLowerCase().contains(_searchQuery);
                      final branchMatches =
                          pet.branchName.toLowerCase().contains(_searchQuery) ||
                              pet.branchId.toLowerCase().contains(_searchQuery);

                      return nameMatches ||
                          ownerMatches ||
                          breedMatches ||
                          idMatches ||
                          branchMatches;
                    }).toList();

                    if (filteredPets.isEmpty) {
                      return EmptyStateView(
                        icon: _searchQuery.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.pets_rounded,
                        title: _searchQuery.isNotEmpty
                            ? 'No Patients Found'
                            : 'Patient Directory Empty',
                        description: _searchQuery.isNotEmpty
                            ? 'No records match "$_searchQuery". Try searching with a different pet name or owner.'
                            : 'No pets have been registered for this clinic location yet.',
                        actionLabel: _searchQuery.isEmpty ? 'Register First Pet' : null,
                        onAction: _searchQuery.isEmpty
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddPetScreen(),
                                  ),
                                );
                              }
                            : null,
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredPets.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final Pet pet = filteredPets[index];

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailsScreen(pet: pet),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Pet Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryUltraSoft,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primarySoft,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      _getSpeciesIcon(pet.species),
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Pet Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                pet.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceVariant,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                pet.species,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${pet.breed} • ${pet.age} Yrs • ${pet.gender}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline_rounded,
                                              size: 14,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Guardian: ${pet.ownerName}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClinicBadge(
                                          branchName: pet.branchName.isNotEmpty
                                              ? pet.branchName
                                              : pet.branchId,
                                          isCompact: true,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Chevron
                                  const Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPetScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Register Pet'),
      ),
    );
  }
}