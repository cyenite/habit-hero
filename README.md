# Habit Hero

Live Demo: https://habit-hro.web.app

[![Deploy Status](https://github.com/cyenite/habit-hero/actions/workflows/firebase-hosting.yml/badge.svg)](https://github.com/cyenite/habit-hero/actions/workflows/firebase-hosting.yml) [![GitHub Release](https://img.shields.io/github/release/cyenite/habit-hero.svg)](https://github.com/cyenite/habit-hero/releases)

**Transform your life, one habit at a time**

Habit Hero is a comprehensive habit tracking application built with Flutter that helps users build positive habits, track their progress, and stay motivated through gamification elements.

## ✨ Features

### 🎯 Core Functionality
- **Habit Management**: Create, edit, and delete personalized habits
- **Flexible Scheduling**: Set habits as daily, weekly, or monthly
- **Custom Reminders**: Schedule notifications for each habit
- **Visual Customization**: Personalize habits with icons and colors

### 📊 Progress Tracking
- **Streak Tracking**: Monitor your current and longest streaks
- **Statistics Dashboard**: Visualize your habit completion data
- **XP & Leveling System**: Earn experience points as you complete habits

### 🏆 Gamification
- **Daily Challenges**: Complete special challenges for bonus rewards
- **Achievement System**: Unlock achievements as you reach milestones
- **Visual Progress**: Watch your habits level up as you stay consistent

### ⚙️ Advanced Features
- **Dark/Light Mode**: Choose your preferred theme
- **Cloud Sync**: Access your habits across multiple devices
- **Offline Support**: Full functionality without internet connection
- **Google Sign-In**: Easy authentication with your Google account

## 📱 Screenshots

| Dashboard | Weekly Overview | Habits |
|---------------|-----------|------------|
| ![Splash](assets/screenshots/sc1.png) | ![Dashboard](assets/screenshots/sc3.png) | ![Habits](assets/screenshots/sc7.png) |

| Habit Details | Add Habit | Profile |
|-----------|------------|---------|
| ![Add Habit](assets/screenshots/sc8.png) | ![Statistics](assets/screenshots/sc9.png) | ![Profile](assets/screenshots/sc11.png) |

| Dashboard (Dark Mode) | Weekly Overview (Dark Mode) | Habit Details (Dark Mode) |
|---------------|-----------|------------|
| ![Splash](assets/screenshots/sc2.png) | ![Dashboard](assets/screenshots/sc4.png) | ![Habits](assets/screenshots/sc6.png) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.5.3)
- Dart SDK (^3.5.3)
- Android Studio / VS Code with Flutter extensions
- A Supabase account for backend services

### Installation

1. Clone the repository
2. Install dependencies `flutter pub get`
3. Run `flutter pub run build_runner build` to generate the necessary files
4. Configure Google Sign-In:
   - Create a project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Google Sign-In API
   - Create OAuth 2.0 credentials
   - Add your client ID to `web/index.html` in the meta tag:
     ```html
     <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
     ```
   - For Android: Configure the OAuth client ID in your Google Cloud Console and add it to your `android/app/src/main/res/values/strings.xml`
   - For iOS: Configure the OAuth client ID in your Google Cloud Console and update your `ios/Runner/Info.plist`
5. Run `flutter run` to start the application

## 🛠️ Technical Architecture

### Frontend
- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Google Fonts**: Custom typography
- **Lottie**: Fluid animations
- **FL Chart**: Data visualization

### Backend
- **Supabase**: Backend as a Service
  - Authentication
  - Database
  - Real-time sync
  
### Local Storage
- **Hive**: NoSQL database for offline data
- **Shared Preferences**: Simple key-value storage

### Authentication
- **Supabase Auth**: Email/password authentication
- **Google Sign-In**: OAuth integration


## 🔄 Data Synchronization

The app implements a robust offline-first approach:
1. All changes are stored locally in Hive
2. When online, data is synchronized with Supabase
3. Conflict resolution strategies ensure data integrity


## 🔄 CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment with the following workflow:

### CI Workflow (on every push and PR)
1. **Code Checkout**: Retrieves the latest code from the repository
2. **Environment Setup**: Configures Java and Flutter
3. **Dependencies**: Installs all project dependencies
4. **Code Analysis**: Runs Flutter analyzer to ensure code quality
5. **Unit Testing**: Executes all unit tests to verify functionality
6. **Environment Configuration**: Sets up environment variables for builds
7. **Build APK**: Creates a release Android APK
8. **Build Web**: Creates a release web build
9. **Artifact Publishing**: Uploads build artifacts for download
10. **Release Creation**: Creates a GitHub release when pushing to main branch

### CD Workflow (Firebase Deployment)
A separate workflow deploys the web build to Firebase Hosting:

1. **Code Checkout**: Retrieves the latest code from the repository
2. **Environment Setup**: Configures Java and Flutter
3. **Build Web**: Creates a release web build
4. **Firebase Deployment**: Deploys the web build to Firebase Hosting

These automated workflows ensure that:
- All code meets quality standards
- Tests pass on every change
- Builds are automatically generated
- Releases are properly versioned
- Web deployments happen automatically

To view workflow runs and artifacts, visit the Actions tab in the GitHub repository.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.