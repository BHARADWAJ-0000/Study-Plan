# Monkeymax Study Plan

Monkeymax is a portrait-first Flutter study planner with personalized onboarding,
adaptive task tracking, quizzes, and an optional Gemini-powered plan generator.

## Run the app

```bash
flutter pub get
flutter run
```

Build the release APK with:

```bash
flutter build apk --release --no-tree-shake-icons
```

## Optional Gemini backend

The app works offline. To enable Gemini plan generation, start the proxy with a
server-side key:

```bash
cd backend
GEMINI_API_KEY="your-key" node server.js
```

Never embed the Gemini key in the APK.
>>>>>>> origin/main
