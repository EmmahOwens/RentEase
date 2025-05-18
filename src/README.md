# Rent Smart

A modern rental management system built with Flutter that provides a comprehensive platform for landlords and tenants to manage properties, payments, and communications.

## Features

### For Landlords
- **Property Management**: Add, edit, and manage multiple properties with detailed information
- **Tenant Management**: Track tenant information, lease agreements, and payment history
- **Financial Overview**: Monitor rent payments, revenue, and financial analytics
- **Communication Hub**: Real-time messaging with tenants for efficient communication

### For Tenants
- **Payment Processing**: Multiple payment methods including card and mobile money options
- **Property Information**: Access details about your rental unit and lease agreement
- **Maintenance Requests**: Submit and track maintenance requests
- **Document Access**: View important documents and notifications

### Core Functionality
- **Real-time Messaging**: Firebase-powered messaging between landlords and tenants
- **Secure Payments**: Multiple payment options with transaction history
- **User Authentication**: Role-based authentication (landlord/tenant) with Firebase Auth
- **Push Notifications**: Receive important alerts and reminders
- **Responsive UI**: Beautiful, Airbnb-inspired design that works across devices

## Technology Stack

- **Frontend**: Flutter with Material Design and custom Airbnb-inspired theme
- **Backend**: Firebase services
  - Firebase Authentication for user management
  - Cloud Firestore for database
  - Firebase Cloud Messaging for notifications
  - Firebase Storage for document and image storage
- **State Management**: Provider pattern for app-wide state management
- **UI Components**: Custom widgets with Google Fonts integration

## Getting Started

### Prerequisites

- Flutter SDK (version ^3.7.0)
- Dart SDK
- Firebase project setup
- Android Studio with Flutter extensions

### Installation

1. Clone the repository
   ```
   git clone https://github.com/EmmahOwens/rent_smart.git
   cd rent_smart
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
   - Enable Authentication, Firestore, and Cloud Messaging in the Firebase Console

4. Run the app
   ```
   flutter run
   ```

## Project Structure

- `lib/`: Main application code
  - `core/`: Core functionality and shared components
    - `constants.dart`: App-wide constants
    - `layouts/`: Layout templates
    - `models/`: Data models
    - `navigation/`: Navigation and routing
    - `services/`: Firebase and other services
    - `theme/`: App theming with Airbnb-inspired design
    - `widgets/`: Reusable UI components
  - `features/`: Feature modules
    - `auth/`: Authentication screens and logic
    - `dashboard/`: Landlord and tenant dashboards
    - `messages/`: Messaging functionality
    - `payments/`: Payment processing and history
    - `profile/`: User profile management
    - `properties/`: Property management
    - `settings/`: App settings
    - `tenants/`: Tenant management
  - `main.dart`: Application entry point

## Contributing

We welcome contributions to Rent Smart! To contribute:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes and commit them with descriptive messages
4. Push your changes to your fork
5. Submit a pull request to the main repository

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who help improve this project
