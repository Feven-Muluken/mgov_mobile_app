import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/core/localization/language_model.dart';
import 'package:mgov_apps/features/gov_connect/pages/about_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/saved_content_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/privacy_policy_page.dart';
import '../core/api_service.dart';
import '../models/user_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- API Service ---
  final ApiService _apiService = ApiService();
  
  // --- User Data States ---
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  
  // --- App Settings States ---
  String _regionPreference = 'Addis Ababa, Oromia';
  String _applicationLanguage = 'English';

  // --- Notification Preference States ---
  bool _emergencyAlerts = true;
  bool _weatherAlerts = true;
  bool _serviceAlerts = true;
  bool _eventAlerts = true;
  bool _latestNews = true;
  bool _newSurveys = true;
  bool _newPolls = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Sync language after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLanguageWithProvider();
    });
  }

  /// Sync the displayed language with LanguageProvider
  void _syncLanguageWithProvider() {
    if (!mounted) return;
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _applicationLanguage = languageProvider.currentLanguage == AppLanguage.English
          ? 'English'
          : 'አማርኛ';
    });
  }

  /// Load user profile from API
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // TODO: Get token from secure storage or auth service
      String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYwNzExOTI3LCJpYXQiOjE3NjA3MDgzMjcsImp0aSI6ImExMWYxN2YyODhmZTQ5ZTNhZDJiMDVkMjBjMDhiNGQ5IiwidXNlcl9pZCI6MjB9.h-pCRgPUi6FIUBSKyvhptoZirfHBaknvwsFRBsBfW58';
      String? accessToken = await getFromLocalStorage('access_token');
      token = accessToken!;
      final response = await _apiService.getUserProfile(token: token);
      
      if (response.success && response.data != null) {
        final userData = response.data['user'];
        if (userData != null) {
          // Ensure my_gov_connect_preferences is passed to profile if it's at user level
          if (userData['my_gov_connect_preferences'] != null && 
              (userData['profile'] == null || userData['profile']['my_gov_connect_preferences'] == null)) {
            userData['profile'] = userData['profile'] ?? {};
            userData['profile']['my_gov_connect_preferences'] = userData['my_gov_connect_preferences'];
          }
          
          setState(() {
            _user = User.fromJson(userData);
            _isLoading = false;
          });
          
          // Update UI with user data
          _updateUIWithUserData();
        } else {
          setState(() {
            _errorMessage = 'User data not found in response';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  /// Update UI elements with user data
  void _updateUIWithUserData() {
    if (_user != null) {
      setState(() {
        _regionPreference = _user!.region.isNotEmpty ? _user!.region : 'Addis Ababa, Oromia';
        _applicationLanguage = _user!.preferredLanguage == 'en' ? 'English' : 'አማርኛ';
        
        // Update notification preferences from my_gov_connect_preferences
        final preferences = _user!.profile.myGovConnectPreferences;
        
        if (preferences.isNotEmpty && preferences['notification_categories'] != null) {
          final notificationCategories = preferences['notification_categories'] as List<dynamic>? ?? [];
          
          // Map notification categories to toggle states
          // Emergency Alerts -> emergency category
          _emergencyAlerts = notificationCategories.contains('emergency');
          
          // Weather, Service, and Event Alerts -> service_updates category
          // We need to check location_based_alerts or service_updates to determine these
          final hasServiceUpdates = notificationCategories.contains('service_updates');
          final locationBasedAlerts = preferences['location_based_alerts'] as bool? ?? false;
          
          // If service_updates is enabled, enable all service-related alerts
          // Otherwise, check individual preferences if available
          if (hasServiceUpdates) {
            _weatherAlerts = locationBasedAlerts || hasServiceUpdates;
            _serviceAlerts = hasServiceUpdates;
            _eventAlerts = hasServiceUpdates;
          }
          
          // Latest News, Surveys, Polls -> policy_updates category
          final hasPolicyUpdates = notificationCategories.contains('policy_updates');
          if (hasPolicyUpdates) {
            _latestNews = true;
            _newSurveys = true;
            _newPolls = true;
          }
        }
        // If preferences are empty or null, keep current toggle states (don't reset)
      });
    }
  }

  /// Save notification preferences to API
  Future<void> _saveNotificationPreferences() async {
    if (_user == null) return;
    
    try {
      // Get token from local storage
      final token = await getFromLocalStorage('access_token');
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to save preferences'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Build interested_services list - include all services if user has any notifications enabled
      List<String> interestedServices = [];
      bool hasAnyNotifications = _emergencyAlerts || _weatherAlerts || _serviceAlerts || 
                                  _eventAlerts || _latestNews || _newSurveys || _newPolls;
      
      if (hasAnyNotifications) {
        // Include all services if user wants notifications
        interestedServices = ['health', 'education', 'tax', 'business_registration'];
      } else {
        // Default services if no notifications are enabled
        interestedServices = ['health', 'education', 'tax', 'business_registration'];
      }
      
      // Build notification_categories list based on enabled notification types
      List<String> notificationCategories = [];
      if (_emergencyAlerts) {
        notificationCategories.add('emergency');
      }
      if (_latestNews || _newSurveys || _newPolls) {
        notificationCategories.add('policy_updates');
      }
      if (_serviceAlerts || _weatherAlerts || _eventAlerts) {
        notificationCategories.add('service_updates');
      }
      
      // Default categories if none selected
      if (notificationCategories.isEmpty) {
        notificationCategories = ['emergency', 'policy_updates', 'service_updates'];
      }
      
      // Determine preferred communication based on active notifications
      // Push for alerts, email for news/surveys/polls
      String preferredCommunication = 'push';
      if (_latestNews || _newSurveys || _newPolls) {
        if (_emergencyAlerts || _weatherAlerts || _serviceAlerts || _eventAlerts) {
          // User wants both - default to push for real-time alerts
          preferredCommunication = 'push';
        } else {
          // Only news/surveys/polls - use email
          preferredCommunication = 'email';
        }
      }
      
      // Get language preference from LanguageProvider
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      String languagePreference = languageProvider.currentLanguage == AppLanguage.English ? 'en' : 'am';
      
      // Build my_gov_connect_preferences object
      final profileData = {
        'my_gov_connect_preferences': {
          'interested_services': interestedServices.isNotEmpty 
              ? interestedServices 
              : ['health', 'education', 'tax', 'business_registration'], // Default if none selected
          'notification_categories': notificationCategories.isNotEmpty
              ? notificationCategories
              : ['emergency', 'policy_updates', 'service_updates'], // Default if none selected
          'location_based_alerts': _emergencyAlerts || _weatherAlerts || _serviceAlerts,
          'preferred_communication': preferredCommunication,
          'language_preference': languagePreference,
        }
      };
      
      final response = await _apiService.updateUserProfile(
        token: token,
        profileData: profileData,
      );
      
      if (response.success) {
        // Update user object from response if available, but preserve current toggle states
        // since we just saved them successfully
        if (response.data != null && response.data['user'] != null) {
          final userData = response.data['user'];
          // Ensure my_gov_connect_preferences is passed to profile if it's at user level
          if (userData['my_gov_connect_preferences'] != null && 
              (userData['profile'] == null || userData['profile']['my_gov_connect_preferences'] == null)) {
            userData['profile'] = userData['profile'] ?? {};
            userData['profile']['my_gov_connect_preferences'] = userData['my_gov_connect_preferences'];
          }
          
          // Update user object with response data (for other fields like name, email, etc.)
          setState(() {
            _user = User.fromJson(userData);
            // DO NOT call _updateUIWithUserData() here - it would reset toggle states
            // The toggle states are already correct since we just saved them
          });
        }
        
        // Show success message - toggle states remain as user set them
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        String errorMessage = response.message ?? 'Failed to save preferences';
        
        // Try to extract error from response data
        if (response.data != null && response.data['errors'] != null) {
          final errors = response.data['errors'];
          if (errors is Map) {
            errorMessage = errors.values.first is List
                ? errors.values.first[0]
                : errors.values.first.toString();
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Logout user and clear all stored data
  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (shouldLogout != true) return;

      // Clear all user data from local storage
      await removeFromLocalStorage('user_data');
      await removeFromLocalStorage('access_token');
      await removeFromLocalStorage('refresh_token');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to login page
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings Page', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            // 2. Saved Content Banner
            _buildSavedContentBanner(),
            
            // 3. App Settings Section
            _buildSectionHeader('App Settings'),
            _buildAppSettingItem(
              icon: Icons.place_outlined,
              title: 'Region Preference',
              subtitle: _regionPreference,
              onTap: () {
                // Handle region selection logic
                print('Change Region');
              },
            ),
            _buildAppSettingItem(
              icon: Icons.translate_outlined,
              title: 'Application Language',
              subtitle: _applicationLanguage,
              onTap: () async {
                // Toggle language using LanguageProvider
                final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                await languageProvider.toggleLanguage();
                
                // Update the displayed language text
                setState(() {
                  _applicationLanguage = languageProvider.currentLanguage == AppLanguage.English
                      ? 'English'
                      : 'አማርኛ';
                });
              },
            ),

            const SizedBox(height: 20),
            
            // 3. Notifications Section
            _buildSectionHeader('Notifications'),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Text(
                'Notifications are affected by regional preferences',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

            // Alerts Notifications
            _buildNotificationToggle(
              title: 'Emergency Alerts',
              value: _emergencyAlerts,
              onToggle: (val) {
                setState(() => _emergencyAlerts = val);
                _saveNotificationPreferences();
              },
            ),
            _buildNotificationToggle(
              title: 'Weather Alerts',
              value: _weatherAlerts,
              onToggle: (val) {
                setState(() => _weatherAlerts = val);
                _saveNotificationPreferences();
              },
            ),
            _buildNotificationToggle(
              title: 'Service Alerts',
              value: _serviceAlerts,
              onToggle: (val) {
                setState(() => _serviceAlerts = val);
                _saveNotificationPreferences();
              },
            ),
            _buildNotificationToggle(
              title: 'Event Alerts',
              value: _eventAlerts,
              onToggle: (val) {
                setState(() => _eventAlerts = val);
                _saveNotificationPreferences();
              },
            ),

            const Divider(height: 1),

            // Content Notifications
            _buildNotificationToggle(
              title: 'Latest News',
              value: _latestNews,
              onToggle: (val) {
                setState(() => _latestNews = val);
                _saveNotificationPreferences();
              },
            ),
            _buildNotificationToggle(
              title: 'New Surveys',
              value: _newSurveys,
              onToggle: (val) {
                setState(() => _newSurveys = val);
                _saveNotificationPreferences();
              },
            ),
            _buildNotificationToggle(
              title: 'New Polls',
              value: _newPolls,
              onToggle: (val) {
                setState(() => _newPolls = val);
                _saveNotificationPreferences();
              },
            ),

            const SizedBox(height: 20),

            // 4. Info/Account Section
            _buildSectionHeader('Info & Account'),
            
            _buildInfoItem(
              icon: Icons.lock_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
            _buildInfoItem(
              icon: Icons.info_outline,
              title: 'About MyGov Connect',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
              },
            ),

            // 5. Action Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logout Button
                  OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),

                  // Delete Account Button
                  TextButton(
                    onPressed: () => print('Delete Account'),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  
                  // App Version
                  const SizedBox(height: 20),
                  const Text(
                    'App Version: V1.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // Bottom spacing
          ],
        ),
      );
  }

  // --- Reusable Widget Builders ---

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEFD5),
            Color(0xFFFFFFFF), // white at bottom
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Profile Picture or Icon
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: _user?.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      _user!.profilePicture!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.blue.shade700,
                  ),
          ),
          const SizedBox(height: 12),
          
          // User Name
          Text(
            _user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // User Email
          Text(
            _user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          
          // User Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _user?.userType == 'citizen' 
                  ? Colors.green.shade100 
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _user?.userType.toUpperCase() ?? 'USER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _user?.userType == 'citizen' 
                    ? Colors.green.shade700 
                    : Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Login Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                _user?.phoneNumber ?? 'No phone number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedContentBanner() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SavedContentPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.bookmark_outline, color: Colors.black87),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saved Content', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Saved Alerts, News & Surveys', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildAppSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required bool value,
    //required ValueChanged<bool> onChanged,
    required ValueChanged<bool> onToggle,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Checkbox(
        value: value,
        onChanged: (bool? newValue) { 
        if (newValue != null) {
          onToggle(newValue); 
        }
      },
      activeColor: Colors.blue.shade700,
    ),
    onTap: () => onToggle(!value), 
      
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
      onTap: onTap,
    );
  }
}