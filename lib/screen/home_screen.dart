import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/models/visit.dart';
import 'package:vetsync/screen/add_pet_screen.dart';
import 'package:vetsync/screen/branch_selection_screen.dart';
import 'package:vetsync/screen/pet_details_screen.dart';
import 'package:vetsync/screen/pets_screen.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/pet_service.dart';
import 'package:vetsync/theme/app_colors.dart';
import 'package:vetsync/theme/app_text_styles.dart';
import 'package:vetsync/widgets/clinic_badge.dart';
import 'package:vetsync/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final BranchService _branchService = BranchService();
  final PetService _petService = PetService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _openBranchSelection(String currentBranchId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BranchSelectionScreen(
          currentBranchId: currentBranchId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('vets').doc(user.uid).snapshots(),
          builder: (context, vetSnapshot) {
            String vetName = user.displayName ?? 'Doctor';
            String branchId = 'BRANCH_DELHI';
            String branchName = 'Delhi Central Clinic';

            if (vetSnapshot.hasData && vetSnapshot.data!.exists) {
              final data = vetSnapshot.data!.data() as Map<String, dynamic>?;
              if (data != null) {
                vetName = data['name'] ?? vetName;
                branchId = data['branchID'] ?? branchId;
                branchName = data['branchName'] ??
                    _branchService.getBranchByIdSync(branchId).name;
              }
            }

            final currentBranch = _branchService.getBranchByIdSync(branchId);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VetSync',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Centralized Medical Network',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Active Hub Badge
                        InkWell(
                          onTap: () => _openBranchSelection(branchId),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryUltraSoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primarySoft),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentBranch.city,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Doctor Greeting Hero Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getGreeting()},',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Cross-Branch Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dr. $vetName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    branchName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _openBranchSelection(branchId),
                                  child: const Text(
                                    'Change',
                                    style: TextStyle(
                                      color: Color(0xFF5EEAD4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Clinical Stream Data (Pets + Visits Counts)
                    StreamBuilder<List<Pet>>(
                      stream: _petService.streamAllPets(),
                      builder: (context, petSnapshot) {
                        final allPets = petSnapshot.data ?? [];
                        final branchPets = allPets.where((p) =>
                            p.branchId.toLowerCase() == branchId.toLowerCase()).toList();

                        return StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('visits').snapshots(),
                          builder: (context, visitSnapshot) {
                            final visitDocs = visitSnapshot.data?.docs ?? [];
                            final allVisits =
                                visitDocs.map((d) => Visit.fromFirestore(d)).toList();

                            // Calculate today's visits
                            final now = DateTime.now();
                            final todayVisits = allVisits.where((v) =>
                                v.date.year == now.year &&
                                v.date.month == now.month &&
                                v.date.day == now.day).length;

                            // Calculate overdue follow-ups
                            final overdueFollowUps = allVisits.where((v) =>
                                v.nextFollowUpDate != null &&
                                v.nextFollowUpDate!.isBefore(now)).length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats 2x2 Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        title: 'Registered Pets',
                                        value: '${allPets.length}',
                                        subtitle: '${branchPets.length} this branch',
                                        icon: Icons.pets_rounded,
                                        iconColor: AppColors.primary,
                                        backgroundColor: AppColors.primaryUltraSoft,
                                        onTap: () {
                                          if (widget.onNavigateTab != null) {
                                            widget.onNavigateTab!(1);
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PetsScreen(),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatCard(
                                        title: 'Today\'s Visits',
                                        value: '$todayVisits',
                                        subtitle: '${allVisits.length} total logged',
                                        icon: Icons.event_available_rounded,
                                        iconColor: AppColors.accent,
                                        backgroundColor: AppColors.accentSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        title: 'Follow-ups Due',
                                        value: '$overdueFollowUps',
                                        subtitle: overdueFollowUps > 0
                                            ? 'Attention needed'
                                            : 'All up to date',
                                        icon: Icons.warning_amber_rounded,
                                        iconColor: overdueFollowUps > 0
                                            ? AppColors.warning
                                            : AppColors.success,
                                        backgroundColor: overdueFollowUps > 0
                                            ? AppColors.warningSurface
                                            : AppColors.successSurface,
                                        onTap: () {
                                          if (widget.onNavigateTab != null) {
                                            widget.onNavigateTab!(2);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: StatCard(
                                        title: 'Clinic Branches',
                                        value: '7',
                                        subtitle: 'Centralized network',
                                        icon: Icons.location_city_rounded,
                                        iconColor: AppColors.medication,
                                        backgroundColor: AppColors.medicationSurface,
                                        onTap: () => _openBranchSelection(branchId),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Section
                    const Text(
                      'QUICK ACTIONS',
                      style: AppTextStyles.overline,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: Icons.search_rounded,
                            label: 'Search Pet',
                            subtitle: 'Lookup chart',
                            color: AppColors.primary,
                            onTap: () {
                              if (widget.onNavigateTab != null) {
                                widget.onNavigateTab!(1);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PetsScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context: context,
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Register Pet',
                            subtitle: 'New patient',
                            color: AppColors.secondary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddPetScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Cross-Branch Activity Feed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RECENT CLINICAL VISITS',
                          style: AppTextStyles.overline,
                        ),
                        TextButton(
                          onPressed: () {
                            if (widget.onNavigateTab != null) {
                              widget.onNavigateTab!(1);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PetsScreen(),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            'View All Pets',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Stream Recent Visits
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('visits')
                          .orderBy('date', descending: true)
                          .limit(5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 36,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No clinical visits recorded yet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Visits recorded at any branch will synchronize here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final visits = docs.map((d) => Visit.fromFirestore(d)).toList();

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visits.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final visit = visits[index];

                            return FutureBuilder<Pet?>(
                              future: _petService.getPetById(visit.petId),
                              builder: (context, petSnap) {
                                final pet = petSnap.data;
                                final petName = pet?.name ?? 'Patient Record';
                                final petBreed = pet != null ? '${pet.species} • ${pet.breed}' : 'Central Record';

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.border),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      if (pet != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PetDetailsScreen(pet: pet),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.primaryUltraSoft,
                                            child: const Icon(
                                              Icons.pets_rounded,
                                              size: 18,
                                              color: AppColors.primary,
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
                                                        petName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 14,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      _formatDateTime(visit.date),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  visit.notes.isNotEmpty
                                                      ? visit.notes
                                                      : petBreed,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    ClinicBadge(
                                                      branchName: visit.branchName,
                                                      isCompact: true,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Dr. ${visit.vetName}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}