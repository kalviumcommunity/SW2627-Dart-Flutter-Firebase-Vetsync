# 📄 Product Requirements Document (PRD) — VetSync

**Product Name:** VetSync  
**Tagline:** Centralized Veterinary Medical Records & Cross-Branch Clinical Synchronization Platform  
**Version:** 2.0  
**Project:** Mobile App Development (Sprint 2 — Team Pioneers)  
**Duration:** 25 Working Days (5 Weeks)  
**Target Platform:** Mobile (iOS / Android / Flutter Web)  

---

## 1. Executive Summary

VetSync is a cross-branch veterinary Electronic Health Record (EHR) platform that allows veterinarians at any clinic branch to instantly look up a pet's complete medical history, vaccination timeline, and treatment notes, add new visit records, and be alerted in real-time to overdue follow-ups and recent cross-branch prescriptions.

The application digitizes and centralizes what has historically been a fragmented, branch-isolated record-keeping system, eliminating clinical hazards such as duplicate medication, redundant vaccinations, and missed post-operative follow-ups.

---

## 2. Business Problem & User Personas

### 2.1 Problem Statement
A chain of veterinary clinics operates across multiple regional branches (e.g., Delhi, Mumbai, Bengaluru, Chennai, Hyderabad, Pune, Kolkata). Each branch traditionally maintains independent records. When a pet owner visits another branch:
1. **Lack of Historical Records:** Attending veterinarians have no access to prior diagnosis or surgical notes.
2. **Duplicate Medication Hazards:** Active prescriptions from another branch may be re-prescribed, causing toxicity.
3. **Redundant Vaccinations:** Over-vaccination occurs due to missing immunization records.
4. **Missed Critical Follow-Ups:** Post-operative and chronic follow-up dates are lost across branch visits.
5. **Operational Friction:** Staff must resort to manual phone calls and physical paperwork.

### 2.2 Primary User Persona: Attending Veterinarian
- **Goals:** Rapid patient chart lookup (< 2 seconds), instant overview of historical cross-branch visits, automated warnings for active medications and overdue follow-ups, and an intuitive interface to log new examinations and prescriptions.
- **Constraints:** High-paced clinic environment requiring high scanability, high contrast, clean typography, and fast mobile data entry.

---

## 3. Product Vision & Success Metrics (KPIs)

### Vision
To provide veterinary professionals with unified, zero-friction medical records so that patient care remains continuous, safe, and synchronized across every branch in the healthcare network.

### Success Metrics (KPIs)
| KPI | Target | Current Status |
| :--- | :--- | :--- |
| **Pet Lookup Response Time** | ≤ 2 seconds | ✅ Instant client-side reactive filtering & search |
| **Cross-Branch Synchronization** | 100% Real-Time | ✅ Cloud Firestore real-time `StreamBuilder` sync |
| **Search Accuracy** | ≥ 95% across fields | ✅ Multi-field matching (name, breed, owner, Pet ID, branch) |
| **Overdue Flag Accuracy** | 100% | ✅ Automated evaluation comparing timestamp with current time |
| **Duplicate Medication Alerts** | 100% detection (< 14d) | ✅ Automated `evaluateSafetyFlags` engine |

---

## 4. User Stories

### Epic 1: Staff Authentication & Security
- **US-01 (Login):** As a vet, I want to sign in with my email and password so that I can securely access confidential medical records.
- **US-02 (Staff Registration):** As a new veterinary doctor, I want to create an account and select my primary clinic branch.
- **US-03 (OTP Password Reset):** As a vet who forgot their password, I want to receive a 6-digit OTP in my email to securely reset my password.

### Epic 2: Centralized Patient Registry & Multi-Filter Search
- **US-04 (Cross-Branch Search):** As a vet, I want to search for a pet by name, breed, guardian, or ID so that I can instantly locate their file regardless of where they were originally registered.
- **US-05 (Branch Filtering):** As a vet, I want to filter the pet directory by clinic location (e.g., "All Clinics", "Delhi", "Mumbai") to view patients local to my current station.
- **US-06 (Patient Registration):** As a vet, I want to register a new animal with species, breed, age, gender, guardian details, and home clinic.

### Epic 3: Pet Medical Profile & Cross-Branch Timeline
- **US-07 (Patient Medical Header):** As a vet, I want to view a pet's summary card displaying species icon, age, gender, guardian name, Pet ID, and home clinic.
- **US-08 (Connected Medical Timeline):** As a vet, I want to inspect a chronological timeline of all past visits displaying the attending doctor, recording branch, clinical notes, vaccines given, and medications prescribed.
- **US-09 (Cross-Branch Attribution):** As a vet, I want each visit card to clearly display which clinic branch recorded it.

