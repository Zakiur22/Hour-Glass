# ⏳ HourGlass


A simple, secure, and privacy-respecting time tracker that gets the job done without getting in your way.


**HourGlass** is an offline-first, mobile-first time tracking tool. It is designed for developers, freelancers, and professionals who need to keep accurate timesheets without compromising their personal data or suffering from over-engineered, cluttered layouts.


---


## 🚀 Technical Stack & Architecture


This project is built using professional, scalable, and robust development technologies.


### 🛠️ Core Technology Stack

* **Framework:** Flutter SDK (Latest Stable Channel) & Dart (Latest Stable Channel)
* **State Management:** BLoC / Cubit architecture patterns separating UI-bindings from data flows.
* **Local Persistence:** SQLite Database (`sqflite` package) for heavy-duty relational timesheet tracking.
* **Reporting Engine:** Native `pdf` compilation engine rendering client-ready multipage summaries.
* **Localization:** Standard `flutter_localizations` framework mapping translations dynamically across 15+ locales.


### 🏗️ Architecture & Folder Structure

The application's code is divided cleanly into feature boundaries. The custom Productivity Reports and PDF Exporter feature utilizes strict **Clean Architecture** patterns to divide business domains from presentation screens:

```
lib/
├── features/
│   └── productivity_reports/     # Clean Architecture Productivity Reports Feature
│       ├── domain/
│       │   ├── models/           # Immutable ProductivitySummary and ChartSlice entities
│       │   └── repositories/     # Repository contracts defining weekly aggregates and PDF render pipelines
│       ├── data/
│       │   ├── datasources/      # Raw SQLite queries compiling timespans and vector graphics generators
│       │   └── repositories/     # Concrete repository implementations invoking document writing APIs
│       └── presentation/
│           ├── controllers/      # BLoC cubits managing dashboard statistics and export triggers
│           ├── pages/            # High-fidelity visual dashboard page
│           └── widgets/          # Tabular grids, progress rings, and animated project cards
├── models/                       # Legacy SQLite Database Models
├── l10n/                         # Internationalization files (15+ languages)
├── screens/                      # Legacy Time tracking, project lists, and settings sheets
└── main.dart                     # Main entrypoint bootstrapping the database and active timers
```


---


## 🛠️ Software Coding & Clean Code Principles


To ensure high quality, maintainability, and clean code standards, we applied rigorous software principles:

* **S.O.L.I.D. Architectural Guidelines:**
  * **Single Responsibility (SRP):** The `SQLiteHelper` class only manages raw SQL commands; it does not contain business logics like compiling project hour-percentages.
  * **Open/Closed (OCP):** Introducing new localization assets or database columns does not require changes to presentation layers.
  * **Liskov Substitution (LSP):** Concrete repository adapters can be fully substituted with fake mock data classes inside developer testing environments.
  * **Interface Segregation (ISP):** Keeping data backup routines decoupled from visual layout modules.
  * **Dependency Inversion (DIP):** Presentation screens listen to abstract Cubit states rather than directly triggering database raw queries.
* **DRY (Don't Repeat Yourself):** Standardized timer controls, project selection lists, and action buttons are modularized.
* **Separation of Concerns:** Deeply isolates UI presentation elements from transactional database backends.
* **Fail-Safe & Type Safety:** Implements explicit strong typing on SQL query return maps to prevent typical type-casting crashes.


---


## ✨ Extensive Features & Subfeatures Guide


### ⏱️ High-Speed Parallel Timers

* **Parallel Tracking:** 
  Manage multiple ongoing tasks at once. Start, pause, resume, edit, or delete timers with a single tap.
* **Project & Client Associations:** 
  Organize your logs by tagging timers with custom-colored projects and category labels.
* **🔍 How to Access & Use:**
  1. On the home page, enter a description of the task you are currently working on in the top input box (e.g., "Designing UI Mockups").
  2. Tap the **Project** colored block next to the input field to assign the task to a client/project.
  3. Tap the green **Play** button to start the timer.
  4. The running timer will display at the top of the list with a ticking second counter.
  5. Tap the red **Stop** button to finish tracking. The entry is instantly saved to your local ledger list below.
  6. To edit or adjust a logged timer's start or end times, simply tap on that timer card to open the editor panel.


### 🔒 Uncompromising Data Privacy & Backups

* **100% Offline-First:** 
  No accounts required, no internet dependency, and absolutely zero background analytics or tracking. Your data belongs to you.
* **Database Backups:** 
  Export and import the app's entire SQLite database with one click for full ownership, migration, and physical backup of your records.
* **🔍 How to Access & Use:**
  1. Open the **Menu** (three lines) in the top corner.
  2. Select **Settings** and scroll down to the **Data Management** section.
  3. Tap **Export Database** to create a backup file containing your entire time log database. You can save this file to your device, iCloud, Google Drive, or send it to your computer.
  4. To restore your logs on a new phone, tap **Import Database** and select your saved SQLite backup file.


### 📊 Premium Feature: Weekly Visual Productivity Reports

* **Client-Ready Summaries:** 
  Compile your hours into professional, client-ready timesheet documents.
* **PDF Exporter:** 
  Generate rich, multi-page PDF summaries featuring graphical time-share charts and formatted ledger tables entirely offline.
* **🔍 How to Access & Use:**
  1. Navigate to the **Reports & Analytics** tab in the main navigation.
  2. Set your desired date range filter (e.g., **This Week**, **Last Month**, or custom dates).
  3. Tap on **Generate PDF Report** at the bottom of the analytics screen.
  4. An on-device compiling engine will generate a stylized PDF report complete with project breakdown charts and tabular work records.
  5. Use the native sharing dialog to send the compiled document directly to your client or manager.


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
> We have extensively worked on their original codebase, refactored the underlying logic, updated legacy dependencies, resolved complex build and runtime errors, and introduced many advanced modern enhancements. These upgrades include a high-performance Weekly Productivity Reporting Dashboard and PDF Exporter built following strict Clean Architecture guidelines, parallel multiple timer tracking states, offline-first SQLite database backups, and extensive internationalization layouts to create a highly optimized, state-of-the-art, and production-ready portfolio application.


---


## 📄 License & Open-Source


**HourGlass** is open-source software licensed under the **Apache-2.0 License**. See [LICENSE](LICENSE) for more details. Contributions and Pull Requests are welcome!
