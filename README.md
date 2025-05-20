# Payment App

A modern Flutter-based payment application with Firebase integration for secure transactions and real-time notifications.

## Features

- 🔐 Secure Authentication with Firebase Auth
- 💳 Payment Processing
- 🔔 Real-time Push Notifications
- 📱 Interactive UI with ShowCase Widget
- 🌓 Custom Theme Support
- 🔄 Real-time Balance Updates
- 📱 Responsive Design

## Project Structure

```
lib/
├── extensions/      # Extension methods
├── helper/          # Helper utilities
├── providers/       # State management (Riverpod)
├── screens/         # UI screens
│   ├── auth/       # Authentication screens
│   └── tabs.dart   # Main tab navigation
├── services/        # Backend services
├── theme/          # App theming
├── utils/          # Utility functions
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

## Technologies Used

- Flutter
- Firebase Core
- Firebase Authentication
- Firebase Cloud Messaging
- Flutter Riverpod (State Management)
- ShowcaseView

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:

   - Add your `google-services.json` for Android
   - Add your `GoogleService-Info.plist` for iOS
   - Update `firebase_options.dart` if needed

4. Run the app:
   ```bash
   flutter run
   ```

## Features in Detail

### Authentication

- User registration and login
- Authentication state management
- Secure session handling

### Notifications

- Push notification support
- Local notifications
- Real-time balance update notifications
- Background message handling

### UI/UX

- Interactive showcase for new users
- Material Design implementation
- Custom theme support
- Responsive layouts

## Contributing

1. Fork the repository.
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
