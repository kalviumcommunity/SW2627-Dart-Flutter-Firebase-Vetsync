📄 Product Requirements Document (PRD)

VetRecords

Version: 1.0
Project: Mobile App Development (Sprint 2)
Duration: 25 Working Days (5 Weeks)
Team Size: [Fill in]

## Table of Contents

1. Executive Summary
2. Business Problem
3. Stakeholders
4. Business Impact
5. Vision & Objectives
6. Dataset
7. KPIs
8. User Stories
9. Scope
10. Features
11. Requirements
12. App Structure
13. Technology Stack
14. Database Design
15. API / Firestore Operations Overview
16. Workflow
17. Security
18. Risks
19. Timeline
20. Future Scope
21. Validation Checklist

---

## 1. Executive Summary

VetRecords is a cross-branch pet medical record platform that lets veterinarians at any clinic branch instantly look up a pet's complete vaccination and treatment history, add new visit records, and be alerted to overdue follow-ups — regardless of which branch originally treated the pet.

The project digitizes what is currently a fragmented, per-branch paper/local-record system, removing the risk of duplicate medication and missed follow-ups that comes from vets working without full context.

## 2. Business Problem

### Problem Statement

A chain of veterinary clinics operates across multiple branches, but each branch maintains its own records for vaccination history and treatment notes. When a pet owner visits a different branch, the attending vet has no access to prior history, increasing the risk of duplicate medication and missed follow-ups.

### Primary Users

- Veterinarians (across all branches)
- Clinic front-desk / support staff (secondary, if included)
- Pet owners (out of scope for MVP — see Future Scope)

### Project Assumptions

- Each branch currently keeps records locally, with no shared visibility across branches.
- A pet is likely to visit more than one branch over its lifetime (relocation, convenience, availability).
- Vets currently rely on the owner's memory or paper records when treatment history from another branch is needed — both are unreliable.
- A shared, searchable record removes the manual back-and-forth of calling another branch to check history.

*Note: These are project assumptions for the MVP and not official clinic-chain metrics.*

### Success Criteria

Within the 5-week sprint:

- A vet can locate any pet's record, from any branch, in under 30 seconds.
- 100% of visits recorded at any branch are visible to every other branch in real time.
- Overdue follow-ups and recent medications are surfaced automatically, without the vet needing to read the entire history manually.

## 3. Stakeholders

| Stakeholder | Responsibility |
|---|---|
| Vets | Search pet records, view cross-branch history, log new visits |
| Clinic branches | Source and consumer of shared pet data |
| Pet owners | Beneficiaries of safer, more informed treatment (indirect, MVP is vet-facing) |
| Mentor / Reviewer | Approves PRD and System Design before build phase begins |

## 4. Business Impact

**Operational**
- Faster, more informed treatment decisions
- Centralized pet medical records instead of siloed per-branch data
- Reduced risk of clinical error from missing history

**Business**
- Reduced liability from duplicate medication or missed follow-up incidents
- Higher owner trust in the clinic chain as a coordinated network, not disconnected branches

**Customer (Pet Owner) Experience**
- Owners no longer need to carry paperwork or recall past treatment when switching branches
- Continuity of care regardless of which branch is visited

## 5. Vision & Objectives

### Vision

Build a reliable, real-time shared record system so that a pet's medical history follows it across every branch of the clinic — not just the one that first treated it.

### Objectives

**Clinical**
- Instant, accurate access to a pet's full treatment and vaccination history
- Automatic flags for overdue follow-ups and recently given medication

**Business**
- Digitize and centralize what is currently fragmented, branch-local record-keeping
- Build a data model that scales cleanly to more branches without structural change

## 6. Dataset

| | |
|---|---|
| Source | Firebase (Firestore) |
| Owner | Clinic Administration |
| Access Layer | Firebase SDK (Flutter) |

**Collections**
- `pets`
- `visits`
- `branches`
- `vets`

**Key Fields**
- `petId`, `ownerName`, `species`, `breed`, `dob`
- `branchId`, `vetId`, `date`
- `notes`, `medications[]`, `vaccination`
- `nextFollowUpDate`

**Data Quality**
- Unique `petId` per pet, shared across all branches (no per-branch duplication)
- Every `visit` document tagged with the `branchId` that recorded it
- Firestore Security Rules enforcing who can read/write which documents
- Real-time listeners (`StreamBuilder`) for instant cross-branch visibility