### Epic 4: Clinical Safety & Attention Flags
- **US-10 (Overdue Follow-Up Alert):** As a vet, I want to see a warning banner if a scheduled follow-up date has passed without evaluation.
- **US-11 (Recent Medication Warning):** As a vet, I want to see an alert detailing any medication prescribed across any branch within the last 14 days to prevent duplicate dosing.
- **US-12 (Clinical Alerts Hub):** As a vet, I want a dedicated view that aggregates all overdue patients and active medication regimens across the clinic network.

### Epic 5: Clinical Visit Recording
- **US-13 (Log Visit):** As a vet, I want to record a new visit including visit date/time, clinical notes & diagnosis, vaccination administered, interactive medication builder, and next follow-up date.
- **US-14 (Real-time Synchronization):** As a vet, I want my submitted visit to immediately appear in the medical timeline for any other branch reviewing the patient.

---

## 5. Scope

### ✅ In Scope (MVP)
- Veterinarian authentication (Sign In, Sign Up, Sign Out, 3-Step OTP Password Reset).
- Centralized cross-branch patient registry with real-time multi-field search and branch chips.
- Pet medical profile with connected cross-branch visit history timeline.
- Clinical Safety Flag Engine: Overdue follow-up evaluation and 14-day medication warnings.
- Clinical visit form with branch selection, date/time pickers, vaccine suggestions, and medication tag management.
- Multi-city clinic network with 7 pre-configured regional branches and doctor branch switching.
- Clinical dashboard with live metrics (Registered Pets, Today's Visits, Follow-ups Due, Branches) and recent cross-branch activity feed.

### ❌ Out of Scope (Future Releases)
- Pet owner facing client portal.
- Public appointment booking system.
- Push notifications / SMS gateway integration.
- Binary imaging attachment uploads (X-rays, lab PDFs).

---

## 6. Technical Specifications & Database Design

### Cloud Firestore Schema

#### `pets` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique Firestore Document ID |
| `name` | `string` | Pet name |
| `species` | `string` | Species (Dog, Cat, Bird, etc.) |
| `breed` | `string` | Breed description |
| `age` | `number` | Age in years |
| `ownerName` | `string` | Guardian / Owner full name |
| `gender` | `string` | Gender ('Male', 'Female', 'Unknown') |
| `branchId` | `string` | Registering clinic branch ID |
| `branchName` | `string` | Registering clinic branch name |
| `createdAt` | `timestamp` | Registration timestamp |

#### `visits` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique Firestore Document ID |
| `petId` | `string` | Foreign key referencing `pets/{id}` |
| `branchId` | `string` | Clinic branch ID where visit occurred |
| `branchName` | `string` | Clinic branch name |
| `vetId` | `string` | User ID of attending veterinarian |
| `vetName` | `string` | Name of attending veterinarian |
| `date` | `timestamp` | Date and time of clinical visit |
| `notes` | `string` | Diagnosis and examination observations |
| `medications` | `list<string>` | List of prescribed medications |
| `vaccination` | `string` | Vaccine administered (if any) |
| `nextFollowUpDate` | `timestamp?` | Scheduled next follow-up evaluation date |

#### `vets` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | `string` | Firebase Auth UID |
| `name` | `string` | Doctor full name |
| `email` | `string` | Doctor email address |
| `branchID` | `string` | Currently active clinic branch ID |
| `branchName` | `string` | Currently active clinic branch name |
| `role` | `string` | 'veterinarian' |
| `createdAt` | `timestamp` | Account creation timestamp |

#### `branches` Collection
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Branch identifier (e.g. `BRANCH_DELHI`) |
| `name` | `string` | Branch full name |
| `city` | `string` | Geographic city / region |
| `address` | `string` | Street address and postal code |
| `phone` | `string` | Contact phone number |
| `operatingHours` | `string` | Operational hours |
| `isMainBranch` | `boolean` | Flag for primary hub |

---

## 7. Security & Compliance

1. **Authentication Security:** Firebase Auth controls session persistence and password encryption.
2. **Firestore Security Rules:** Restricted read/write access ensuring only authenticated veterinary staff can query and write patient charts.
3. **Data Sanitization:** Input validation and human-readable error messages prevent exposure of raw exceptions.