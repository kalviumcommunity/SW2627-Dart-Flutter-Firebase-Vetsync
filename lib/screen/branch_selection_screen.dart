import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/theme/app_colors.dart';

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

      if (!mounted) return;

      setState(() {
        _activeBranchId = branch.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Active clinic switched to ${branch.name} (${branch.city})'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, branch);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update active branch: $e'),
          backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clinic Branches'),
      ),
      body: StreamBuilder<List<Branch>>(
        stream: widget.customBranchStream ?? _branchService.streamBranches(),
        builder: (context, snapshot) {
          final branches = snapshot.data ?? Branch.defaultBranches;
          final cities = ['All', ...{...branches.map((b) => b.city)}];

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
              // Active Clinic Banner
              if (!widget.returnSelectedOnly)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CURRENT ACTIVE CLINIC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeBranch.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              activeBranch.city,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
                    hintText: 'Search clinic name, city, or address...',
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
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),

              // City Filter Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cities.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final isSelected = _selectedCity == city;
                    return FilterChip(
                      label: Text(city),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
                          _selectedCity = city;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Branches List
              Expanded(
                child: ListView.separated(
                  itemCount: filteredBranches.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final branch = filteredBranches[index];
                    final isActive =
                        branch.id.toLowerCase() == _activeBranchId.toLowerCase();

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isActive ? AppColors.primary : AppColors.border,
                          width: isActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primaryUltraSoft
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital_rounded,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              branch.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (branch.isMainBranch)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.warningSurface,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: AppColors.warningBorder),
                                              ),
                                              child: const Text(
                                                'MAIN HUB',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.warning,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        branch.city,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Address
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    branch.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Operating Hours
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  branch.operatingHours,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: isActive
                                  ? OutlinedButton.icon(
                                      onPressed: null,
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Active Clinic Selected',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: AppColors.successBorder),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _isSwitching
                                          ? null
                                          : () => _selectBranch(branch),
                                      icon: const Icon(
                                        Icons.swap_horiz_rounded,
                                        size: 16,
                                      ),
                                      label: Text(
                                        widget.returnSelectedOnly
                                            ? 'Select This Branch'
                                            : 'Switch To This Branch',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
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