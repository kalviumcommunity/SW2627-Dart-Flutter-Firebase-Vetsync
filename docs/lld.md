# VetSync — Low-Level Design (LLD)

## 1. Introduction
This document provides the Low-Level Design (LLD) for VetSync, detailing the architecture, database schema, data models, components, and module interactions based on the PRD and HLD.

## 2. System Architecture Overview
VetSync follows a standard Flutter + Firebase layered architecture.

- **Presentation Layer:** Flutter Widgets and Screens (`lib/screen/`).
- **State Management Layer:** Uses Flutter `StreamBuilder` for real-time reactivity and core state management.
- **Service/Repository Layer:** Handles communication with Firebase Auth and Firestore (`lib/repositories/`).
- **Data Model Layer:** Dart classes mapping to Firestore documents (`lib/models/`).

## 3. Database Schema (Firestore)

### `pets` Collection
Stores core details about the pet, shared across all clinic branches.
- `petId` (String) - Document ID
- `name` (String) - Pet's name
- `species` (String) - e.g., Dog, Cat
- `breed` (String) - Breed of the pet
- `ownerName` (String) - Name of the pet owner
- `dob` (Timestamp) - Date of birth

### `visits` Collection
Stores individual visit records tied to a pet and branch.
- `visitId` (String) - Document ID
- `petId` (String) - Reference to `pets` document
- `branchId` (String) - Reference to `branches` document
- `vetId` (String) - Reference to `vets` document
- `date` (Timestamp) - Visit date and time
- `notes` (String) - Clinical notes
- `medications` (Array<String>) - List of administered or prescribed medications
- `vaccination` (String) - Name of vaccination administered (if any)
- `nextFollowUpDate` (Timestamp) - Scheduled date for the next follow-up

### `branches` Collection
Stores clinic branch locations.
- `branchId` (String) - Document ID
- `name` (String) - Branch name (e.g., Downtown Clinic)
- `location` (String) - Physical address or location details

### `vets` Collection
Stores veterinarian details.
- `vetId` (String) - Document ID (Matches Firebase Auth UID)
- `name` (String) - Veterinarian's full name
- `branchId` (String) - Primary branch assignment

## 4. Class Diagrams / Data Models (Dart)

### `Pet` Model
```dart
class Pet {
  final String petId;
  final String name;
  final String species;
  final String breed;
  final String ownerName;
  final DateTime dob;
  
  // fromMap() and toMap() methods for Firestore
}
```

### `Visit` Model
```dart
class Visit {
  final String visitId;
  final String petId;
  final String branchId;
  final String vetId;
  final DateTime date;
  final String notes;
  final List<String> medications;
  final String vaccination;
  final DateTime? nextFollowUpDate;

  // fromMap() and toMap() methods for Firestore
}
```

## 5. UI & Widget Tree

### Screen Structure
1. **LoginScreen:** Authenticates vet using `FirebaseAuth.instance.signInWithEmailAndPassword`.
2. **SearchScreen:** Top-level screen post-login. Contains a `TextField` for search input and a `ListView` mapping to a `pets` query.
3. **PetDetailScreen:** Displays pet info and a `StreamBuilder` listening to `visits` where `petId == currentPet.id`.
4. **AddVisitScreen:** Form with `TextFormField`s and `DatePicker` for logging a new visit. Calls `FirestoreService.addVisit()`.

## 6. Business Logic & Flags

### Overdue Follow-up Flag
Computed locally in the app:
- Iterate over the pet's past visits to find the most recent `nextFollowUpDate`.
- If `nextFollowUpDate < DateTime.now()`, display an overdue warning banner.

### Recent Medication Flag
- Filter `visits` from the past N days.
- If `medications` array is non-empty, display recent medications given to prevent duplicates.

## 7. Security Rules (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // Base rule: Must be authenticated
      allow read, write: if request.auth != null;
    }
  }
}
```
