# SIPEJA - Sistem Pelaporan Jalan (Frontend)

## 📱 Application Description

SIPEJA (Sistem Pelaporan Jalan / Road Reporting System) is a Flutter mobile application that allows citizens to report damaged road conditions to local government authorities. The application uses AI technology to analyze the level of road damage based on photos submitted by users.

## 🚀 Key Features

- **User Authentication**: Login, register, forgot password, and email verification
- **Road Reporting**: Report road conditions with photos and location
- **AI Prediction**: Automatic analysis of road damage levels using AI
- **Upvoting System**: Voting system for existing reports
- **Real-time Updates**: Real-time report status updates
- **Maps Integration**: Map integration to display locations
- **Profile Management**: User profile management

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider
- **Backend**: Firebase (Auth, Realtime Database, Storage)
- **Maps**: Flutter Map
- **HTTP Client**: HTTP package
- **Local Storage**: SharedPreferences
- **Image Handling**: Image Picker
- **Location**: Geolocator & Geocoding

## 📦 Dependencies

```yaml
dependencies:
  firebase_auth: ^6.0.0
  firebase_core: ^4.0.0
  firebase_database: ^12.0.0
  flutter_map: ^8.2.1
  image_picker: ^1.1.2
  provider: ^6.1.5
  geolocator: ^14.0.2
  geocoding: ^4.0.0
  shared_preferences: ^2.5.3
  intl: ^0.20.2
  http: ^1.5.0
```

## 🏗️ Project Structure

```
lib/
├── src/
│   ├── app/
│   │   ├── config/
│   │   │   └── app_config.dart
│   │   └── routes/
│   │       └── app_router.dart
│   ├── core/
│   │   ├── services/
│   │   │   └── shared_preferences.dart
│   │   └── utils/
│   │       ├── snackbar_helper.dart
│   │       └── image_preview_dialog.dart
│   ├── data/
│   │   ├── model/
│   │   │   ├── address_model.dart
│   │   │   └── report_model.dart
│   │   └── repository/
│   │       ├── auth_repository.dart
│   │       └── report_repository.dart
│   ├── features/
│   │   ├── 0_splash/
│   │   │   └── view/splash_page.dart
│   │   ├── 1_auth/
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   ├── forgot_password/
│   │   │   └── verify_otp/
│   │   └── 2_home/
│   │       ├── view/home_page.dart
│   │       └── viewmodel/home_view_model.dart
│   └── widgets/
│       ├── custom_dialog.dart
│       ├── custom_dropdown.dart
│       └── report_card.dart
├── firebase_options.dart
└── main.dart
```

## 🔧 Setup & Installation

### Prerequisites

1. Flutter SDK (3.8.1 or higher)
2. Dart SDK
3. Android Studio / VS Code
4. Firebase Account
5. Android development environment

### Installation Steps

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd sipeja_gemastik
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**

   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Setup Realtime Database
   - Download `google-services.json` for Android
   - Place the configuration file in the appropriate directory

4. **Configure Firebase Options**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Update App Configuration**

   - Edit `lib/src/app/config/app_config.dart`
   - Adjust the database URL to match your Firebase project

6. **Run Application**
   ```bash
   flutter run
   ```

## 🏃‍♂️ Running the App

### Debug Mode

```bash
flutter run
```

### Release Mode (Android)

```bash
flutter build apk --release
flutter install
```

## 📱 Platform Support

- ✅ Android (API 23+)
- ❌ Web (not configured)
- ❌ Desktop (not configured)

## 🔐 Authentication Flow

1. **Splash Screen**: Check authentication status
2. **Login/Register**: Firebase Authentication
3. **Email Verification**: Automatic email verification
4. **Home Screen**: Main application dashboard

## 📊 Data Models

### Report Model

```dart
class Report {
  final String id;
  final ReporterInfo reporterInfo;
  final String address1;
  final AddressInfo address2;
  final String roadImageUrl;
  final int status; // 1: Accepted, 2: In Progress, 3: Completed
  final int aiPrediction; // 1: Light Damage, 2: Heavy Damage, 3: Good
  final int upvotes;
  final bool hasVoted;
  // ... other properties
}
```

### Address Model

- City: Pekanbaru (fixed)
- 15 available districts
- Sub-districts corresponding to each district

## 🎨 UI/UX Design

### Color Scheme

- Primary: `#F68A1E` (Orange)
- Background: `#F7F5F2` (Light Cream)
- Success: `#259500` (Green)
- Warning: `#956600` (Dark Yellow)
- Error: `#950000` (Red)

### Typography

- Font Family: Poppins (all variants from Thin to Black)
- Responsive font sizes based on content

### Components

- Custom Dialogs (Confirmation, Success, Media Picker)
- Custom Dropdown with overlay
- Report Cards with status indicators
- Custom SnackBar notifications

## 🌍 Localization

- Primary Language: Indonesian
- Date formatting: Indonesian locale (`id_ID`)
- Time format: 24-hour format (HH.mm)

## 🔒 Permissions

### Android

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 📦 Build Configuration

### Android

- compileSdk: 34
- minSdk: 23
- targetSdk: Dynamic (Flutter default)
- Gradle: 8.12
- Kotlin: 2.1.0

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Connection Issues**

   - Ensure `google-services.json` exists in `android/app/`

2. **Location Permission Denied**

   - Check permission configuration
   - Test on physical device, not emulator

3. **Image Picker Issues**

   - Ensure permissions for camera and gallery
   - Test with different image formats

4. **Build Failures**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check for dependency conflicts

### Debug Commands

```bash
# Check Flutter doctor
flutter doctor

# Analyze code issues
flutter analyze

# Format code
flutter format .

# Clear build cache
flutter clean
```

## 📝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.
