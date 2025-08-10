# SIPEJA - Road Reporting System

A comprehensive road reporting system consisting of a Flutter mobile application and Node.js backend API that allows citizens to report damaged road conditions to local government authorities using AI-powered damage analysis.

## 📱 Overview

SIPEJA (Sistem Pelaporan Jalan / Road Reporting System) enables community-driven infrastructure monitoring through:

- **Mobile App**: Flutter-based citizen reporting interface
- **Backend API**: Comprehensive management system with dual authentication
- **AI Integration**: Automated road damage level analysis
- **Real-time Updates**: Live status tracking and notifications

## 📸 Application Screenshots

![Application Screenshot](Screenshot/0_ApplicationScreenshot.png)

## 🚀 Features

### Mobile Application (Frontend)

- **User Authentication**: Login, register, forgot password, and email verification
- **Road Reporting**: Report road conditions with photos and location
- **AI Prediction**: Automatic analysis of road damage levels using AI
- **Upvoting System**: Community voting system for existing reports
- **Real-time Updates**: Live report status updates
- **Maps Integration**: Interactive map integration for location display
- **Profile Management**: Comprehensive user profile management

### Backend API

- **Dual Authentication System**: Firebase Auth for mobile + JWT for web admin
- **Role-based Access Control**: CITIZEN, STAKEHOLDER, ADMIN roles
- **Comprehensive Report Management**: Create, track, and manage reports
- **Voting & Comment System**: Community engagement features
- **Badge & Gamification System**: Point-based rewards for user participation
- **Real-time Notifications**: Keep users informed about report status
- **Analytics Dashboard**: Daily statistics and insights
- **File Upload Support**: Images and videos for reports
- **Geolocation Support**: Location-based report mapping

## 🛠️ Tech Stack

### Frontend (Mobile)

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider
- **Backend Integration**: Firebase (Auth, Realtime Database, Storage)
- **Maps**: Flutter Map
- **HTTP Client**: HTTP package
- **Local Storage**: SharedPreferences
- **Image Handling**: Image Picker
- **Location Services**: Geolocator & Geocoding

### Backend (API)

- **Runtime**: Node.js 18+
- **Framework**: Fastify
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Firebase Admin SDK + JWT
- **Password Hashing**: bcryptjs
- **File Storage**: Configurable (local/cloud)
- **Containerization**: Docker & Docker Compose

## 📦 Installation & Setup

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Node.js 18+
- PostgreSQL database
- Firebase project with Admin SDK credentials
- Android development environment

### Frontend Setup

1. **Clone Repository**

   ```bash
   git clone <repository-url>
   cd sipeja-gemastik
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
   - Place configuration files in appropriate directories

4. **Run Application**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to Backend Directory**

   ```bash
   cd backend
   ```

2. **Install Dependencies**

   ```bash
   npm install
   ```

3. **Environment Configuration**
   Create a `.env` file:

   ```env
   DATABASE_URL="postgresql://postgres:password@localhost:5432/sipeja"
   JWT_SECRET="your-super-secret-jwt-key"
   PORT=3000
   NODE_ENV=development
   FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'
   ```

4. **Database Setup**

   ```bash
   npx prisma generate
   npx prisma migrate dev --name init
   npx prisma db push
   ```

5. **Start Server**
   ```bash
   npm run dev
   ```

## 📱 Download & Demo

### APK Release

Download the latest version: [SIPEJA v0.1.0](https://github.com/AgusSyuhada/sipeja_gemastik/releases/tag/v0.1.0)

### Demo Account

Test the application with the following credentials:

| Field    | Value           |
| -------- | --------------- |
| Email    | user@sipeja.com |
| Password | sipeja2025      |

## 🔐 Authentication System

### Mobile User Flow

1. **Splash Screen**: Check authentication status
2. **Login/Register**: Firebase Authentication
3. **Email Verification**: Automatic email verification
4. **Home Dashboard**: Main application interface

### Web Admin Flow (Backend)

1. Register with email/password → Creates Firebase Auth user and local DB record
2. Login with email/password → Validates against local DB, returns JWT
3. JWT used for subsequent API calls

## 📊 User Roles & Permissions

### CITIZEN (Mobile Users)

- Create and submit pothole reports
- Vote on existing reports
- Comment on reports
- View public reports
- Earn badges and points

### STAKEHOLDER

- All CITIZEN permissions
- Assigned to specific reports
- Update report status
- Access to assigned reports dashboard

### ADMIN

- Complete system access
- User management
- System configuration
- Analytics access
- Assign reports to stakeholders

## 🎨 Design System

### Color Scheme

- **Primary**: `#F68A1E` (Orange)
- **Background**: `#F7F5F2` (Light Cream)
- **Success**: `#259500` (Green)
- **Warning**: `#956600` (Dark Yellow)
- **Error**: `#950000` (Red)

### Typography

- **Font Family**: Poppins (all variants from Thin to Black)
- **Responsive font sizes** based on content

## 🌍 Localization

- **Primary Language**: Indonesian
- **Date Formatting**: Indonesian locale (`id_ID`)
- **Time Format**: 24-hour format (HH.mm)

## 📱 Platform Support

- ✅ **Android** (API 23+)
- ❌ **Web** (not configured)
- ❌ **Desktop** (not configured)

## 🔒 Security Features

- **Password Hashing**: bcryptjs with salt rounds
- **JWT Tokens**: Secure token-based authentication
- **Role-based Access Control**: Granular permissions
- **Session Management**: Refresh token rotation
- **Input Validation**: Comprehensive request validation
- **CORS Protection**: Configurable CORS policies

## 🐳 Deployment

### Using Docker Compose (Backend)

```bash
# Start all services (app + database)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Android APK Build (Frontend)

```bash
flutter build apk --release
```

## 🧪 Development

### Run in Development Mode

```bash
# Frontend
flutter run

# Backend
npm run dev
```

### Database Management

```bash
# View database in Prisma Studio
npx prisma studio

# Reset database
npx prisma migrate reset
```

## 📈 Analytics & Monitoring

The system tracks:

- Daily statistics (reports, users, votes, comments)
- User engagement metrics
- Report completion rates
- AI prediction accuracy
- System performance metrics

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.

## ⚠️ Important Notes

- Always use HTTPS in production
- Regularly update dependencies for security
- Monitor Firebase usage and billing
- Implement proper backup strategies for your database
- Test on physical devices for location-based features

---

For questions or support, please open an issue in the repository.
