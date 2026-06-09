# 💪 GravLift App - Workout Tracker

<div align="center">

![GravLift App](https://img.shields.io/badge/Flutter-App-blue?logo=flutter)
![Status](https://img.shields.io/badge/Status-Alpha%20Testing-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![Dart](https://img.shields.io/badge/Dart-80.2%25-blue)
![Version](https://img.shields.io/badge/Version-v0.1.0--alpha-red)

**Track your gym & calisthenics workouts effortlessly with a beautiful, dark-themed mobile app**


</div>

---

## 📱 About GravLift

**GravLift** is a free, open-source workout tracking application designed for gym athletes and calisthenics enthusiasts. Built with **Flutter** and powered by **Supabase**, it provides a seamless experience for logging workouts, tracking progress, and achieving fitness goals.

> **Status**: Currently in active **alpha testing**. Features are being actively developed and feedback is highly appreciated! 🚀

### Why GravLift?
✅ **Completely Free** - No ads, no paywalls, no premium tiers  
✅ **Privacy-First** - Your data is yours (open-source, self-hostable)  
✅ **Beautiful UI** - Dark theme with deep purple accents  
✅ **Lightweight** - Minimal app size, fast performance  
✅ **Made for Athletes** - Features designed by fitness enthusiasts, for fitness enthusiasts  

---

## 🎯 Features

### Current (v0.1.0-alpha)
- 📊 **Workout Logging** - Log exercises, sets, reps, and weight
- 📈 **Progress Tracking** - Visual charts and statistics
- 🌙 **Dark Theme** - Easy on the eyes during gym sessions
- 🎨 **Beautiful UI** - Intuitive navigation with custom Drawer menu
- 🔐 **Secure Auth** - Supabase Row Level Security (RLS)
- 💾 **Cloud Sync** - Auto-sync workouts across devices
- **Note:** - Exercises database is still in heavy development. Current exercises are temporary and a better version will come up later.

### Roadmap (Planned)
- 🎥 **Form Videos** - Exercise form guidance
- 🏋️ **Workout Programs** - Pre-built routines (PPL, Upper/Lower, etc)
- 🎯 **Goal Setting** - Set and track specific fitness goals
- 📱 **Android/iOS** - Native apps for both platforms
- 🤝 **Social Features** - Share workouts with friends
- 📊 **Advanced Analytics** - AI-powered insights

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Supabase (PostgreSQL) |
| **Auth** | Supabase Auth + RLS |
| **State** | Provider / Riverpod |
| **Database** | PostgreSQL (Free tier) |
| **Version Control** | Git + GitHub |

---

## 🚀 Quick Start

### Installation

#### Option 1: Download Pre-built APK (Android)
1. Go to [Releases](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/releases)
2. Download the latest `gravlift-vX.X.X-alpha.apk`
3. Install on your Android device
4. Create an account and start logging workouts!


## 🧪 Beta Testing

We're looking for **community testers** to help shape GravLift! No coding experience needed.

### What We Need
- 🐛 Bug reports (with screenshots/videos)
- 💬 UI/UX feedback
- 💡 Feature suggestions
- ✅ Confirmation that features work as expected

### How to Join
1. **Download** the latest APK from [Releases](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/releases)
2. **Test** in your actual workouts (15-30 min/week)
3. **Report** issues via [GitHub Issues](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/issues)
4. **Join** our [Discord Community](#discord) for real-time chat

### Beta Tester Benefits
As a beta tester, you get:
- 🎖️ Your name in the CHANGELOG as a beta tester
- ⭐ Early access to new features
- 💬 Direct support from the developer
- 🎯 One custom feature request (if feasible)

---

## 📝 How to Report Issues

Found a bug? Have feedback? Follow these steps:

### 1. Check Existing Issues
Visit [Issues](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/issues) and search before creating a new one.

### 2. Use the Bug Report Template
- **Title**: Clear, concise description
- **Environment**: Android version, device model, app version
- **Steps to Reproduce**: Detailed reproduction steps
- **Expected**: What should happen
- **Actual**: What actually happened
- **Screenshots/Video**: Visual proof (highly helpful!)

### 3. Example
```
## Bug: Crash when logging weights

**Environment:**
- Device: Samsung Galaxy A10
- Android: 10
- App Version: v0.1.0-alpha1

**Steps to Reproduce:**
1. Open app
2. Click "Log Workout"
3. Enter weight as "50kg"
4. Click Save
→ App crashes

**Expected:** Workout logs successfully

**Actual:** Crash with error dialog

**Logs:**
[Paste error logs here]
```

---

## 🎨 Design System

### Colors (Deep Purple Theme)
```dart
// Primary
Colors.deepPurpleAccent    // Main brand color
Colors.deepPurple[900]     // Dark backgrounds
Colors.deepPurple[800]     // Secondary backgrounds

// Accents
Colors.white               // Text on dark
Colors.grey[300]          // Secondary text
```

### UI Patterns
- **Navigation**: Custom Drawer (always close with `Navigator.pop(context)`)
- **Layouts**: Column/ListView (modular, prevent stretching)
- **Feedback**: Bottom sheets, dialogs, snackbars
- **Dark Mode**: Enabled by default

---

## 🔒 Security & Privacy

### Data Protection
- ✅ **Row Level Security (RLS)** - Only your own data is visible
- ✅ **Environment Variables** - Credentials never hardcoded
- ✅ **HTTPS Only** - Supabase enforces encrypted connections
- ✅ **No Tracking** - Zero analytics/ads

---

## 💬 Community & Support

### Get Help
- 📖 **Documentation**: Check the [Wiki](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/wiki)
- 💬 **Discussions**: Use [GitHub Discussions](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/discussions)
- 🐛 **Report Issues**: Open a [GitHub Issue](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/issues)
- 💌 **Email**: contact@gravlift.dev *(add your email)*

### Follow Development
- ⭐ Star the repo to stay updated
- 🔔 Watch for new releases
- 📧 Subscribe to [Discussions](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/discussions)

---

## 💖 Support the Project

Love GravLift? Here's how you can support:

### Free Ways to Help
- ⭐ **Star** the repository
- 🔄 **Share** with friends
- 📢 **Report bugs** and suggest features
- 📝 **Contribute** code or documentation
- 💬 **Provide feedback** on design/UX

### Patreon Support (Coming Soon)
Want to support development financially?
**[Patreon Link](https://patreon.com/tungstenfed)** *(enable when ready)*

Your support helps with:
- 🖥️ Server costs
- 🎨 Design tools
- 📚 Learning resources
- ⏱️ Development time

---


## 🙏 Acknowledgments

### Built With
- 🦅 [Flutter](https://flutter.dev) - UI framework
- 🗄️ [Supabase](https://supabase.com) - Backend as a Service
- 🎨 [Material Design](https://material.io) - Design system

### Contributors
We're grateful to everyone who's contributed! See [CONTRIBUTORS.md](CONTRIBUTORS.md)

---

## 📞 Contact

- **Developer**: [@tungstenFed](https://github.com/tungstenFed)
- **GitHub Issues**: [Report bugs here](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/issues)
- **Discussions**: [Ask questions here](https://github.com/tungstenFed/GravLift-Workout-Tracker-App/discussions)

---

<div align="center">

**Made with 💜 by [@tungstenFed](https://github.com/tungstenFed)**

[⬆ back to top](#-gravlift-app---workout-tracker)

</div>
