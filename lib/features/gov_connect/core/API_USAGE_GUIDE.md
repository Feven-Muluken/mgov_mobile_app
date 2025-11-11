# API Service Usage Guide

## Overview

The API service provides a centralized, clean way to make HTTP requests throughout your Gov Connect app.

## File Structure

```
lib/features/gov_connect/
├── constants/
│   └── api_constants.dart       # All API endpoints and base URLs
└── core/
    └── api_service.dart          # HTTP request handler
```

## Quick Start

### 1. Import the API Service

```dart
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/constants/api_constants.dart';
```

### 2. Create Instance

```dart
final apiService = ApiService(); // Singleton - always returns same instance
```

## Built-in API Methods

### Authentication APIs

```dart
// Login
final response = await apiService.login(
  phone: '0912345678',
  password: 'password123',
);

// Register
final response = await apiService.register(
  phone: '0912345678',
  fullName: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
);

// Verify OTP
final response = await apiService.verifyOtp(
  phone: '0912345678',
  otp: '123456',
);
```

### Alerts APIs

```dart
// Get all alerts
final response = await apiService.getAlerts();

// Get alerts by region
final response = await apiService.getAlerts(region: 'Addis Ababa');

// Get alerts by type
final response = await apiService.getAlerts(type: 'emergency');

// Get alert detail
final response = await apiService.getAlertDetail('alert-id-123');
```

### News APIs

```dart
// Get all news
final response = await apiService.getNews();

// Get news by category
final response = await apiService.getNews(category: 'Health');

// Get news detail
final response = await apiService.getNewsDetail('news-id-456');
```

### Surveys & Polls APIs

```dart
// Get all surveys
final response = await apiService.getSurveys();

// Get survey detail
final response = await apiService.getSurveyDetail('survey-id-789');

// Submit survey
final response = await apiService.submitSurvey(
  surveyId: 'survey-id-789',
  responses: {
    'question_1': 'answer_1',
    'question_2': 'answer_2',
  },
  token: userToken, // Optional
);

// Get all polls
final response = await apiService.getPolls();

// Vote on poll
final response = await apiService.votePoll(
  pollId: 'poll-id-101',
  optionId: 'option-2',
  token: userToken,
);
```

### Emergency Contacts APIs

```dart
// Get all emergency contacts
final response = await apiService.getEmergencyContacts();

// Get emergency contacts by region
final response = await apiService.getEmergencyContacts(region: 'Bahir Dar');
```

## Generic HTTP Methods

For custom endpoints not covered by built-in methods:

### GET Request

```dart
final response = await apiService.get(
  '/custom/endpoint',
  token: userToken,
  queryParameters: {'page': '1', 'limit': '10'},
);
```

### POST Request

```dart
final response = await apiService.post(
  '/custom/endpoint',
  body: {
    'key1': 'value1',
    'key2': 'value2',
  },
  token: userToken,
);
```

### PUT Request

```dart
final response = await apiService.put(
  '/custom/endpoint',
  body: {'field': 'updated_value'},
  token: userToken,
);
```

### DELETE Request

```dart
final response = await apiService.delete(
  '/custom/endpoint',
  token: userToken,
);
```

## Response Handling

All API methods return an `ApiResponse` object:

```dart
class ApiResponse {
  final bool success;      // true if status code 200-299
  final String message;    // Success/error message
  final dynamic data;      // Response data (JSON decoded)
  final int? statusCode;   // HTTP status code
}
```

### Example: Handle Response

```dart
final response = await apiService.login(
  phone: phoneNumber,
  password: password,
);

if (response.success) {
  // Success - access data
  final user = response.data['user'];
  final token = response.data['token'];
  
  print('Login successful: ${response.message}');
  print('User: ${user['name']}');
  
} else {
  // Error - show message
  print('Login failed: ${response.message}');
  print('Status code: ${response.statusCode}');
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${response.message}')),
  );
}
```

## Complete Example: Login Flow

```dart
void _handleLogin() async {
  final apiService = ApiService();
  
  // Validate form
  if (!_formKey.currentState!.validate()) return;

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Make API call
    final response = await apiService.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Close loading
    if (mounted) Navigator.pop(context);

    // Handle response
    if (response.success && response.data != null) {
      // Extract user data
      final user = response.data['user'];
      final token = response.data['token'];
      
      // Save token (using shared_preferences or secure storage)
      await saveToken(token);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      
      // Navigate to home
      context.go('/home', extra: user);
      
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${response.message}')),
      );
    }
    
  } catch (e) {
    // Close loading if still open
    if (mounted) Navigator.pop(context);
    
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## Changing Base URL

Update in `api_constants.dart`:

```dart
class ApiConstants {
  // Development
  static const String baseUrl = 'http://196.189.50.35:8080';
  
  // Production (when ready)
  // static const String baseUrl = 'https://api.mygov.et';
  
  // Local testing
  // static const String baseUrl = 'http://localhost:8080';
}
```

## Adding New Endpoints

### Step 1: Add to `api_constants.dart`

```dart
class ApiConstants {
  // ... existing code ...
  
  // New endpoint
  static const String profileEndpoint = '/user/profile/';
}
```

### Step 2: Add method to `api_service.dart`

```dart
class ApiService {
  // ... existing code ...
  
  /// Get user profile
  Future<ApiResponse> getUserProfile(String userId, {String? token}) async {
    return await get(
      '${ApiConstants.profileEndpoint}$userId',
      token: token,
    );
  }
}
```

### Step 3: Use in your page

```dart
final response = await apiService.getUserProfile(
  userId,
  token: userToken,
);

if (response.success) {
  final profile = response.data;
  // Use profile data
}
```

## Error Handling Best Practices

### Pattern 1: Try-Catch with Loading

```dart
void _callApi() async {
  final apiService = ApiService();
  
  // Show loading
  _showLoading(context);
  
  try {
    final response = await apiService.getSomething();
    
    // Hide loading
    _hideLoading(context);
    
    if (response.success) {
      // Handle success
    } else {
      _showError(context, response.message);
    }
  } catch (e) {
    _hideLoading(context);
    _showError(context, 'Network error: $e');
  }
}
```

### Pattern 2: Using FutureBuilder

```dart
@override
Widget build(BuildContext context) {
  return FutureBuilder<ApiResponse>(
    future: ApiService().getAlerts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      
      final response = snapshot.data;
      if (response == null || !response.success) {
        return Center(child: Text('Failed to load data'));
      }
      
      final alerts = response.data as List;
      return ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return AlertCard(alert: alerts[index]);
        },
      );
    },
  );
}
```

## Features

✅ **Singleton Pattern** - Single instance throughout app  
✅ **Automatic JSON Encoding/Decoding** - No manual parsing needed  
✅ **Error Handling** - Catches network errors gracefully  
✅ **Timeout Support** - 30-second default timeout  
✅ **Token Support** - Easy authentication token management  
✅ **Type-Safe** - Proper response typing  
✅ **Reusable** - Generic methods for all HTTP verbs  

## Tips

1. **Always check `response.success`** before accessing data
2. **Use try-catch** for network errors
3. **Show loading indicators** for better UX
4. **Store tokens securely** using flutter_secure_storage
5. **Handle mounted state** before Navigator operations after async

