/// User Model for Gov Connect App
///
/// Represents user profile data from the API

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String userType;
  final String preferredLanguage;
  final String? profilePicture;
  final String address;
  final String city;
  final String region;
  final bool isVerified;
  final String lastAppUsed;
  final DateTime dateJoined;
  final DateTime lastLogin;
  final UserProfile profile;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.userType,
    required this.preferredLanguage,
    this.profilePicture,
    required this.address,
    required this.city,
    required this.region,
    required this.isVerified,
    required this.lastAppUsed,
    required this.dateJoined,
    required this.lastLogin,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      userType: json['user_type'] ?? '',
      preferredLanguage: json['preferred_language'] ?? 'en',
      profilePicture: json['profile_picture'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      region: json['region'] ?? '',
      isVerified: json['is_verified'] ?? false,
      lastAppUsed: json['last_app_used'] ?? '',
      dateJoined: DateTime.parse(json['date_joined'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['last_login'] ?? DateTime.now().toIso8601String()),
      profile: UserProfile.fromJson(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'user_type': userType,
      'preferred_language': preferredLanguage,
      'profile_picture': profilePicture,
      'address': address,
      'city': city,
      'region': region,
      'is_verified': isVerified,
      'last_app_used': lastAppUsed,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'profile': profile.toJson(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : username;
}

class UserProfile {
  final String bio;
  final String organization;
  final String position;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final String profileVisibility;
  final Map<String, dynamic> myGovConnectPreferences;
  final Map<String, dynamic> gebetaLehagerPreferences;
  final Map<String, dynamic> snapAndSendPreferences;
  final Map<String, dynamic> yellowPagesPreferences;

  UserProfile({
    required this.bio,
    required this.organization,
    required this.position,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
    required this.profileVisibility,
    required this.myGovConnectPreferences,
    required this.gebetaLehagerPreferences,
    required this.snapAndSendPreferences,
    required this.yellowPagesPreferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'] ?? '',
      organization: json['organization'] ?? '',
      position: json['position'] ?? '',
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      smsNotifications: json['sms_notifications'] ?? false,
      profileVisibility: json['profile_visibility'] ?? 'limited',
      myGovConnectPreferences: json['my_gov_connect_preferences'] ?? {},
      gebetaLehagerPreferences: json['gebeta_lehager_preferences'] ?? {},
      snapAndSendPreferences: json['snap_and_send_preferences'] ?? {},
      yellowPagesPreferences: json['yellow_pages_preferences'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'organization': organization,
      'position': position,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'profile_visibility': profileVisibility,
      'my_gov_connect_preferences': myGovConnectPreferences,
      'gebeta_lehager_preferences': gebetaLehagerPreferences,
      'snap_and_send_preferences': snapAndSendPreferences,
      'yellow_pages_preferences': yellowPagesPreferences,
    };
  }
}

