# 🌿 Plant Watering Reminder App

A cross-platform Flutter application designed to elegantly help plant lovers efficiently manage and track their watering schedules. This project features a completely Offline-First architecture connected seamlessly to Firebase Cloud Firestore.

## 📱 Core Features

- **Offline-First Storage**: Blazing-fast loading times from local memory with automatic background Firebase Cloud backups and restoring.
- **Dynamic Scheduling**: Next watering dates are mathematically generated and dynamically updated based on custom frequency constraints.
- **Smart Dashboard**: Instantly triage tasks using the Overdue, Today, Tomorrow, and This Week lists.
- **Intuitive UI**: Pull-to-refresh to manually sync with the Cloud, simple Trash icons, and quick-water action buttons.
- **Premium Design**: Built using custom Typography (Outfit & Inter fonts), gorgeous SVG gradient fallbacks, and micro-animations to create a top-tier user experience.

---

## ⚙️ Prerequisites & Initial Setup

Before running the app for the first time after cloning, ensure you have:

1. **Flutter SDK** installed (version 3.0+)
   - Download from [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your system PATH

2. **Android Studio** or **Visual Studio Code** with Flutter extension

3. **Chrome Browser** (for web testing)

### First Time Setup Steps:

```bash
# 1. Navigate to the project directory
cd "D:\Plant_Watering_reminder"

# 2. Get all Flutter dependencies
flutter pub get

# 3. Clean previous builds (optional but recommended)
flutter clean

# 4. Generate dependencies
flutter pub get

# 5. You're ready to run!
```

---

## 🚀 How To Run The App

This app is currently optimized to be rigorously tested via a **Local Web Browser (Chrome)**.

**To run the app:**

1. Open your Windows **Terminal**, **Command Prompt**, or **PowerShell**.
2. Navigate to your project folder:
   ```bash
   cd "D:\Plant_Watering_reminder"
   ```
3. Run the Flutter web engine:
   ```bash
   flutter run -d chrome
   ```
4. A Chrome window will automatically open with your application!

**To stop the server:** Press `q` in your Terminal.

### Platform-Specific Running:

- **Web (Chrome)** - `flutter run -d chrome`
- **Android Emulator** - `flutter run -d emulator-5554`
- **iOS Simulator** - `flutter run -d iphone-se` (macOS only)

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

## � Troubleshooting

### Issue: "Flutter command not found"
**Solution:** Ensure Flutter is added to your system PATH. Run `flutter doctor` to verify installation.

### Issue: "Chrome not found"
**Solution:** Make sure Google Chrome is installed. Update PATH if necessary.

### Issue: "Build failed" or "Dependency issues"
**Solution:** Run the following commands:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run -d chrome
```

### Issue: Firebase connection errors
**Solution:** The app automatically uses the configured Firebase project (`plant-watering-reminder-1f917`). Ensure you have internet connectivity and that the backend is accessible.

### Issue: Local storage not persisting
**Solution:** The app uses local storage that persists across browser sessions. If data is lost, try:
- Clearing browser cache: Settings > Privacy > Clear browsing data
- Restarting the Flutter development server  
Based on the original software requirement specifications (`srs.txt`), the application framework is fully primed for the following upgrades at any time:
- AI Plant Suggestions & ML Disease Detection
- External Weather-API connections to delay watering schedules
- Dark Mode Themes

---
*"Keep your leafy friends happy and hydrated!"* 🌱
