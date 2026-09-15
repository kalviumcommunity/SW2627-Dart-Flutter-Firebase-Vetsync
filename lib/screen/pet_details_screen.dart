import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/models/visit.dart';
import 'package:vetsync/services/visit_service.dart';
import 'package:vetsync/screen/add_visit_screen.dart';
import 'package:vetsync/theme/app_colors.dart';
import 'package:vetsync/theme/app_text_styles.dart';
import 'package:vetsync/widgets/clinic_badge.dart';
import 'package:vetsync/widgets/medical_timeline_tile.dart';
import 'package:vetsync/widgets/safety_flag_card.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final VisitService _visitService = VisitService();

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
        title: Text('${widget.pet.name}\'s Medical File'),
      ),
      body: StreamBuilder<List<Visit>>(
        stream: _visitService.streamVisitsForPet(widget.pet.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading medical records: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          final visits = snapshot.data ?? [];
          final safetyReport = _visitService.evaluateSafetyFlags(visits);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Pet Profile Header Card
                _buildPetProfileCard(),

                const SizedBox(height: 16),

                // 2. Clinical Safety Flags Section
                SafetyFlagCard(report: safetyReport),

                const SizedBox(height: 24),

                // 3. Section Title & Cross-Branch Visit Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CROSS-BRANCH MEDICAL TIMELINE',
                          style: AppTextStyles.overline,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Synchronized Clinical History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryUltraSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primarySoft),
                      ),
                      child: Text(
                        '${visits.length} Visits',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Connected Timeline List
                if (visits.isEmpty)
                  _buildEmptyVisitsState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      return MedicalTimelineTile(
                        visit: visits[index],
                        isFirst: index == 0,
                        isLast: index == visits.length - 1,
                      );
                    },
                  ),
                const SizedBox(height: 60), // Padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVisitScreen(pet: widget.pet),
            ),
          );
        },
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Add Clinical Visit'),
      ),
    );
  }

  Widget _buildPetProfileCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryUltraSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primarySoft, width: 1.5),
                  ),
                  child: Icon(
                    _getSpeciesIcon(widget.pet.species),
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.pet.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.pet.age} Yrs • ${widget.pet.gender}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.pet.species} • ${widget.pet.breed}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Guardian: ${widget.pet.ownerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'ID: ${widget.pet.id.length > 8 ? widget.pet.id.substring(0, 8) : widget.pet.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Home Clinic: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                ClinicBadge(
                  branchName: widget.pet.branchName.isNotEmpty
                      ? widget.pet.branchName
                      : widget.pet.branchId,
                  isCompact: true,
                  isHighlighted: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisitsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.primaryUltraSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_edu_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Clinical Visits Recorded Yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When any clinic branch records an examination, diagnosis, or prescription, it will appear here in real-time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
