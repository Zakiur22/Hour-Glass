# ⏳ HourGlass


A simple, secure, and privacy-respecting time tracker that gets the job done without getting in your way.


**HourGlass** is an offline-first, mobile-first time tracking tool. It is designed for developers, freelancers, and professionals who need to keep accurate timesheets without compromising their personal data or suffering from over-engineered, cluttered layouts.


---


## 🎨 Premium Visual Theme & Time Tracker Aesthetics


HourGlass prides itself on a zero-clutter, utility-first user experience built on top of high-performance Material Design tokens:

* **Dark Mode & Dynamic Themes:** Toggle between dark, light, and black themes designed to minimize battery drain and reduce eye strain during late-night development sessions.
* **Fluid Floating Control Bar:** Start and stop tracking with an always-accessible, responsive timer widget that resides at the top of the interface.
* **Vibrant Project Colors:** Assign distinct, saturated colors to different clients or tasks to visually categorize your work list instantly.


---


## ✨ Key Features & User Guide


### ⏱️ High-Speed Parallel Timers

* **Parallel Tracking:** Manage multiple ongoing tasks at once. Start, pause, resume, edit, or delete timers with a single tap.
* **Project & Client Associations:** Organize your logs by tagging timers with custom-colored projects and category labels.
* **🔍 How to Access & Use:**
  1. On the home page, enter a description of the task you are currently working on in the top input box (e.g., "Designing UI Mockups").
  2. Tap the **Project** colored block next to the input field to assign the task to a client/project.
  3. Tap the green **Play** button to start the timer.
  4. The running timer will display at the top of the list with a ticking second counter.
  5. Tap the red **Stop** button to finish tracking. The entry is instantly saved to your local ledger list below.
  6. To edit or adjust a logged timer's start or end times, simply tap on that timer card to open the editor panel.


### 🔒 Uncompromising Data Privacy & Backups

* **100% Offline-First:** No accounts required, no internet dependency, and absolutely zero background analytics or tracking. Your data belongs to you.
* **Database Backups:** Export and import the app's entire SQLite database with one click for full ownership, migration, and physical backup of your records.
* **🔍 How to Access & Use:**
  1. Open the **Menu** (three lines) in the top corner.
  2. Select **Settings** and scroll down to the **Data Management** section.
  3. Tap **Export Database** to create a backup file containing your entire time log database. You can save this file to your device, iCloud, Google Drive, or send it to your computer.
  4. To restore your logs on a new phone, tap **Import Database** and select your saved SQLite backup file.


### 📊 Premium Feature: Weekly Visual Productivity Reports

* **Client-Ready Summaries:** Compile your hours into professional, client-ready timesheet documents.
* **PDF Exporter:** Generate rich, multi-page PDF summaries featuring graphical time-share charts and formatted ledger tables entirely offline.
* **🔍 How to Access & Use:**
  1. Navigate to the **Reports & Analytics** tab in the main navigation.
  2. Set your desired date range filter (e.g., **This Week**, **Last Month**, or custom dates).
  3. Tap on **Generate PDF Report** at the bottom of the analytics screen.
  4. An on-device compiling engine will generate a stylized PDF report complete with project breakdown charts and tabular work records.
  5. Use the native sharing dialog to send the compiled document directly to your client or manager.


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


## 🔌 Localization Support


HourGlass supports over **15+ Languages** dynamically mapped:

| Code | Language | Mode |
|---|---|---|
| **EN** | English | Complete |
| **ES** | Spanish | Complete |
| **FR** | French | Complete |
| **DE** | German | Complete |
| **PT** | Portuguese | Complete |
| **JA** | Japanese | Complete |
| **ZH** | Chinese | Complete |


---


## 🛠️ Developer Setup & Guidelines


### Requirements
* **Flutter SDK:** Latest Stable Channel
* **Dart SDK:** Latest Stable Channel


### Step-by-Step Installation

1. Navigate to the project directory:
   ```bash
   cd HourGlass
   ```

2. Retrieve required dependencies:
   ```bash
   flutter pub get
   ```

3. Run the static code analyzer:
   ```bash
   flutter analyze
   ```

4. Compile a pristine production release APK:
   ```bash
   flutter build apk --release
   ```


---


## 🙏 Acknowledgements & Attribution


We would like to express our sincere gratitude to the original creators and maintainers of the original [hamaluik/timecop](https://github.com/hamaluik/timecop) repository, which served as the foundation of this work.


> [!NOTE]
> This repository represents an **extensive, premium upgrade** from the original codebase. It introduces a beautifully modernized dashboard, parallel timer triggers, a robust Weekly Visual Productivity & PDF Reporting Engine built following rigorous S.O.L.I.D. guidelines, upgraded state provider architecture, and full packages compatibility with contemporary Flutter platforms.


---


## 📄 License & Open-Source


**HourGlass** is open-source software licensed under the **Apache-2.0 License**. See [LICENSE](LICENSE) for more details. Contributions and Pull Requests are welcome!
