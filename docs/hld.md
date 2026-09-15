# 🏗️ High-Level Design (HLD) — VetSync

**System:** VetSync Centralized Veterinary Health-Record Platform  
**Document Version:** 2.0  
**Target Architecture:** Flutter Client + Google Firebase Cloud Backend  
**Author:** Nirbhay Jakhar (Team Pioneers)  

---

## 1. Project Overview & Architectural Topology

VetSync is a centralized veterinary health-record mobile application designed for veterinary clinic chains operating across multiple regional branches.

The application follows a clean, reactive Flutter + Firebase architecture, decoupling UI components, business logic services, data models, and cloud persistence.

```mermaid
graph TD
    subgraph Client_Layer [Flutter Client Application]
        UI[Presentation Layer: Screens & Widgets]
        Theme[AppTheme & Design Tokens]
        Services[Business Logic & Service Layer]
        Models[Data Models: Pet, Visit, Branch]
        UI --> Theme
        UI --> Services
        Services --> Models
    end

    subgraph Firebase_Cloud_Layer [Firebase Cloud Platform]
        Auth[Firebase Authentication]
        Firestore[(Cloud Firestore NoSQL)]
        Rules[Firestore Security Rules]
    end

    subgraph External_Integrations [External APIs]
        Brevo[Brevo REST API - OTP Email Delivery]
    end

    Services -->|Auth & Session Persistence| Auth
    Services -->|Real-time Snapshot Streams| Firestore
    Services -->|Send 6-digit OTP Code| Brevo
    Firestore --- Rules
```

---

## 2. Architectural Layers

### 2.1 Presentation & UI Layer
- **Workstation Shell (`MainNavigationScreen`):** Manages a 4-tab `IndexedStack` keeping widget state persistent across tab transitions (**Dashboard**, **Patient Directory**, **Safety Alerts Hub**, **Doctor Profile**).
- **Theme & Design System (`lib/theme/`):** Centralizes all color tokens (`AppColors`), typography scales (`AppTextStyles`), elevation styles, button themes, and input decorations in `AppTheme`.
- **Component Library (`lib/widgets/`):** Reusable medical UI components (`ClinicBadge`, `SafetyFlagCard`, `MedicalTimelineTile`, `StatCard`, `EmptyStateView`).

### 2.2 Business Logic & Service Layer (`lib/services/`)
- **`AuthService`:** Manages user registration, email/password authentication, persistent auth streams (`authStateChanges`), session termination, and OTP integration.
- **`PetService`:** Handles patient document creation and real-time streaming (`streamAllPets()`, `streamPetsByBranch()`, `getPetById()`).
- **`VisitService`:** Manages cross-branch visit creation, real-time timeline streaming (`streamVisitsForPet()`), and runs the in-memory **Clinical Safety Flag Engine** (`evaluateSafetyFlags()`).
- **`BranchService`:** Streams clinic locations, provides fallback sync for offline regional clinics, and updates the attending veterinarian's active station in the `vets` Firestore collection.
- **`OtpService`:** Generates cryptographic 6-digit verification codes, handles REST delivery via Brevo with resilient fallback, verifies code validity with TTL expiration, and issues signed reset tokens.

### 2.3 Data Layer & Models (`lib/models/`)
- Strongly-typed Dart data classes (`Pet`, `Visit`, `Branch`, `SafetyReport`, `RecentMedicationInfo`, `OtpResult`) equipped with `fromFirestore()`, `toMap()`, and factory deserializers.

---

## 3. Core Sequence Flows

### 3.1 Authentication & Reactive Session Gate (`AuthWrapper`)
```mermaid
sequenceDiagram
    autonumber
    actor Doctor
    participant App as Flutter App Root
    participant Wrapper as AuthWrapper
    participant Auth as AuthService (Firebase Auth)
    participant Nav as MainNavigationScreen
    participant Login as LoginScreen

    App->>Wrapper: Initialize App Root
    Wrapper->>Auth: Listen to authStateChanges Stream
    alt User is Authenticated
        Auth-->>Wrapper: Yields User object
        Wrapper->>Nav: Render MainNavigationScreen
    else User is Unauthenticated
        Auth-->>Wrapper: Yields null
        Wrapper->>Login: Render LoginScreen
    end
    Doctor->>Login: Submits credentials
    Login->>Auth: signInWithEmail(email, password)
    Auth-->>Wrapper: Emits updated User stream event
    Wrapper->>Nav: Auto-routes to Dashboard
```

### 3.2 Real-time Cross-Branch Visit Recording & Timeline Sync
```mermaid
sequenceDiagram
    autonumber
    actor DrA as Attending Vet (Delhi Branch)
    actor DrB as Attending Vet (Mumbai Branch)
    participant UI as AddVisitScreen
    participant VisitSvc as VisitService
    participant Firestore as Cloud Firestore ('visits')
    participant Timeline as PetDetailsScreen (Timeline)

    DrA->>UI: Fills Diagnosis, Meds, Vaccines, Follow-Up
    DrA->>UI: Clicks "Save & Synchronize Visit"
    UI->>VisitSvc: addVisit(petId, branchId, vetId, notes, meds, ...)
    VisitSvc->>Firestore: docRef.set(visit.toMap())
    Firestore-->>VisitSvc: Write Ack (Server Timestamp)
    UI-->>DrA: Display Success Snackbar & Pop Form
    Note over Firestore,Timeline: Firestore Snapshot Listener fires instantly
    Firestore-->>Timeline: Snapshot update emitted to StreamBuilder
    Timeline->>VisitSvc: evaluateSafetyFlags(visits)
    Timeline-->>DrB: Connected Timeline & Safety Flags update in Real Time
```

### 3.3 Clinical Safety Flag Engine
```mermaid
flowchart TD
    Start([Receive Visits for Pet]) --> Sort[Sort Visits by Date Descending]
    Sort --> CheckFollowUp{Latest Follow-Up in Past?}
    CheckFollowUp -- Yes --> SetOverdue[Set isFollowUpOverdue = true & extract overdueDate]
    CheckFollowUp -- No --> CheckMeds
    SetOverdue --> CheckMeds{Any Visits in Past 14 Days?}
    CheckMeds -- Yes --> ExtractMeds[Extract distinct medication names, prescribing branch, and doctor]
    CheckMeds -- No --> BuildReport
    ExtractMeds --> BuildReport[Construct SafetyReport]
    BuildReport --> RenderUI[Render SafetyFlagCard & Alerts Hub]
```

---

## 4. Database Schema & Firestore Security

### 4.1 Collection Relationships
```
[branches] (1) <─────── (N) [vets] (Active Branch Attribution)
     │
     │ (Attributed Home Branch)
     ▼
  [pets] (1) <────────── (N) [visits] (Cross-Branch Visits)
```

### 4.2 Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 5. Non-Functional Attributes

1. **Real-Time Responsiveness:** `StreamBuilder` pipelines reactively update medical charts within milliseconds of a Firestore write from any clinic location.
2. **Offline Resilience:** Static default branches provide uninterrupted local fallback if cloud network connectivity drops.
3. **Auditability:** Every recorded visit permanently encapsulates the timestamp, attending doctor name, and branch attribution.