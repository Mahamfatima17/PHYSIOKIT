# 🦴 PhysioKit — Clinical Pocket Reference for Physiotherapy

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.9-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" />
  <img src="https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
  <img src="https://img.shields.io/badge/Status-Phase%201%20Complete-brightgreen" />
</p>

<p align="center">
  <b>A modern, offline-first Flutter Android app for physiotherapy students, DPT clinicians, and healthcare professionals.</b><br/>
  Built from <i>The Physiotherapist's Pocket Book</i> by Karen Kenyon & Jonathan Kenyon.
</p>

---

## 📱 What is PhysioKit?

**PhysioKit** transforms an entire physiotherapy clinical pocket reference into a beautiful, interactive mobile learning platform. It allows DPT students and practicing physiotherapists to:

- 🔍 **Search & browse 100+ clinical special tests** by anatomical region
- 📋 **Study structured test procedures** with patient & therapist positioning
- 🔖 **Bookmark favourites** and track learning progress automatically
- 📊 **View diagnostic stats** — sensitivity, specificity, and clinical notes per test
- 🌙 **Switch between pastel light and dark themes** optimised for night studying
- 🏆 **Earn learning badges** as you complete anatomical regions

> This is **Phase 1** of a 3-phase roadmap. All content works fully **offline** — no internet required.

---

## ✨ Features

### 🏠 Home Dashboard
- Personalised greeting with daily study motivation
- Quick-tap 2D interactive body map hotspots that deep-link to test categories
- Progress overview cards (tests studied, regions completed)
- Recently viewed tests with one-tap resume

### 📚 Test Library (100 Special Tests)
| Category | Tests |
|---|---|
| 🦴 Musculoskeletal | 85 tests |
| ⚡ Neurodynamic | 7 tests |
| 🧠 Neurological | 12 tests (Dermatomes, Myotomes, Reflexes, Cranial Nerves) |

Every test includes:
- **Purpose** — what the test diagnoses
- **Patient Position** — starting position for patient
- **Therapist Position** — clinician stance and grip
- **Step-by-Step Procedure** — broken into clear steps
- **Positive Sign** — exact clinical indicator
- **Clinical Notes** — significance and interpretation
- **Sensitivity & Specificity** — evidence-based accuracy stats
- **Textbook Reference** — source citation

### 📍 Anatomical Categories
- Cervical Spine · Shoulder · Elbow · Wrist & Hand
- Pelvis & SIJ · Hip · Knee · Ankle & Foot
- Vascular Tests · Neurology Section

### 🔖 Bookmarks & History
- Save favourite tests with one tap
- Full scrollable history log of recently viewed tests
- Clear history with one sweep

### 👤 Profile & Progress Tracker
- Student name, university, and DPT credential display
- Live progress percentage across all 100 tests
- Achievement badges: Quick Starter, Knee Specialist, Spine Explorer, Neuro Expert, Dedicated DPT

### ⚙️ Settings
- Pastel Dark Mode toggle
- Adjustable font size (12sp → 20sp)
- Language selection (English; Urdu unlocked in Phase 3)
- App credits and textbook disclaimer

### 🫀 Anatomy Tab (Phase 2 Teaser)
- Animated 3D teaser with orbiting glowing joint nodes
- Preview of upcoming interactive 3D Skeleton, Muscle Attachments, Nerve Overlays

---

## 🗺️ Development Roadmap

```
Phase 1 ✅ COMPLETE — Offline Clinical Reference
├── 100 structured special tests
├── SQLite local database + Hive settings storage
├── Interactive 2D body map
├── Progress tracking & badges
└── Dark/Light pastel theme

Phase 2 🔜 UPCOMING — Interactive 3D Anatomy Engine
├── 3D skeletal viewer (zoom, pan, rotate)
├── Muscle attachment overlays
├── Ligament integrity maps (ACL, PCL, LCL, MCL)
└── Dermatome / myotome nerve overlays

Phase 3 🔜 UPCOMING — AI & Multilingual
├── Urdu language translation
├── AI-assisted differential diagnosis suggestions
├── Voice-guided test procedure walkthrough
└── Cloud sync & collaborative learning
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter 3.41.9** | Cross-platform UI framework |
| **Dart** | Primary programming language |
| **SQLite (sqflite)** | Offline test database with full-text search |
| **Hive** | Lightning-fast local settings, bookmarks & progress |
| **Provider** | Reactive state management |
| **flutter_animate** | Smooth micro-animations throughout |
| **Google Fonts (Outfit + Inter)** | Medical-grade professional typography |
| **Material 3** | Modern card-based adaptive UI system |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.41.9 or later
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Mahamfatima17/PHYSIOKIT.git
cd PHYSIOKIT

# 2. Install dependencies
flutter pub get

# 3. Run on connected Android device
flutter run

# 4. Build release APK
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── database/
│   │   ├── db_helper.dart          # SQLite manager + seeder
│   │   └── initial_data.dart       # 100 structured tests dataset
│   ├── storage/
│   │   └── storage_helper.dart     # Hive boxes for settings/bookmarks
│   └── theme/
│       ├── colors.dart             # Pastel medical colour palette
│       └── theme.dart              # Light & dark Material 3 themes
├── models/
│   ├── special_test.dart           # Test entity model
│   └── user_profile.dart           # Profile/progress model
├── providers/
│   ├── learning_provider.dart      # Search, bookmarks, history, progress
│   └── theme_provider.dart         # Dark/light mode state
└── views/
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── main_layout.dart        # Bottom nav + tab switching
    │   ├── home_screen.dart        # Dashboard + body map
    │   ├── categories_screen.dart  # Region browser with progress
    │   ├── test_library_screen.dart
    │   ├── test_detail_screen.dart # 3-tab clinical guide
    │   ├── bookmarks_screen.dart
    │   ├── profile_screen.dart
    │   ├── settings_screen.dart
    │   └── anatomy_placeholder_screen.dart
    └── widgets/
        └── interactive_body_map.dart  # Custom painted silhouette hotspots
```

---

## 📖 Reference Material

All clinical content is based on:

> **"The Physiotherapist's Pocket Book — Essential Facts at Your Fingertips"** (2nd Edition)
> *Karen Kenyon BSc(Hons) MCSP, Jonathan Kenyon BSc(Hons) MCSP*
> Publisher: Churchill Livingstone / Elsevier

> ⚠️ **Disclaimer:** This application is designed for **educational and reference purposes only**. Always verify clinical findings using a comprehensive patient assessment. Not a substitute for professional medical advice.

---

## 👩‍💻 Developer

Built with ❤️ for the physiotherapy community.

- 🎓 Designed for DPT students and clinical practitioners
- 📱 Android-first, built with Flutter
- 🏥 100% offline — works without internet

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <i>PhysioKit — Study smarter. Treat better.</i>
</p>
