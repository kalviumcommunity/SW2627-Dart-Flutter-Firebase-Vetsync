import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/services/branch_service.dart';

class BranchSelectionScreen extends StatefulWidget {
  final String? currentBranchId;
  final bool returnSelectedOnly;
  final Stream<List<Branch>>? customBranchStream;

  const BranchSelectionScreen({
    super.key,
    this.currentBranchId,
    this.returnSelectedOnly = false,
    this.customBranchStream,
  });

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  final BranchService _branchService = BranchService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCity = 'All';
  String _activeBranchId = '';
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _activeBranchId = widget.currentBranchId ?? 'BRANCH_DELHI';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectBranch(Branch branch) async {
    if (widget.returnSelectedOnly) {
      Navigator.pop(context, branch);
      return;
    }

    setState(() {
      _isSwitching = true;
    });

    try {
      await _branchService.updateCurrentVetBranch(
        branchId: branch.id,
        branchName: branch.name,
      );

      setState(() {
        _activeBranchId = branch.id;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Switched active clinic to ${branch.name} (${branch.city})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E88E5),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, branch);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update branch: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.apartment_rounded, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text('Clinic Branches', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: StreamBuilder<List<Branch>>(
        stream:
            widget.customBranchStream ?? _branchService.streamBranches(),
        builder: (context, snapshot) {
          final branches = snapshot.data ?? Branch.defaultBranches;

          // Extract unique cities
          final cities = ['All', ...{...branches.map((b) => b.city)}];

          // Filter branches by search query and city
          final filteredBranches = branches.where((branch) {
            final matchesCity =
                _selectedCity == 'All' || branch.city == _selectedCity;
            final query = _searchQuery.toLowerCase();
            final matchesQuery = query.isEmpty ||
                branch.name.toLowerCase().contains(query) ||
                branch.city.toLowerCase().contains(query) ||
                branch.address.toLowerCase().contains(query);

            return matchesCity && matchesQuery;
          }).toList();

          final activeBranch = branches.firstWhere(
            (b) => b.id.toLowerCase() == _activeBranchId.toLowerCase(),
            orElse: () => branches.first,
          );

          return Column(
            children: [
              // Active Branch Banner Card
              if (!widget.returnSelectedOnly)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_city_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ACTIVE CLINIC',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  activeBranch.city,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeBranch.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search clinic name, city, address...',
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
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),

              // City Filter Chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = _selectedCity == city;
                    return FilterChip(
                      label: Text(city),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF1E88E5),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
                          _selectedCity = city;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),

              // Branches List
              Expanded(
                child: filteredBranches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off,
                                size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No clinic branches match "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBranches.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final branch = filteredBranches[index];
                          final isActive =
                              branch.id.toLowerCase() ==
                              _activeBranchId.toLowerCase();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: isActive ? 2 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isActive
                                    ? const Color(0xFF1E88E5)
                                    : Colors.grey.shade200,
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isActive
                                            ? const Color(0xFF1E88E5)
                                            : Colors.grey.shade100,
                                        child: Icon(
                                          Icons.local_hospital,
                                          color: isActive
                                              ? Colors.white
                                              : const Color(0xFF1E88E5),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    branch.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                if (branch.isMainBranch)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.amber.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      'MAIN HUB',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .amber.shade900,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              branch.city,
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Address
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.pin_drop_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          branch.address,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Hours & Contact
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          branch.operatingHours,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      if (branch.phone.isNotEmpty) ...[
                                        const Icon(Icons.phone_outlined,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          branch.phone,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  // Select Button / Active Badge
                                  SizedBox(
                                    width: double.infinity,
                                    child: isActive
                                        ? OutlinedButton.icon(
                                            onPressed: null,
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                            label: const Text(
                                              'Active Location Selected',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Colors.green.shade300),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: _isSwitching
                                                ? null
                                                : () => _selectBranch(branch),
                                            icon: const Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 18),
                                            label: Text(
                                              widget.returnSelectedOnly
                                                  ? 'Choose This Branch'
                                                  : 'Switch To This Branch',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF1E88E5),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
