# VetSync — High-Level Design (HLD)

## 1. Project Overview

VetSync is a centralized veterinary health-record mobile application designed for veterinary clinic chains operating across multiple branches.

Currently, each clinic branch may maintain its own vaccination history and treatment records. When a pet visits another branch, the attending veterinarian may not have access to the pet's previous medical history.

VetSync solves this problem by providing a centralized system where authorized veterinary staff can access and manage a pet's medical records across clinic branches.

---

# 2. Problem Statement

A chain of veterinary clinics operates across multiple branches, but each clinic maintains its own records for vaccination history and treatment notes.

When a pet owner visits a different branch, the attending vet has no access to prior history, increasing the risk of:

- Duplicate medication
- Duplicate vaccinations
- Missed follow-ups
- Incomplete treatment decisions
- Loss of important medical history
- Poor coordination between clinic branches

VetSync provides a centralized digital record for every pet so authorized veterinary staff can access its medical history regardless of which branch previously treated the pet.

---

# 3. Goals

The main goals of VetSync are:

1. Centralize veterinary medical records.
2. Allow authorized veterinary staff to access pet history.
3. Maintain vaccination history.
4. Maintain treatment history.
5. Allow vets to add and update medical records.
6. Allow vets to search for pets.
7. Reduce duplicate medication and vaccinations.
8. Reduce missed follow-ups.
9. Provide a simple mobile-first interface.
10. Protect medical records using authentication and database security rules.

---

# 4. Target Users

## Primary Users

### Veterinary Staff / Veterinarians

They can:

- Create an account
- Log in
- View pets
- Search for pets
- Add pets
- View pet details
- View vaccination history
- Add vaccination records
- View treatment history
- Add treatment records
- Update records

## Future Users

### Pet Owners

Potential future functionality:

- View their pet's medical history
- View upcoming vaccinations
- View treatment records
- Receive follow-up reminders

Pet-owner functionality is outside the initial MVP unless required by the project scope.

---

# 5. MVP Scope

The first version of VetSync will focus on the core problem.

### Authentication

- Signup
- Login
- Logout
- Persistent login

### Pet Management

- View pets
- Add pet
- View pet details
- Search pets

### Medical Records

- View vaccination history
- Add vaccination record
- View treatment history
- Add treatment record

### Security

- Firebase Authentication
- Firestore Security Rules
- Authenticated access to medical data

---

# 6. Technology Stack

## Frontend

### Flutter

Flutter will be used to build the cross-platform mobile application.

Flutter is responsible for:

- UI
- Navigation
- Forms
- User interaction
- State management
- Displaying Firebase data

---

## Programming Language

### Dart

Dart is used to write the Flutter application.

It will be used for:

- Widgets
- Models
- Services
- Business logic
- Async operations
- Firebase integration

---

## Backend / Cloud Platform

### Firebase

Firebase will provide the backend infrastructure.

The main Firebase services used are:

### Firebase Authentication

Used for:

- Signup
- Login
- Logout
- User identity
- Authentication state

### Cloud Firestore

Used for:

- Users
- Clinics
- Pets
- Vaccinations
- Treatments

### Firebase Storage

Used for:

- Pet images
- Medical documents
- Other supported files

---

# 7. High-Level Architecture

The application follows a Flutter + Firebase architecture.

```text
                    VETSYNC
                       |
                       v
                Flutter Mobile App
                       |
              +--------+--------+
              |        |        |
              v        v        v
              UI     Services  Models
              |        |        |
              +--------+--------+
                       |
                       v
                  Firebase SDK
                       |
       +---------------+---------------+
       |               |               |
       v               v               v
 Firebase Auth    Cloud Firestore   Firebase Storage
       |               |               |
       v               v               v
    Users          Medical Data      Files