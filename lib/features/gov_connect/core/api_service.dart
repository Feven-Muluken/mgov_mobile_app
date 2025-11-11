import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// API Service for Gov Connect App
///
/// Handles all HTTP requests with proper error handling and response parsing

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Generic GET request
  Future<ApiResponse> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.buildUrl(endpoint))
          .replace(queryParameters: queryParameters);

      final response = await http
          .get(url, headers: _getHeaders(token: token))
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        data: null,
        errors:null
      );
    }
  }

  /// Generic POST request
  Future<ApiResponse> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.buildUrl(endpoint));

      final response = await http
          .post(
            url,
            headers: _getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        data: null,
        errors:null
      );
    }
  }

  /// Generic PUT request
  Future<ApiResponse> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.buildUrl(endpoint));

      final response = await http
          .put(
            url,
            headers: _getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        data: null,
      );
    }
  }

  /// Generic DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.buildUrl(endpoint));

      final response = await http
          .delete(url, headers: _getHeaders(token: token))
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        data: null,
      );
    }
  }

  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    try {
      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: 'Request successful',
          data: responseData,
          statusCode: response.statusCode,
          errors: responseData["errors"]
        );
      } else {
        print(responseData['errors']);
        return ApiResponse(
          success: false,
          message: responseData['errors'] ?? responseData['message'] ?? 'Request failed',
          data: responseData,
          statusCode: response.statusCode,
          errors: 'error'
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse response: $e',
        data: null,
        statusCode: response.statusCode,
      );
    }
  }

  // ========== AUTH API CALLS ==========

  /// Login user
  Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    return await post(
      ApiConstants.loginEndpoint, 
      body: {
        'username': username,
        'password': password,
      },
    );
  }

  /// Register user
  Future<ApiResponse> register({
    required String userName,
    required String email,
    required String phone_number,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String userType,
    required bool termAccepted,
    required bool privacyConsent,
  }) async {
    return await post(
      ApiConstants.registerEndpoint,
      body: {
        'username': userName,
        'email': email,
        'phone_number': phone_number,
        'password': password,
        "password_confirm": confirmPassword,
        "first_name": firstName,
        "last_name": lastName,
        "user_type": userType,
        "terms_accepted": termAccepted,
        "privacy_consent": privacyConsent
      },
    );
  }

  /// Verify OTP
  Future<ApiResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await post(
      ApiConstants.verifyOtpEndpoint,
      body: {
        'phone_number': phone,
        'otp_code': otp, 
      },
    );
  }

  /// Resend OTP
  Future<ApiResponse> resendOtp({
    required String phoneNumber,
  }) async {
    return await post(
      ApiConstants.resendOtpEndpoint,
      body: {
        'phone_number': phoneNumber,
      },
    );
  }

  Future<ApiResponse> forgetPassword({
    required String phone
  }) async {
    return await post(
      ApiConstants.forgetPasswordEndpoint,
      body: {
        'phone_number': phone,
      });
  }

  /// Reset Password
  Future<ApiResponse> resetPassword({
    required String phoneNumber,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await post(
      ApiConstants.resetPasswordEndpoint,
      body: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // ========== USER PROFILE API CALLS ==========

  /// Get user profile
  Future<ApiResponse> getUserProfile({required String token}) async {
    return await get(
      ApiConstants.userProfileEndpoint,
      token: token,
    );
  }

  /// Update user profile
  Future<ApiResponse> updateUserProfile({
    required String token,
    required Map<String, dynamic> profileData,
  }) async {
    return await put(
      ApiConstants.updateProfileEndpoint,
      token: token,
      body: profileData,
    );
  }

  // ========== ALERTS API CALLS ==========

  /// Get all alerts
  Future<ApiResponse> getAlerts({String? region, String? type, String? title}) async {
    Map<String, String>? queryParams;
    if (region != null || type != null || title != null) {
      queryParams = {};
      if (region != null) queryParams['region'] = region;
      if (type != null) queryParams['type'] = type;
      if (title != null) queryParams['title'] = title;
    }

    return await get(
      ApiConstants.alertsEndpoint,
      queryParameters: queryParams,
    );
  }

  /// Get alert detail
  Future<ApiResponse> getAlertDetail(String alertId) async {
    return await get('${ApiConstants.alertDetailEndpoint}$alertId');
  }

  // ========== NEWS API CALLS ==========

  /// Get all news
  Future<ApiResponse> getNews({String? category, String? title}) async {
    Map<String, String>? queryParams;
    if (category != null || title != null) {
      queryParams = {};
      if (category != null) queryParams['category'] = category;
      if (title != null) queryParams['title'] = title;
    }

    return await get(
      ApiConstants.newsEndpoint,
      queryParameters: queryParams,
    );
  }

  /// Get news detail
  Future<ApiResponse> getNewsDetail(String newsId) async {
    return await get('${ApiConstants.newsDetailEndpoint}$newsId');
  }

  // ========== SURVEYS & POLLS API CALLS ==========

  /// Get all surveys
  Future<ApiResponse> getSurveys({String? token}) async {
    return await get(ApiConstants.surveysEndpoint, token: token);
  }

  /// Get survey detail
  Future<ApiResponse> getSurveyDetail(String surveyId, {String? token}) async {
    return await get('${ApiConstants.surveyDetailEndpoint}$surveyId/', token: token);
  }

  /// Submit survey response
  Future<ApiResponse> submitSurveyResponse({
    required int surveyId,
    required Map<String, String> responses,
    required String appName,
    required bool isComplete,
    String? token,
  }) async {
    return await post(
      ApiConstants.surveyRespondEndpoint(surveyId),
      body: {
        'responses': responses,
        'app_name': appName,
        'is_complete': isComplete,
      },
      token: token,
    );
  }

  /// Get all polls
  Future<ApiResponse> getPolls({String? token}) async {
    return await get(ApiConstants.pollsEndpoint, token: token);
  }

  /// Vote on poll
  Future<ApiResponse> votePoll({
    required int pollId,
    required int selectedOption,
    required String appName,
    String? token,
  }) async {
    final endpoint = ApiConstants.pollVoteEndpoint(pollId);
    final body = {
      'selected_option': selectedOption,
      'app_name': appName,
    };
    
    print('=== API SERVICE DEBUG ===');
    print('Endpoint: $endpoint');
    print('Body: $body');
    print('Has Token: ${token != null}');
    print('=========================');
    
    return await post(
      endpoint,
      body: body,
      token: token,
    );
  }

  // ========== EMERGENCY CONTACTS API CALLS ==========

  /// Get emergency contacts
  Future<ApiResponse> getEmergencyContacts({String? region}) async {
    Map<String, String>? queryParams;
    if (region != null) {
      queryParams = {'region': region};
    }

    return await get(
      ApiConstants.emergencyContactsEndpoint,
      queryParameters: queryParams,
    );
  }

  // ========== DIRECTORY LISTINGS API CALLS ==========

  /// Get directory listings
  Future<ApiResponse> getDirectoryListings({
    String? category,
    String? listingType,
    String? region,
    String? search,
    String? token,
  }) async {
    Map<String, String>? queryParams;
    if (category != null) queryParams?['category'] = category;
    if (listingType != null) queryParams?['listing_type'] = listingType;
    if (region != null) queryParams?['region'] = region;
    if (search != null) queryParams?['search'] = search;

    return await get(
      ApiConstants.directoryListingsEndpoint,
      queryParameters: queryParams,
      token: token,
    );
  }

  // ========== FEEDBACK API CALLS ==========

  /// Submit general feedback
  Future<ApiResponse> submitFeedback({
    required String subject,
    required String message,
    required String category,
    required String appName,
    required bool isAnonymous,
    String? token,
  }) async {
    final body = {
      'subject': subject,
      'message': message,
      'category': category,
      'app_name': appName,
      'is_anonymous': isAnonymous,
    };

    print('=== FEEDBACK API DEBUG ===');
    print('Endpoint: ${ApiConstants.feedbackSubmissionEndpoint}');
    print('Full URL: ${ApiConstants.buildUrl(ApiConstants.feedbackSubmissionEndpoint)}');
    print('Body: $body');
    print('Has Token: ${token != null}');
    print('Token: ${token?.substring(0, 20)}...');
    print('=========================');

    return await post(
      ApiConstants.feedbackSubmissionEndpoint,
      body: body,
      token: token,
    );
  }
}

/// API Response Model
class ApiResponse {
  final bool success;
  final dynamic message;
  final dynamic data;
  final int? statusCode;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.statusCode,
    this.errors
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, errors: $errors)';
  }
}

