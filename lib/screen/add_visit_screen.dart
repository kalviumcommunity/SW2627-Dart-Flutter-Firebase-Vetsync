import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/visit_service.dart';
import 'package:vetsync/theme/app_colors.dart';
import 'package:vetsync/theme/app_text_styles.dart';

class AddVisitScreen extends StatefulWidget {
  final Pet pet;

  const AddVisitScreen({super.key, required this.pet});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final BranchService _branchService = BranchService();
  final VisitService _visitService = VisitService();

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _vaccinationController = TextEditingController();
  final TextEditingController _medicationInputController =
      TextEditingController();

  final List<String> _medicationsList = [];
  DateTime _visitDate = DateTime.now();
  DateTime? _nextFollowUpDate;

  String _vetName = 'Veterinarian';
  String _selectedBranchId = 'BRANCH_DELHI';
  String _selectedBranchName = 'Delhi Central Clinic';
  List<Branch> _availableBranches = Branch.defaultBranches;
  bool _isLoading = false;

  final List<String> _commonVaccines = [
    'Rabies',
    'DHPP (Distemper, Hepatitis, Parvovirus)',
    'Bordetella (Kennel Cough)',
    'FVRCP (Feline Viral Rhinotracheitis)',
    'Leptospirosis',
    'Deworming Protocol',
    'None / Not Applicable',
  ];

  final List<String> _commonMedications = [
    'Amoxicillin 250mg',
    'Metronidazole 100mg',
    'Meloxicam 1.5mg/ml',
    'Prednisone 5mg',
    'Cephalexin 500mg',
    'Carprofen 75mg',
    'Ear Drops (Otomax)',
    'Flea & Tick Prevention',
  ];

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
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('vets')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        final bId = data?['branchID'] ?? 'BRANCH_DELHI';
        final bName =
            data?['branchName'] ?? _branchService.getBranchByIdSync(bId).name;

        setState(() {
          _vetName = data?['name'] ?? user.displayName ?? 'Dr. Veterinarian';
          _selectedBranchId = bId;
          _selectedBranchName = bName;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesController.dispose();
    _vaccinationController.dispose();
    _medicationInputController.dispose();
    super.dispose();
  }

  void _addMedication(String med) {
    final trimmed = med.trim();
    if (trimmed.isNotEmpty && !_medicationsList.contains(trimmed)) {
      setState(() {
        _medicationsList.add(trimmed);
        _medicationInputController.clear();
      });
    }
  }

  Future<void> _pickVisitDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_visitDate),
      );

      setState(() {
        _visitDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _visitDate.hour,
          pickedTime?.minute ?? _visitDate.minute,
        );
      });
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _nextFollowUpDate = picked;
      });
    }
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = _authService.currentUser;

    try {
      await _visitService.addVisit(
        petId: widget.pet.id,
        branchId: _selectedBranchId,
        branchName: _selectedBranchName,
        vetId: user?.uid ?? 'unknown_vet',
        vetName: _vetName,
        visitDate: _visitDate,
        notes: _notesController.text,
        medications: _medicationsList,
        vaccination: _vaccinationController.text == 'None / Not Applicable'
            ? ''
            : _vaccinationController.text,
        nextFollowUpDate: _nextFollowUpDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Visit recorded for $_selectedBranchName and synced across branches!'),
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
          content: Text('Failed to save visit record: $e'),
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
        title: Text('Record Visit: ${widget.pet.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient Summary Strip
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryUltraSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.pets_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.pet.species} • ${widget.pet.breed} • Guardian: ${widget.pet.ownerName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Attending Doctor Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryUltraSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primarySoft),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attending Veterinarian: Dr. $_vetName',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              'Attributed Branch: $_selectedBranchName',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Clinical Visit Form Card
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
                      // Branch Selector
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBranchId,
                        decoration: const InputDecoration(
                          labelText: 'Clinic Branch of Visit *',
                          prefixIcon: Icon(Icons.location_city_rounded),
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

                      // Visit Date & Time Picker
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event_available_rounded,
                              color: AppColors.primary),
                          title: const Text(
                            'Visit Date & Time',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                          subtitle: Text(
                            '${_visitDate.day.toString().padLeft(2, '0')}/${_visitDate.month.toString().padLeft(2, '0')}/${_visitDate.year} at ${_visitDate.hour.toString().padLeft(2, '0')}:${_visitDate.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: TextButton.icon(
                            onPressed: _pickVisitDate,
                            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                            label: const Text('Change'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Clinical Notes & Diagnosis
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Clinical Notes & Diagnosis *',
                          hintText:
                              'e.g. Physical exam normal. Mild ear infection observed, cleaning performed. Vaccinated against Rabies.',
                          prefixIcon: Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please provide clinical notes'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Vaccination Administered
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _commonVaccines;
                          }
                          return _commonVaccines.where((v) => v
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _vaccinationController.text = selection;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          _vaccinationController.text = controller.text;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Vaccination Administered (Optional)',
                              hintText: 'Select or type vaccine name',
                              prefixIcon: Icon(Icons.vaccines_outlined),
                            ),
                            onChanged: (val) {
                              _vaccinationController.text = val;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Prescribed Medications Builder
                      const Text(
                        'PRESCRIBED MEDICATIONS',
                        style: AppTextStyles.overline,
                      ),
                      const SizedBox(height: 8),

                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _commonMedications;
                          }
                          return _commonMedications.where((med) => med
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _addMedication(selection);
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Add Medication',
                              hintText: 'Type dosage or pick common item',
                              prefixIcon: const Icon(Icons.medication_outlined),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded,
                                    color: AppColors.primary),
                                onPressed: () {
                                  _addMedication(controller.text);
                                  controller.clear();
                                },
                              ),
                            ),
                            onFieldSubmitted: (val) {
                              _addMedication(val);
                              controller.clear();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // Medications Chips
                      if (_medicationsList.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _medicationsList.map((med) {
                            return Chip(
                              backgroundColor: AppColors.primaryUltraSoft,
                              side: const BorderSide(color: AppColors.primarySoft),
                              avatar: const Icon(Icons.medication_rounded,
                                  size: 16, color: AppColors.primary),
                              label: Text(
                                med,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              deleteIcon: const Icon(Icons.cancel_rounded,
                                  size: 16, color: AppColors.textMuted),
                              onDeleted: () {
                                setState(() {
                                  _medicationsList.remove(med);
                                });
                              },
                            );
                          }).toList(),
                        )
                      else
                        const Text(
                          'No medications prescribed for this visit.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),

                      const SizedBox(height: 24),

                      // Next Follow-Up Date Scheduler
                      const Text(
                        'NEXT FOLLOW-UP DATE',
                        style: AppTextStyles.overline,
                      ),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.schedule_rounded,
                              color: AppColors.warning),
                          title: Text(
                            _nextFollowUpDate == null
                                ? 'No Follow-Up Scheduled'
                                : 'Scheduled: ${_nextFollowUpDate!.day}/${_nextFollowUpDate!.month}/${_nextFollowUpDate!.year}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _nextFollowUpDate != null
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _nextFollowUpDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_nextFollowUpDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: AppColors.textMuted, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _nextFollowUpDate = null;
                                    });
                                  },
                                ),
                              ElevatedButton(
                                onPressed: _pickFollowUpDate,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Pick Date',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Action
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitVisit,
                    icon: const Icon(Icons.cloud_upload_rounded),
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
                            'Save & Synchronize Visit',
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
