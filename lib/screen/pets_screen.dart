import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/pet_service.dart';
import 'package:vetsync/screen/add_pet_screen.dart';
import 'package:vetsync/screen/branch_selection_screen.dart';
import 'package:vetsync/screen/pet_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Health Records'),
        actions: [
          IconButton(
            tooltip: 'Branches',
            icon: const Icon(Icons.location_city_outlined),
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
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search pet, owner, breed, branch...',
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF1E88E5)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                ),
              ),

              // Branch Filter Chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('All Clinics'),
                      selected: _selectedBranchFilter == 'ALL',
                      showCheckmark: false,
                      selectedColor: const Color(0xFF1E88E5),
                      labelStyle: TextStyle(
                        color: _selectedBranchFilter == 'ALL'
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: _selectedBranchFilter == 'ALL'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _selectedBranchFilter == 'ALL'
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300,
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
                          selectedColor: const Color(0xFF1E88E5),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF1E88E5)
                                  : Colors.grey.shade300,
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
              const SizedBox(height: 6),

              // Real-Time Pets List
              Expanded(
                child: StreamBuilder<List<Pet>>(
                  stream: _petService.streamAllPets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load records: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
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
                      final branchMatches =
                          pet.branchName.toLowerCase().contains(_searchQuery) ||
                              pet.branchId.toLowerCase().contains(_searchQuery);

                      return nameMatches ||
                          ownerMatches ||
                          breedMatches ||
                          branchMatches;
                    }).toList();

                    if (filteredPets.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.pets,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No pets match "$_searchQuery"'
                                    : 'No pets found for this clinic location.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selectedBranchFilter != 'ALL'
                                    ? 'Try switching to "All Clinics" or add a new pet for this branch.'
                                    : 'Tap the "+" button below to register a pet record.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredPets.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final Pet pet = filteredPets[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PetDetailsScreen(pet: pet),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor:
                                        const Color(0xFF1E88E5).withAlpha(25),
                                    child: const Icon(
                                      Icons.pets,
                                      color: Color(0xFF1E88E5),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                pet.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '(${pet.species})',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pet.breed} • ${pet.age} Yrs • ${pet.gender}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Owner: ${pet.ownerName}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Branch Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E88E5)
                                                .withAlpha(20),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.apartment_rounded,
                                                size: 13,
                                                color: Color(0xFF1E88E5),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pet.branchName.isNotEmpty
                                                    ? pet.branchName
                                                    : pet.branchId,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E88E5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
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
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
    );
  }
}