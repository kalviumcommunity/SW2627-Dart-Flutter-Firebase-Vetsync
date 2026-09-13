import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a Veterinary Clinic Branch in the VetSync network.
class Branch {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String operatingHours;
  final bool isMainBranch;

  const Branch({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    this.operatingHours = '09:00 AM - 08:00 PM',
    this.isMainBranch = false,
  });

  /// Factory constructor to deserialize a Firestore document snapshot.
  factory Branch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Branch(
      id: doc.id,
      name: data['name'] ?? 'Branch Clinic',
      city: data['city'] ?? 'Central',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      operatingHours: data['operatingHours'] ?? '09:00 AM - 08:00 PM',
      isMainBranch: data['isMainBranch'] ?? false,
    );
  }

  /// Deserialization from generic Map.
  factory Branch.fromMap(Map<String, dynamic> map, {String? id}) {
    return Branch(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? 'Branch Clinic',
      city: map['city'] ?? 'Central',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      operatingHours: map['operatingHours'] ?? '09:00 AM - 08:00 PM',
      isMainBranch: map['isMainBranch'] ?? false,
    );
  }

  /// Serializes the Branch object into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'phone': phone,
      'operatingHours': operatingHours,
      'isMainBranch': isMainBranch,
    };
  }

  /// Curated list of default VetSync clinic branches across major regions.
  static const List<Branch> defaultBranches = [
    Branch(
      id: 'BRANCH_DELHI',
      name: 'Delhi Central Clinic',
      city: 'Delhi NCR',
      address: 'Plot 42, Connaught Place, New Delhi - 110001',
      phone: '+91 11 2345 6789',
      operatingHours: '24/7 Emergency & Outpatient',
      isMainBranch: true,
    ),
    Branch(
      id: 'BRANCH_MUMBAI',
      name: 'Mumbai Pet Specialty Hospital',
      city: 'Mumbai',
      address: '14 Bandra West, Linking Road, Mumbai - 400050',
      phone: '+91 22 4567 8901',
      operatingHours: '08:00 AM - 10:00 PM',
    ),
    Branch(
      id: 'BRANCH_BLR',
      name: 'Bengaluru Veterinary Care Center',
      city: 'Bengaluru',
      address: '88 Indiranagar 100 Feet Rd, Bengaluru - 560038',
      phone: '+91 80 3456 7890',
      operatingHours: '09:00 AM - 09:00 PM',
    ),
    Branch(
      id: 'BRANCH_CHENNAI',
      name: 'Chennai Companion Animal Clinic',
      city: 'Chennai',
      address: '25 Anna Nagar East, 2nd Avenue, Chennai - 600102',
      phone: '+91 44 2626 1234',
      operatingHours: '08:30 AM - 08:30 PM',
    ),
    Branch(
      id: 'BRANCH_HYD',
      name: 'Hyderabad Pet Care & Trauma Center',
      city: 'Hyderabad',
      address: 'Road No. 36, Jubilee Hills, Hyderabad - 500033',
      phone: '+91 40 6789 0123',
      operatingHours: '24/7 Emergency & General Care',
    ),
    Branch(
      id: 'BRANCH_PUNE',
      name: 'Pune Advanced Vet Clinic',
      city: 'Pune',
      address: 'Koregaon Park Main Road, Lane 5, Pune - 411001',
      phone: '+91 20 2612 9876',
      operatingHours: '09:00 AM - 08:00 PM',
    ),
    Branch(
      id: 'BRANCH_KOLKATA',
      name: 'Kolkata Animal Health & Diagnostics',
      city: 'Kolkata',
      address: 'Park Street Cross, Salt Lake Sector V, Kolkata - 700091',
      phone: '+91 33 2289 5432',
      operatingHours: '09:00 AM - 07:30 PM',
    ),
  ];
}
