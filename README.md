# ⚔️ Warhammer 40K Build Generator (iOS App)

**Warhammer 40K Build Generator** is a mobile app for iOS built with SwiftUI that allows players to generate, manage, and share optimized unit builds for Warhammer 40K, powered by AI. The app provides personalized suggestions for equipment, abilities, advantages/disadvantages, and battlefield strategies — all tailored to the chosen faction and playstyle.

---

## ✨ Features (MVP)
- 🎯 Smart build suggestions powered by ChatGPT
- 🛡️ Custom loadouts based on point limits and detachments
- 📊 Unit stats viewer with filtering and search
- 🧠 Strategy tips and role-based recommendations
- 📄 Export builds as sharable PDF or image guides

---

## 🚧 Tech Stack

- `SwiftUI` — Declarative UI for iOS
- `MVVM` + Clean Architecture
- `Firebase` or `Supabase` (TBD) — Online backend and auth
- `OpenAI API` — AI-powered build generation and strategy
- `Swift Package Manager` — Dependency management
- `GitHub` — Repository & CI/CD workflows

---

## 📦 Project Structure (Clean MVVM)

```bash
warhammer40k-fe-ios/
│
├── Presentation/          # SwiftUI Views & ViewModels
├── Domain/                # Use Cases & Entities
├── Data/                  # Repositories, Models, Mappers
├── Resources/             # Assets, Localizations
├── Configuration/         # .xcconfig, Secrets
└── SupportingFiles/       # Info.plist, AppDelegate, etc.
```

---

## 🚀 Getting Started

### Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Setup
1. Clone the repository:
```bash
git clone https://github.com/jvillenaVS/warhammer40k-fe-ios.git
```

2. Create a `Secrets.xcconfig` file with:
```text
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxx
```

3. Open `warhammer40k-fe-ios.xcodeproj` in Xcode and run on simulator or device.

---

## 📄 Roadmap

- [ ] AI-powered build generation (ChatGPT)
- [ ] Unit database integration (cloud-based)
- [ ] Dynamic point calculations
- [ ] PDF export and share features
- [ ] Offline mode (local caching)
- [ ] Optional voice explanation (TTS)

---

## 🤖 AI Prompt Examples

```text
Generate an optimized build for a Blood Angels Intercessor unit focused on close combat. Max 200 points.
```

```text
Suggest a balanced Astra Militarum build with strong defensive synergy for a 1000-point army.
```

---

## 📬 Contact

Created by [@jvillenaVS](https://github.com/jvillenaVS) — for Warhammer 40K enthusiasts and developers alike.

---

## 📜 License

This project is currently under development and not licensed for distribution yet.
