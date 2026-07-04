# Project Plan - HourGlass

## 1. Current State Assessment
* **Category:** Productivity Time Tracker
* **Tech Stack:** flutter_bloc state management, sqflite database, pdf, dynamic_color, csv, card_swiper, flutter_slidable.
* **SDK Range:** `>=3.1.3 <4.0.0`
* **Status:** Highly professional, production-grade private offline tracker. Localization and accessibility are highly complete.

## 2. Planned Enhancements (Phase 4)
* **New Feature: Weekly Visual Productivity Reports**
  * **Objective:** Summarize time tracking metrics into beautifully visualized local reports.
  * **Implementation:** Aggregate sqflite tracker timestamps into weekly buckets. Calculate total tracked time, project ratios, and active days.
  * **UI/UX:** Add a modern report dashboard tab featuring pie/bar charts representing weekly project distribution, with option to share as PDF.
