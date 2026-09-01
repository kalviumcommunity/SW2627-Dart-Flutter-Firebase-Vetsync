import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vetsync/services/auth_service.dart';
import 'package:vetsync/screen/pets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String vetName = "Loading...";
  String vetEmail = "";
  String branchID = "";
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    getVetProfile();
  }

  Future<void> getVetProfile() async {
    final user = _authService.currentUser;

    if (user == null) return;

    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection("vets").doc(user.uid).get();

      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>?;
        setState(() {
          vetName = data?["name"] ?? "Veterinarian";
          vetEmail = data?["email"] ?? user.email ?? "";
          branchID = data?["branchID"] ?? "Main Branch";
          _isLoadingProfile = false;
        });
      } else if (mounted) {
        setState(() {
          vetName = user.displayName ?? "Veterinarian";
          vetEmail = user.email ?? "";
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          vetName = "Veterinarian";
          vetEmail = user.email ?? "";
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out of VetSync?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      // AuthWrapper StreamBuilder automatically redirects to LoginScreen!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Color(0xFF1E88E5)),
            SizedBox(width: 8),
            Text("VetSync Hub", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isLoadingProfile ? "Welcome..." : "Welcome, Dr. $vetName 👨‍⚕️",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vetEmail,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              if (branchID.isNotEmpty) ...[
                const SizedBox(height: 8),
                Chip(
                  avatar: const Icon(Icons.location_on_outlined, size: 16),
                  label: Text(
                    "Branch: $branchID",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Text(
                "Centralized cross-branch veterinary health records at your fingertips.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PetsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.pets),
                  label: const Text(
                    "View Pets Records",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }
}