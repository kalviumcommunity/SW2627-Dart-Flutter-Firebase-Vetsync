import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/models/pet.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/services/branch_service.dart';
import 'package:vetsync/services/visit_service.dart';

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
    'Bordetella',
    'FVRCP (Feline Viral Rhinotracheitis)',
    'Leptospirosis',
    'Deworming',
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
          content: Text(
              'Visit recorded for $_selectedBranchName and synced across branches! 🏥'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save visit record: $e'),
          backgroundColor: Colors.redAccent,
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
      appBar: AppBar(
        title: Text('New Visit: ${widget.pet.name}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branch & Doctor attribution banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, color: Color(0xFF1E88E5)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attending Veterinarian: Dr. $_vetName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Recording for: $_selectedBranchName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Clinic Branch Selector for Visit
                DropdownButtonFormField<String>(
                  initialValue: _selectedBranchId,
                  decoration: const InputDecoration(
                    labelText: 'Clinic Branch of Visit *',
                    prefixIcon: Icon(Icons.location_city_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableBranches.map((branch) {
                    return DropdownMenuItem(
                      value: branch.id,
                      child: Text(
                        '${branch.name} (${branch.city})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
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
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event_available,
                        color: Color(0xFF1E88E5)),
                    title: const Text(
                      'Visit Date & Time',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      '${_visitDate.day.toString().padLeft(2, '0')}/${_visitDate.month.toString().padLeft(2, '0')}/${_visitDate.year} at ${_visitDate.hour.toString().padLeft(2, '0')}:${_visitDate.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    trailing: TextButton.icon(
                      onPressed: _pickVisitDate,
                      icon: const Icon(Icons.edit_calendar, size: 16),
                      label: const Text('Change'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Clinical Notes & Diagnosis
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Clinical Notes & Diagnosis *',
                    hintText:
                        'e.g. Routine checkup, ear infection treated, dental scaling done.',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        _vaccinationController.text = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Prescribed Medications Section
                const Text(
                  'Prescribed Medications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Autocomplete<String>(
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
                            decoration: const InputDecoration(
                              labelText: 'Add Medication',
                              hintText: 'Type or pick from common list',
                              prefixIcon: Icon(Icons.medication_outlined),
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (val) {
                              _addMedication(val);
                              controller.clear();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Chips display
                if (_medicationsList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _medicationsList.map((med) {
                      return Chip(
                        avatar:
                            const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(med),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
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
                    'No medications added yet for this visit.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                const SizedBox(height: 24),

                // Next Follow-Up Date
                const Text(
                  'Next Follow-Up Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined,
                        color: Color(0xFF1E88E5)),
                    title: Text(
                      _nextFollowUpDate == null
                          ? 'No Follow-Up Scheduled'
                          : 'Scheduled: ${_nextFollowUpDate!.day}/${_nextFollowUpDate!.month}/${_nextFollowUpDate!.year}',
                      style: TextStyle(
                        fontWeight: _nextFollowUpDate != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_nextFollowUpDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _nextFollowUpDate = null;
                              });
                            },
                          ),
                        ElevatedButton(
                          onPressed: _pickFollowUpDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitVisit,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save & Sync Visit Record',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
