# ⏳ HourGlass

A simple, secure, and privacy-respecting time tracker that gets the job done without getting in your way.

<p align="center">
  <img src="icon.no-bg.cyan.svg" alt="HourGlass Icon" width="128" height="128" />
</p>

<p align="center">
  <b>HourGlass</b> is an offline-first, mobile-first time tracking tool. It is designed for developers, freelancers, and professionals who need to keep accurate time sheets without compromising their personal data or suffering from over-engineered, cluttered layouts.
</p>

---

## ✨ Features at a Glance

### ⏱️ High-Speed Parallel Timers
* **Parallel Tracking:** Manage multiple ongoing tasks at once. Start, pause, resume, edit, or delete timers with a single tap.
* **Project Associations:** Organize your logs by tagging timers with custom-colored project blocks.

### 🔒 Uncompromising Data Privacy
* **100% Offline-First:** No accounts required, no internet dependency, and absolutely zero background analytics or tracking.
* **Database Backups:** Export and import the app's entire SQLite database with one click for full ownership of your records.

### 🌐 Global Localization
* **15+ Languages Supported:** Available in English, Spanish, French, German, Portuguese, Hindi, Japanese, Russian, Chinese, Italian, Czech, Norwegian, Indonesian, and more.

### 📊 Premium Feature: Weekly Visual Productivity Reports [Phase 4 Update]
HourGlass includes a beautiful **Productivity Dashboard and PDF Exporter** to compile your hours into client-ready sheets:

> [!TIP]
> **Client-Ready Reports:** Generate rich, multi-page PDF time summaries featuring graphical time-share charts and formatted ledger tables entirely offline.

---

## 🏗️ Architectural Blueprint

The productivity reporting and PDF rendering module is structured under `lib/features/productivity_reports/` using strict **Clean Architecture** and SOLID design rules:

```
lib/features/productivity_reports/
├── domain/
│   ├── models/           # Immutable ProductivitySummary and ChartSlice entities
│   └── repositories/     # Repository contracts defining weekly aggregates and PDF render pipelines
├── data/
│   ├── datasources/      # Raw SQLite queries compiling timespans and vector graphics generators
│   └── repositories/     # Concrete repository implementations invoking document writing APIs
└── presentation/
    ├── controllers/      # BLoC cubits managing dashboard statistics and export triggers
    ├── pages/            # High-fidelity visual dashboard page
    └── widgets/          # Tabular grids, progress rings, and animated project cards
```

---

## 🛠️ Setup & Installation

### Requirements
* **Flutter SDK:** Latest Stable Channel
* **Dart SDK:** Latest Stable Channel

### Step-by-Step Run Guide
1. Clone the repository:
   ```bash
   git clone https://github.com/hamaluik/HourGlass.git
   cd HourGlass
   ```
2. Fetch required dependencies:
   ```bash
   flutter pub get
   ```
3. Run the static code analyzer:
   ```bash
   flutter analyze
   ```
4. Compile production release:
   ```bash
   flutter build apk --release
   ```

---

## 📄 License
HourGlass is open-source software licensed under the **Apache-2.0 License**. See [LICENSE](LICENSE) for more details.
Contributions and feature bug reports are welcome!
