# VetSync — Centralized Cross-Branch Veterinary Medical Record Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.44.9-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-teal.svg)](LICENSE)

**VetSync** is a centralized veterinary health-record and clinic synchronization mobile application built with Flutter and Firebase. It provides veterinary clinics with instant, shared access to a pet's complete medical history, vaccination timeline, treatment notes, and automated clinical safety alerts across all clinic branches.

---
## Table of Contents
-> Problem Statement
-> Key Features
-> Tech Stack
-> Project Structure
-> Getting Started
-> Documentation
-> Team

---


## 🏥 Problem Statement

A chain of veterinary clinics operates across multiple branches, but traditionally each branch maintains its own local records for vaccination history and treatment notes. When a pet visits a different branch:
- The attending veterinarian has no access to prior history.
- Risk of **duplicate or conflicting medication** increases.
- Redundant vaccinations may be administered.
- Critical follow-up evaluations are missed across branch transitions.
- Coordination between branches relies on manual, error-prone phone calls and paperwork.

---

## 💡 Solution & Key Features

VetSync centralizes every pet's medical records into a single unified cloud database:

- 🐾 **Unified Pet Profiles** — One centralized digital record per pet, accessible across all branches in real-time.
- 💉 **Vaccination & Treatment History** — Full chronological medical record of past vaccines, clinical notes, attending doctor, and branch attribution.
- ⚠️ **Duplicate Medication & Recency Flags** — Automatically surfaces medications prescribed within the last 14 days across any branch to prevent duplicate dosing.
- 🔔 **Overdue Follow-Up Alerts** — Automatically tracks and alerts staff to missed or pending follow-up evaluations.
- 🏥 **Multi-Branch Network & Switching** — Built for multi-city clinic chains (Delhi, Mumbai, Bengaluru, Chennai, Hyderabad, Pune, Kolkata) with live doctor branch switching.
- 🔐 **Staff Authentication & 3-Step OTP Reset** — Secure Firebase authentication with email OTP verification.

---

## 🛠️ Tech Stack

- **Mobile Framework:** Flutter (Dart 3.x)
- **Authentication:** Firebase Authentication (Email/Password & OTP)
- **Database:** Cloud Firestore (Real-time sync via `StreamBuilder`)
- **Email Delivery:** Brevo REST API / OTP Service
- **Architecture:** Service-Repository Pattern with reactive streams

---

## 📁 Project Structure

```
VetSync/
├── docs/                      # Project Documentation
│   ├── prd.md                 # Product Requirements Document
│   ├── hld.md                 # High-Level Design (HLD)
│   └── lld.md                 # Low-Level Design (LLD)
├── lib/
│   ├── firebase_options.dart  # Firebase configuration
│   ├── main.dart              # App root & reactive AuthWrapper
│   ├── models/                # Data models (Pet, Visit, Branch)
│   ├── repositories/          # Repository data access layer
│   ├── screen/                # UI screens (Home, Pets, Details, Visits, Auth)
│   ├── services/              # Firebase & business services
│   ├── theme/                 # Centralized design system & tokens
│   └── widgets/               # Reusable UI component library
├── test/                      # Unit & Widget test suite
└── pubspec.yaml               # Dependencies & assets configuration
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.44.x or newer)
- Dart SDK (3.12.x or newer)
- Android Studio / VS Code

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/kalviumcommunity/SW2627-Dart-Flutter-Firebase-Vetsync.git
cd SW2627-Dart-Flutter-Firebase-Vetsync

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run application
flutter run
```

---

## 👥 Team Pioneers

| Name | Role |
| :--- | :--- |
| **Nirbhay Jakhar** | Lead Developer & Architect |
| **Satvik** | Collaborator |
| **Somya** | Collaborator |
