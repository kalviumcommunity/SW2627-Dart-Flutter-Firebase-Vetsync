# VetConnect — Unified Pet Health Records System

A [Next.js / your stack] application that gives veterinary clinics shared access to a pet's vaccination history and treatment notes across all branches, flags potential duplicate medications, and helps vets stay on top of follow-ups — no matter which branch a pet is seen at.

Built by team **[Your Team Name]** for [Sprint/Project Name]. Full requirements in [`docs/PRD.md`](docs/PRD.md).

---

## Problem Statement

A chain of veterinary clinics operates across multiple branches, but each clinic maintains its own records for vaccination history and treatment notes. When a pet owner visits a different branch, the attending vet has no access to prior history — increasing the risk of duplicate medication and missed follow-ups.

## Solution

VetConnect centralizes every pet's medical records into a single system accessible from any branch, so vets always have the full picture before treating an animal.

## Features

- 🐾 **Unified Pet Profiles** — one record per pet, accessible across all branches
- 💉 **Vaccination History** — full log of past vaccines, dates, and due dates for the next one
- 📋 **Treatment Notes** — shared notes from every visit, at every branch
- ⚠️ **Duplicate Medication Alerts** — flags conflicting or repeated prescriptions before they're given
- 🔔 **Follow-Up Reminders** — tracks and notifies staff of pending follow-ups
- 🏥 **Multi-Branch Support** — built for clinic chains with several locations

## Tech Stack

- **Frontend:** [Next.js / React / your framework]
- **Backend:** [Node.js / Express / your framework]
- **Database:** [PostgreSQL / MongoDB / your DB]
- **Auth:** [NextAuth / JWT / your solution]
- **Deployment:** [Vercel / Render / your host]

## Getting Started

### Prerequisites

- Node.js (v18+)
- [Database] running locally or a connection string

### Installation

```bash
# Clone the repo
git clone <repository-url>
cd vetconnect

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env

# Run the development server
npm run dev
```

Visit `http://localhost:3000` to view the app.

## Project Structure