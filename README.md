# Gatekeeper Mobile App

A Flutter mobile application with authentication functionality that connects to the Gatekeeper backend API.

## Features

- **Login Screen**: Beautiful login interface with RUT and password validation
- **RUT Formatting**: Automatic formatting of Chilean RUT numbers (12.345.678-9)
- **Authentication**: Secure token-based authentication with local storage
- **Auto-login**: Automatically logs in users if they have a valid stored token
- **Logout**: Secure logout functionality that clears stored credentials
- **Shift Management**: Clock in and clock out functionality for employee time tracking
- **Real-time Clock**: Live time display for accurate shift recording
- **Error Handling**: Comprehensive error handling for network issues and invalid credentials

## Setup

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Navigate to the mobile directory:

   ```bash
   cd mobile
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## API Integration

The app connects to the backend API at `localhost:9000`. Make sure your backend server is running before testing the login functionality.

### API Endpoints

- **Login**: `POST /auth/login`

  - Request body: `{"rut": "123456789", "password": "password"}`
  - Response:
    ```json
    {
      "success": true,
      "message": "Login successful",
      "data": {
        "user": {
          "id": "user-id",
          "rut": "123456789",
          "email": "user@example.com",
          "firstName": "John",
          "lastName": "Doe",
          "roles": [...]
        },
        "token": "jwt_token"
      },
      "timestamp": "2025-07-22T10:05:04.158Z",
      "endpoint": "/auth/login"
    }
    ```

- **Clock In**: `POST /shifts/clock-in`

  - Headers: `Authorization: Bearer <token>`
  - Request body: `{"timestamp": "2024-01-01T08:00:00.000Z"}`
  - Response: `{"success": true, "shift": {...}}`

- **Clock Out**: `POST /shifts/clock-out`

  - Headers: `Authorization: Bearer <token>`
  - Request body: `{"timestamp": "2024-01-01T17:00:00.000Z"}`
  - Response: `{"success": true, "shift": {...}}`

- **Current Shift**: `GET /shifts/current`
  - Headers: `Authorization: Bearer <token>`
  - Response: `{"shift": {...}}`

### RUT Format

The app handles Chilean RUT (Rol Único Tributario) format:

- **Input**: Users can enter RUT with or without formatting (123456789, 12345678-9, 12.345.678-9)
- **Display**: Automatically formats as "12.345.678-9" for better readability
- **API**: Sends clean format "123456789" to the backend
- **Validation**: Ensures proper RUT format (8-9 digits + verification digit)

## Project Structure

```
mobile/lib/
├── main.dart              # Main application entry point
├── services/
│   ├── auth_service.dart  # Authentication service for API calls
│   └── shift_service.dart # Shift management service for clock in/out
└── screens/
    ├── login_screen.dart  # Login screen UI with RUT input
    └── home_screen.dart   # Dashboard with clock in/out functionality
```

## Authentication Flow

1. **App Startup**: The app checks for existing authentication tokens
2. **Login Screen**: If no valid token exists, shows the login form with RUT field
3. **RUT Formatting**: Automatically formats RUT input for better UX
4. **API Call**: Sends clean RUT and password to the backend
5. **Token Storage**: Stores the JWT token locally using SharedPreferences
6. **Dashboard**: Shows the shift management dashboard after successful login
7. **Shift Management**: Employees can clock in/out with real-time feedback
8. **Logout**: Clears stored tokens and returns to login screen

## Dependencies

- `http`: For making HTTP requests to the backend API
- `shared_preferences`: For secure local storage of authentication tokens

## Development

### Adding New Features

1. Create new screens in the `screens/` directory
2. Add new services in the `services/` directory
3. Update the main.dart file to include new navigation logic

### Testing

Run tests with:

```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **Network Error**: Ensure the backend server is running on `localhost:9000`
2. **Build Errors**: Run `flutter clean` and `flutter pub get`
3. **iOS Simulator Issues**: Make sure Xcode is properly configured
4. **Android Emulator Issues**: Ensure Android Studio and SDK are set up correctly

### Debug Mode

Run in debug mode for detailed logs:

```bash
flutter run --debug
```

## Security Notes

- Authentication tokens are stored securely using SharedPreferences
- All API calls use HTTPS (when available)
- Input validation is implemented on both client and server side
- Passwords are never stored locally, only authentication tokens
- RUT validation ensures proper Chilean national ID format
