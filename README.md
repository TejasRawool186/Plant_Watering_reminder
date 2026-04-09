# 🌿 Plant Watering Reminder App

A cross-platform Flutter application designed to elegantly help plant lovers efficiently manage and track their watering schedules. This project features a completely Offline-First architecture connected seamlessly to Firebase Cloud Firestore.

## 📱 Core Features

- **Offline-First Storage**: Blazing-fast loading times from local memory with automatic background Firebase Cloud backups and restoring.
- **Dynamic Scheduling**: Next watering dates are mathematically generated and dynamically updated based on custom frequency constraints.
- **Smart Dashboard**: Instantly triage tasks using the Overdue, Today, Tomorrow, and This Week lists.
- **Intuitive UI**: Pull-to-refresh to manually sync with the Cloud, simple Trash icons, and quick-water action buttons.
- **Premium Design**: Built using custom Typography (Outfit & Inter fonts), gorgeous SVG gradient fallbacks, and micro-animations to create a top-tier user experience.

---

## 🚀 How To Run The App

This app is currently optimized to be rigorously tested via a **Local Web Browser (Chrome)**.

Whenever you reboot your computer or close your development window and want to restart the app later, simply follow these steps:

1. Open your Windows **Terminal**, **Command Prompt**, or **PowerShell**.
2. Navigate to your project folder using this command:
   ```bash
   cd "D:\Plant_Watering_reminder"
   ```
3. Run the Flutter web engine:
   ```bash
   flutter run -d chrome
   ```
4. A Chrome window will securely open housing your application!

*Note: Whenever you want to safely stop the server, just press `q` in your Terminal.*

---

## ☁️ Firebase Architecture Note

**Live Firestore Database ID:** `plant-watering-reminder-1f917`

Your plant data (names, schedules, frequencies, and UI colors) is entirely hooked up to Firebase Cloud Firestore. 

* **Image Behavior**: When you upload an image inside the Chrome test environment, Chrome uses a temporary memory link (`blob:`). If you completely terminate your browser session, that memory block dumps. Our app acknowledges this, catches the missing link dynamically from the cloud, and elegantly replaces the missing image with a high-quality icon gradient fallback!

---

## 🛠️ Tech Stack & Specifications

- **Framework**: Flutter 3 (Dart)
- **State Management**: Reactive `provider` design pattern
- **Database Backend**: Firebase Cloud Firestore 
- **Packages Used**: `flutter_local_notifications`, `flutter_slidable`, `image_picker`, `google_fonts`

---

## 🔮 Future Roadmap 
Based on the original software requirement specifications (`srs.txt`), the application framework is fully primed for the following upgrades at any time:
- AI Plant Suggestions & ML Disease Detection
- External Weather-API connections to delay watering schedules
- Dark Mode Themes

---
*"Keep your leafy friends happy and hydrated!"* 🌱
