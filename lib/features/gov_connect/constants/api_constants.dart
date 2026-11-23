/// API Constants for Gov Connect App
///
/// Contains all API endpoints and configuration

class ApiConstants {
  // Base URLs
  // Use 127.0.0.1 for localhost testing
  //static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl = 'http://196.189.50.53:8000';
  static const String apiPath = '/api';
  
  // Full API Base URL
  static String get apiBaseUrl => '$baseUrl$apiPath';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/token/';
  static const String registerEndpoint = '/users/register/';
  static const String verifyOtpEndpoint = '/users/verify-otp/';
  static const String resendOtpEndpoint = '/users/resend-otp/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String refreshTokenEndpoint = '/auth/refresh/';
  static const String forgetPasswordEndpoint= '/users/forgot-password/request/';
  static const String resetPasswordEndpoint = '/users/forgot-password/reset/';

  // User Endpoints
  static const String userProfileEndpoint = '/users/profile/';
  static const String updateProfileEndpoint = '/users/profile/'; // PUT request to same endpoint

  // Alerts Endpoints
  static const String alertsEndpoint = '/my-gov-connect/alerts/';
  static const String alertDetailEndpoint = '/alerts/detail/';
  static const String alertsByRegionEndpoint = '/alerts/region/';

  // News Endpoints
  static const String newsEndpoint = '/my-gov-connect/news/';
  static const String newsDetailEndpoint = '/news/detail/';
  static const String newsByCategoryEndpoint = '/news/category/';

  // Surveys & Polls Endpoints
  static const String surveysEndpoint = '/feedback/surveys/';
  static const String surveyDetailEndpoint = '/feedback/surveys/';
  static const String pollsEndpoint = '/feedback/polls/';
  
  // Dynamic endpoints (require ID)
  static String surveyRespondEndpoint(int surveyId) => '/feedback/surveys/$surveyId/respond/';
  static String pollVoteEndpoint(int pollId) => '/feedback/polls/$pollId/vote/';

  // Emergency Contacts Endpoints
  static const String emergencyContactsEndpoint = '/emergency-contacts/';
  static const String emergencyContactsByRegionEndpoint = '/emergency-contacts/region/';
  
  // Notifications Endpoints
  static const String notificationsListEndpoint = '/notifications/list/';
  static const String notificationsMarkAllReadEndpoint = '/notifications/mark-all-read/';
  static const String deviceTokenEndpoint = '/notifications/device-token/';
  static String notificationMarkReadEndpoint(int id) => '/notifications/$id/read/';

  // Directory Listings Endpoints
  static const String directoryListingsEndpoint = '/directory/listings/';
  
  // Feedback Endpoints
  static const String feedbackSubmissionEndpoint = '/feedback/general/';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