## 7. KPI & Success Metrics

| KPI | Target | Timeline |
|---|---|---|
| Pet lookup response | ≤2 sec | Launch |
| Cross-branch visit visibility | 100% real-time | Launch |
| Search success rate | ≥95% | End of sprint |
| Overdue follow-up flag accuracy | 100% | Continuous |

## 8. User Stories

**Vet**

- US-01: As a vet, I want to search for a pet by name or owner so that I can find their record quickly, regardless of which branch they were last treated at.
- US-02: As a vet, I want to view a pet's full visit history across all branches so that I have complete context before treating them.
- US-03: As a vet, I want to be warned if a follow-up is overdue so that I don't miss necessary care.
- US-04: As a vet, I want to be warned if a medication was recently given so that I avoid prescribing a duplicate.
- US-05: As a vet, I want to add a new visit record (notes, medication, vaccination, follow-up date) so that other branches have accurate, up-to-date information.

**System / Admin (if included)**

- US-06: As an admin, I want to manage the list of branches and vets so that records are correctly attributed.

## 9. Product Scope

### ✅ In Scope (MVP)

**Vet-facing**
- Login
- Pet search (cross-branch)
- Pet detail / full visit timeline
- Overdue follow-up flag
- Recent-medication flag
- Add new visit record

### ❌ Out of Scope (MVP)

- Pet owner accounts / owner-facing app
- Appointment booking or scheduling
- Push notifications / reminders
- Photo or lab report uploads
- Branch/admin management dashboard
- Automated drug-interaction checking (beyond a recency flag)

*(Candidates for Future Scope if the team finishes early.)*

## 10. Product Features

| Feature | Description |
|---|---|
| Login | Vet authentication via Firebase Auth |
| Pet Search | Search across all branches by pet name, owner, or ID |
| Pet Detail / Timeline | Full chronological visit history, branch-tagged |
| Overdue Follow-Up Flag | Automatic alert when a scheduled follow-up date has passed |
| Recent Medication Flag | Surfaces recently given medication to reduce duplicate-prescription risk |
| Add Visit | Form to log a new visit — notes, medications, vaccination, follow-up date |
| Real-Time Sync | New visits appear instantly to vets at any branch |
| Responsive Mobile UI | Works across device sizes, tested on emulator and physical device |

## 11. Functional & Non-Functional Requirements

**Functional**
- Authenticate vets before granting access to any pet record.
- Validate and search pets across all branches, not just one.
- Display a pet's complete visit history in chronological order, tagged by branch.
- Flag overdue follow-ups and recently administered medication.
- Allow a vet to add a new visit record with structured fields.
- Sync new visit records to all branches in real time.

**Non-Functional**
- Pet lookup response ≤2 seconds.
- Responsive UI across common device sizes.
- Secure authentication (Firebase Auth).
- Firestore Security Rules enforced on every read/write.
- App tested on an emulator or physical device daily — not just before showcase.

## 12. App Structure (Screens)

| Screen | Purpose |
|---|---|
| Login | Vet authentication |
| Search | Search bar + list of matching pets |
| Pet Detail / Timeline | Pet info, alerts banner, full cross-branch visit history |
| Add Visit | Form to log a new visit for the selected pet |

## 13. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter | Cross-platform mobile UI, widget tree |
| Language | Dart | App logic |
| Backend / Database | Firebase Firestore | Real-time NoSQL store for pets, visits, branches, vets |
| Authentication | Firebase Auth | Vet login (email/password) |
| Persistence | Firebase Auth persistent session | Stay signed in between app launches |
| File Storage (future) | Firebase Storage | Photos / lab reports (Future Scope) |
| Version Control | Git & GitHub | Source control, daily commits and PRs |
| Repository Host | GitHub (KalviumCommunity) | Team repo, PR review, Kanban board |

## 14. Database Design (Firestore)

**Collections & Key Fields**

`pets`
- `petId`, `name`, `species`, `breed`, `ownerName`, `dob`

`visits`
- `visitId`, `petId`, `branchId`, `vetId`, `date`, `notes`, `medications[]`, `vaccination`, `nextFollowUpDate`

`branches`
- `branchId`, `name`, `location`

`vets`
- `vetId`, `name`, `branchId`

**Relationships**

