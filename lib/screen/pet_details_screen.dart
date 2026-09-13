import 'package:flutter/material.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/models/visit.dart';
import 'package:vetsync/services/visit_service.dart';
import 'package:vetsync/screen/add_visit_screen.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final VisitService _visitService = VisitService();

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;

    final hourNum = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hourNum:$minuteStr $amPm';
  }

  String _formatDateOnly(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Text(
                'Error loading visits: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
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
                _buildSafetyFlagsSection(safetyReport),

                const SizedBox(height: 20),

                // 3. Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cross-Branch Visit Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text('${visits.length} Visits'),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: const TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Timeline list or Empty state
                if (visits.isEmpty)
                  _buildEmptyVisitsState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visits.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildVisitCard(visits[index]);
                    },
                  ),
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
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Visit'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPetProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1E88E5).withAlpha(30),
                  child: const Icon(
                    Icons.pets,
                    color: Color(0xFF1E88E5),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pet.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.pet.species} • ${widget.pet.breed}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${widget.pet.age} Yrs'),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Owner: ${widget.pet.ownerName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.transgender, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.pet.gender,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.apartment_rounded,
                    size: 16, color: Color(0xFF1E88E5)),
                const SizedBox(width: 6),
                Text(
                  'Home Clinic: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Expanded(
                  child: Text(
                    widget.pet.branchName.isNotEmpty
                        ? widget.pet.branchName
                        : widget.pet.branchId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFlagsSection(SafetyReport report) {
    if (!report.isFollowUpOverdue && report.recentMedications.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Clinical Status: Up to date. No overdue follow-ups or recent cross-branch medication risks.',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ⚠️ Overdue Follow-Up Flag
        if (report.isFollowUpOverdue && report.overdueDate != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade400, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.deepOrange, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OVERDUE FOLLOW-UP ALERT',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scheduled follow-up on ${_formatDateOnly(report.overdueDate!)} was missed.',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 💊 Recent Medication Flag
        if (report.recentMedications.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.purple.shade300, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medication_liquid_sharp,
                    color: Colors.purple, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECENT MEDICATION FLAG (< 14 Days)',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check previous branch prescriptions to avoid duplicate dosage:',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: report.recentMedications.map((med) {
                          final branchDisplay = med.branchName.isNotEmpty
                              ? med.branchName
                              : med.branchId;
                          return Chip(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.purple.shade200),
                            label: Text(
                              '${med.medicationName} ($branchDisplay)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisitCard(Visit visit) {
    final branchDisplay =
        visit.branchName.isNotEmpty ? visit.branchName : visit.branchId;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date & Time + Branch Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_available,
                              size: 17, color: Color(0xFF1E88E5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatDateTime(visit.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_pin,
                              size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Attended by: Dr. ${visit.vetName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Branch Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF1E88E5).withAlpha(50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_city_rounded,
                        size: 14,
                        color: Color(0xFF1E88E5),
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          branchDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Clinical Diagnosis / Notes
            const Text(
              'Diagnosis & Clinical Notes:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              visit.notes,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),

            // Vaccination Administered (if any)
            if (visit.vaccination.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.vaccines, size: 18, color: Colors.teal),
                  const SizedBox(width: 6),
                  const Text(
                    'Vaccine:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Chip(
                    backgroundColor: Colors.teal.shade50,
                    side: BorderSide(color: Colors.teal.shade200),
                    label: Text(
                      visit.vaccination,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Medications Prescribed
            if (visit.medications.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Prescribed Medications:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: visit.medications.map((m) {
                  return Chip(
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    label: Text(
                      m,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Follow-Up Date (if scheduled)
            if (visit.nextFollowUpDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      'Next Follow-Up: ${_formatDateOnly(visit.nextFollowUpDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisitsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.history_edu_outlined,
              size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No Clinical Visits Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'When any clinic branch records a visit, it will appear here in real-time with full doctor & branch details.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
