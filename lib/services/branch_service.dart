import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsync/models/branch.dart';
import 'package:vetsync/services/auth_service.dart';

/// Service for managing clinic branches and veterinarian branch selection.
class BranchService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  AuthService get _authService => AuthService();

  CollectionReference? get _branchesCollection {
    try {
      return _firestore.collection('branches');
    } catch (_) {
      return null;
    }
  }

  /// Streams list of all clinic branches from Firestore.
  /// If Firestore has no documents or is unavailable, returns the curated default branches.
  Stream<List<Branch>> streamBranches() {
    try {
      final collection = _branchesCollection;
      if (collection == null) {
        return Stream.value(Branch.defaultBranches);
      }
      return collection.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return Branch.defaultBranches;
        }
        return snapshot.docs.map((doc) => Branch.fromFirestore(doc)).toList();
      }).handleError((_) {
        return Branch.defaultBranches;
      });
    } catch (_) {
      return Stream.value(Branch.defaultBranches);
    }
  }

  /// Fetches all branches asynchronously, falling back to predefined branches.
  Future<List<Branch>> getBranches() async {
    try {
      final collection = _branchesCollection;
      if (collection != null) {
        final snapshot = await collection.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => Branch.fromFirestore(doc)).toList();
        }
      }
    } catch (_) {}
    return Branch.defaultBranches;
  }

  /// Fetches branch details by ID, or checks default branches.
  Branch getBranchByIdSync(String branchId) {
    try {
      return Branch.defaultBranches.firstWhere(
        (b) => b.id.toLowerCase() == branchId.toLowerCase(),
      );
    } catch (_) {
      return Branch(
        id: branchId,
        name: branchId,
        city: 'Branch',
        address: 'Clinic Location',
        phone: '',
      );
    }
  }

  /// Updates the active branch of the currently logged-in veterinarian.
  Future<void> updateCurrentVetBranch({
    required String branchId,
    required String branchName,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _firestore.collection('vets').doc(user.uid).set({
        'branchID': branchId,
        'branchName': branchName,
        'lastBranchSwitchedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