```
pets
 └── has many
      visits (tagged with branchId + vetId)

branches
 └── has many
      vets

branches
 └── referenced by
      visits.branchId
```

**Design Principle:** A pet's record is one shared document tree across the entire clinic chain. `branchId` is a field on each `visit`, never a separate database per branch — this is the direct fix for the stated problem.

## 15. Firestore Operations Overview

| Operation | Trigger | Purpose |
|---|---|---|
| Auth sign-in | Vet login screen | Authenticate vet, start session |
| Query `pets` | Search screen | Find pets by name/owner across all branches |
| Stream `visits` where `petId == X` | Pet detail screen | Real-time, cross-branch visit history |
| Create `visits` document | Add Visit form | Log a new visit, instantly synced |
| Read `branches` / `vets` | Various | Resolve branch name and vet display info |

## 16. Application Workflow

```
Vet
 │
 ▼
Login (Firebase Auth)
 │
 ▼
Search Pet (Firestore query, all branches)
 │
 ▼
Pet Detail — Stream visits (StreamBuilder)
 │
 ▼
Overdue / Recent-Medication Flags Computed
 │
 ▼
Add New Visit → Firestore write
 │
 ▼
Instantly visible to all branches
```

## 17. Security

- Firebase Authentication (email/password) for all vets
- Firestore Security Rules — vets can read all pet/visit records, write only as themselves (`vetId` matches authenticated user)
- No public/unauthenticated access to any collection
- Persistent session handled via Firebase Auth, not stored manually
- Input validation on all form fields before writing to Firestore

## 18. Risk Analysis

| Risk | Impact | Mitigation |
|---|---|---|
| Poorly shaped Firestore data model | Expensive rework mid-build | Finalize and get model approved before Phase 4 (building) |
| Treating Flutter's widget/state model like the web DOM | Wasted rework, timeline slip | Team ramps on Flutter fundamentals in Week 1 before writing screens |
| Never testing on a real device/emulator until showcase | Late discovery of breaking bugs | Build, run, and test on device/emulator every day |
| Ambiguous owner-vs-vet-only login scope | Rework of auth and screens | Decide and document in PRD before build starts |
| Overly permissive Firestore rules | Data exposure risk | Explicit read/write rules scoped to authenticated vets only |

## 19. Sprint Timeline

| Week | Deliverables |
|---|---|
| Week 1 | Learning phase, team setup, PRD + System Design submitted and approved |
| Week 2 | Firebase Auth, Firestore schema implemented, Search screen |
| Week 3 | Pet Detail / Timeline screen, real-time sync, Add Visit form |
| Week 4 | Overdue/recent-medication flags, polish, edge-case handling |
| Week 5 | Testing on device/emulator, showcase prep, documentation |

## 20. Future Scope

- Pet owner accounts with view-only access to their own pet's records
- Appointment booking
- Photo / lab report upload (Firebase Storage)
- Push notification reminders for upcoming follow-ups
- Branch/admin management dashboard
- Automated drug-interaction checking beyond a recency flag

## 21. Mapping to Sprint Concepts

| Area | Concepts Covered |
|---|---|
| Foundations | Concepts 1–14 |
| Authentication | Concepts 18–23, 37 (Firebase Auth, persistent login) |
| Firestore CRUD | Concepts 24–31 |
| Real-Time Updates | Concept 32 |
| Search & Filtering | Concept 40 |
| Storage (Future Scope) | Concepts 35–36 |

## Validation Checklist

- ✅ Business problem clearly defined
- ✅ Stakeholders identified
- ✅ KPIs measurable
- ✅ User stories follow Role → Action → Benefit
- ✅ MVP scope defined
- ✅ Features documented
- ✅ Functional & Non-functional requirements included
- ✅ Technology stack finalized
- ✅ Database design documented
- ✅ Risks identified
- ✅ Security planned
- ✅ Sprint timeline prepared
- ⬜ Owner-vs-vet-only scope confirmed with mentor
- ⬜ Firestore Security Rules reviewed in detail

## Conclusion

VetRecords replaces fragmented, per-branch pet records with a single shared source of truth, so any vet at any branch can treat a pet with full historical context. Built on Flutter and Firebase, the MVP prioritizes the one flow that solves the stated problem — search, view cross-branch history, add a visit — while leaving owner accounts, notifications, and admin tooling as clearly scoped future work.