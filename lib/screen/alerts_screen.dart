import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/models/visit.dart';
import 'package:vetsync/screen/pet_details_screen.dart';
import 'package:vetsync/services/pet_service.dart';
import 'package:vetsync/services/visit_service.dart';
import 'package:vetsync/theme/app_colors.dart';
import 'package:vetsync/widgets/empty_state_view.dart';

/// Clinical Safety & Attention Hub showing overdue follow-ups and recent cross-branch medication alerts.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final PetService _petService = PetService();
  final VisitService _visitService = VisitService();

  String _formatDateOnly(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Clinical Safety & Alerts'),
          ],
        ),
      ),
      body: StreamBuilder<List<Pet>>(
        stream: _petService.streamAllPets(),
        builder: (context, petSnapshot) {
          if (petSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (petSnapshot.hasError) {
            return EmptyStateView(
              icon: Icons.error_outline_rounded,
              title: 'Unable to Load Clinical Alerts',
              description: 'Please check your network connection and try again.',
              isError: true,
              actionLabel: 'Retry',
              onAction: () => setState(() {}),
            );
          }

          final pets = petSnapshot.data ?? [];

          if (pets.isEmpty) {
            return const EmptyStateView(
              icon: Icons.verified_user_outlined,
              title: 'No Active Alerts',
              description:
                  'All registered pets are currently up to date with no overdue follow-ups or drug alerts.',
            );
          }

          // Listen to all visits to aggregate cross-branch warnings
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('visits').snapshots(),
            builder: (context, visitSnapshot) {
              if (visitSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final visitDocs = visitSnapshot.data?.docs ?? [];
              final allVisits = visitDocs.map((d) => Visit.fromFirestore(d)).toList();

              // Map visits by petId
              final Map<String, List<Visit>> petVisitsMap = {};
              for (final v in allVisits) {
                petVisitsMap.putIfAbsent(v.petId, () => []).add(v);
              }

              // Evaluate safety report for each pet
              final List<_PetAlertItem> alertItems = [];

              for (final pet in pets) {
                final visits = petVisitsMap[pet.id] ?? [];
                if (visits.isEmpty) continue;

                // Sort descending
                visits.sort((a, b) => b.date.compareTo(a.date));
                final report = _visitService.evaluateSafetyFlags(visits);

                if (report.isFollowUpOverdue || report.recentMedications.isNotEmpty) {
                  alertItems.add(_PetAlertItem(pet: pet, report: report));
                }
              }

              if (alertItems.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'All Patients Up to Date',
                  description:
                      'No overdue follow-up evaluations or recent cross-branch medication risks detected across the clinic network.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: alertItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = alertItems[index];
                  final pet = item.pet;
                  final report = item.report;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: report.isFollowUpOverdue
                            ? AppColors.warningBorder
                            : AppColors.medicationBorder,
                        width: 1.2,
                      ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pet Header Row
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: report.isFollowUpOverdue
                                      ? AppColors.warningSurface
                                      : AppColors.medicationSurface,
                                  child: Icon(
                                    Icons.pets_rounded,
                                    size: 18,
                                    color: report.isFollowUpOverdue
                                        ? AppColors.warning
                                        : AppColors.medication,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${pet.species} • ${pet.breed} (Owner: ${pet.ownerName})',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textLight,
                                ),
                              ],
                            ),
                            const Divider(height: 18),

                            // Overdue Alert Tag
                            if (report.isFollowUpOverdue && report.overdueDate != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.warningSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warningBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Overdue Follow-up scheduled for ${_formatDateOnly(report.overdueDate!)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (report.recentMedications.isNotEmpty)
                                const SizedBox(height: 8),
                            ],

                            // Recent Medications
                            if (report.recentMedications.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.medicationSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.medicationBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.medication_liquid_rounded,
                                          size: 15,
                                          color: AppColors.medication,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Recent Cross-Branch Medications (< 14 Days):',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.medication,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: report.recentMedications.map((m) {
                                        return Text(
                                          '• ${m.medicationName} (${m.branchName.isNotEmpty ? m.branchName : m.branchId})',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.medication,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}

class _PetAlertItem {
  final Pet pet;
  final SafetyReport report;

  const _PetAlertItem({required this.pet, required this.report});
}
