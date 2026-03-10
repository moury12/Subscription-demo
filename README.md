# Ramsai - AI-Powered Fitness & Nutrition Ecosystem

Ramsai is a premium, feature-rich health and fitness application built with Flutter. It combines personalized workout planning, intelligent nutrition tracking via AI, and a modern, high-performance UI designed for a seamless user experience.

---

## 🚀 Key Features

### 🍏 Intelligent Nutrition Tracking
- **AI Food Scanner**: Snap a photo or upload an image of your meal. The app leverages AI to identify ingredients and provide instant nutritional analysis (calories, protein, carbs, fats).
- **Consolidated Meal Logging**: Quick entry for Breakfast, Lunch, Dinner, and Snacks.
- **Unified Logging Flow**: A standardized multi-step selection (Manual vs. AI Scan) used across the entire app.
- **Daily Macro Overview**: Real-time progress tracking with beautiful circular indicators and micronutrient breakdowns.

### 🏠 Dynamic Dashboard
- **Personalized Header**: Context-aware greetings based on time of day.
- **Live Clock & Date**: Real-time time and date display in the header (e.g., "Thursday, July 25, 11:45 AM").
- **Streak Management**: Motivating "Day Streak" tracker to encourage daily consistency.
- **Responsive Navigation**: Easy access to Dashboard, Workout, Nutrition, Progress, and Profile.

### 📋 Smart Onboarding & Personalization
- **Multi-Step Profile Setup**: Gathers comprehensive user data including physical stats, activity level, fitness goals, and dietary preferences.
- **Localized Timezone Selection**: Integrated timezone search and selection to sync reminders and schedules correctly.
- **Progressive Disclosure**: Clean, step-by-step UI to ensure high completion rates.

### 🏋️ Personalized Workout Planning (Work-in-Progress)
- **Schedule Management**: User-defined workout frequency (days per week).
- **Progress Tracking**: Visual indicators of completed vs. remaining workouts.

---

## 🏗️ Technical Architecture

The project follows a **Feature-Based Architecture** to ensure modularity, scalability, and ease of maintenance.

```
lib/
├── core/               # Theme, constants, global configurations
├── features/           # Modular units of functionality
│   ├── auth/           # Authentication flow (Sign-In, Sign-Up)
│   ├── home/           # Dashboard UI and header widgets
│   ├── nutrition/      # AI Scanner, meal logging, and macro tracking
│   ├── onboarding/     # Step-by-step user onboarding flow
│   ├── workout/        # Workout scheduling and exercises
│   └── ...             # Main, Profile, Progress features
├── utils/              # Helper functions (Responsive scaling, Date formatting)
├── widgets/            # Reusable UI components (Buttons, Cards, Inputs)
└── main.dart           # Application entry point
```

### Tech Stack
- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.10.4)
- **State Management**: Reactive Controller pattern (e.g., `NutritionController`).
- **Localization & Formatting**: `intl` package for precise date/time handling.
- **UI Components**: High-fidelity custom widgets with glassmorphism and dynamic gradients.

---

## 🛠️ Developer Setup & Backend Roadmap

### Current Focus
The application is currently a high-fidelity frontend experience. It includes fully realized navigational flows, local state management for UI demonstrations, and standardized components.

### Backend Implementation Guide
For developers looking to implement the backend (e.g., using Node.js, Go, or Python), prioritize the following:

1.  **Authentication Integration**:
    - Connect `SignInScreen` and `SignUpScreen` to an Auth provider (e.g., Firebase, Supabase, or Clerk).
    - Handle session persistence and password reset requests.

2.  **User Data Persistence**:
    - **Profiles**: Store data from the `OnboardingData` model (Age, Weight, Activity Level, Timezone).
    - **Logs**: Store daily meal logs (`LoggedMeal`) and workout completion history.

3.  **AI Vision Gateway**:
    - Implement a proxy/gateway to integrate the `AiFoodScanScreen` with a Vision AI service (like Gemini Pro 1.5 Flash or Vision GPT-4).
    - The backend should receive an image, process it via AI, and return structured nutritional data mapping to the frontend `Food` model.

4.  **Real-time Services**:
    - Implement push notifications for workout reminders and streak alerts.

---

## 🎨 Design Principles
- **Aesthetic Excellence**: Premium dark mode design with vibrant accents (`#00C853`, `#2E6FFC`).
- **Responsive Scaling**: Utilizes a custom `DesignScale` utility to ensure pixel-perfect rendering across different screen aspect ratios.
- **Interactivity**: Micro-animations and hover effects (on web) to provide tactile feedback.

---

## 📦 How to Run
1.  **Clone the repository**: `git clone <repo-url>`
2.  **Fetch dependencies**: `flutter pub get`
3.  **Run the app**: `flutter run` (Ensure you have a simulator or physical device connected)

---

### Contribution
We are building the future of AI-driven health. Join us! 👟🔥
