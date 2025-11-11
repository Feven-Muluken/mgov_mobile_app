import 'package:flutter/material.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_detail_page.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/pages/filter_search_modal.dart';

// --- Data Model and Enum for Alerts ---

enum AlertType { emergency, weather, service }

// class Alert {
//   final String title;
//   final AlertType type;
//   final String date;
//   final String location;

//   Alert({
//     required this.title,
//     required this.type,
//     required this.date,
//     required this.location,
//   });
// }

class Alert {
  final String title;
  final AlertType type;
  final String date;
  final String location;
  final String? time;        
  final String? status;      
  final String? details;     
  final List<String>? evacuationCenters;


  Alert({
    required this.title,
    required this.type,
    required this.date,
    required this.location,
    this.time,
    this.status,
    this.details,
    this.evacuationCenters,
  });
}

// Mock Data List
// final List<Alert> mockAlerts = [
//   Alert(
//     title: 'Heavy Rainfall Flood Warning — immediate Evacuation Required in Bahir Dar',
//     type: AlertType.emergency,
//     date: '1 day ago',
//     location: 'Bahir Dar',
//   ),
//   Alert(
//     title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
//     type: AlertType.emergency,
//     date: 'Jan 21, 2025',
//     location: 'Addis Ababa',
//   ),
//   Alert(
//     title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
//     type: AlertType.weather,
//     date: 'Jan 21, 2025',
//     location: 'Addis Ababa',
//   ),
//   Alert(
//     title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
//     type: AlertType.weather,
//     date: 'Jan 21, 2025',
//     location: 'Addis Ababa',
//   ),
//   Alert(
//     title: 'High wind advisory in Dire Dawa. Secure outdoor items.',
//     type: AlertType.weather,
//     date: 'Jan 20, 2025',
//     location: 'Dire Dawa',
//   ),
// ];

final List<Alert> mockAlerts = [
  // 1. EMERGENCY: Heavy Rainfall (Full Detail Data Included)
  Alert(
    title: 'Heavy Rainfall Flood Warning — immediate Evacuation Required in Bahir Dar',
    type: AlertType.emergency,
    date: '1 day ago', // Note: Date here is relative for the list view
    location: 'Bahir Dar',
    
    // DETAIL FIELDS
    time: '10:00 AM',
    status: 'Active',
    details: 'Due to continuous heavy rainfall over the past 48 hours, severe flooding is expected...',
    evacuationCenters: [
      'Bahir Dar University Main Hall',
      'Bahir Dar Stadium',
    ],
  ),

  // 2. EMERGENCY: Flood warning (Simpler detail data)
  Alert(
    title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
    type: AlertType.emergency,      
    date: 'Jan 21, 2025',
    location: 'Addis Ababa',
    
    // DETAIL FIELDS
    time: '12:00 PM',
    status: 'Active',
    details: 'Low-lying areas near the river are at high risk. Move to higher ground immediately.',
    evacuationCenters: [], // Empty list if none are specified
  ),

  // 3. WEATHER: Flood warning (Simple/No Detail data needed for list)
  Alert(
    title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
    type: AlertType.weather,
    date: 'Jan 21, 2025',
    location: 'Addis Ababa',
  ),

  // 4. WEATHER: Flood warning (Simple/No Detail data needed for list)
  Alert(
    title: 'Flood warning in Addis Ababa — Evacuate low-lying areas immediately',
    type: AlertType.weather,
    date: 'Jan 21, 2025',
    location: 'Addis Ababa',
  ),

  // 5. WEATHER: High wind advisory (Simple/No Detail data needed for list)
  Alert(
    title: 'High wind advisory in Dire Dawa. Secure outdoor items.',
    type: AlertType.weather,
    date: 'Jan 20, 2025',
    location: 'Dire Dawa',
    
    // DETAIL FIELDS (Example of a weather alert having a different status)
    status: 'Expired',
  ),
  
  // (You can add more alerts here to reach the total count, following the pattern)
];

// --- The Main Page Widget ---

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _selectedFilter = 'All';
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // State variables for alerts
  bool _isLoadingAlerts = true;
  bool _hasAlertsError = false;
  String _alertsErrorMessage = '';
  List<Alert> _allAlertsList = [];
  List<Alert> _filteredAlertsList = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _fetchAlerts({String? type, String? region}) async {
    setState(() {
      _isLoadingAlerts = true;
      _hasAlertsError = false;
    });

    try {
      final response = await _apiService.getAlerts(type: type, region: region);
      
      if (response.success && response.data != null) {
        // Parse the alerts from API response
        final List<dynamic> alertsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _allAlertsList = alertsData.map((json) => _parseAlert(json)).toList();
          _filteredAlertsList = _allAlertsList;
          _isLoadingAlerts = false;
        });
      } else {
        setState(() {
          _hasAlertsError = true;
          _alertsErrorMessage = response.message;
          _isLoadingAlerts = false;
          // Use mock data as fallback
          _allAlertsList = mockAlerts;
          _filteredAlertsList = mockAlerts;
        });
      }
    } catch (e) {
      setState(() {
        _hasAlertsError = true;
        _alertsErrorMessage = 'Failed to load alerts: $e';
        _isLoadingAlerts = false;
        // Use mock data as fallback
        _allAlertsList = mockAlerts;
        _filteredAlertsList = mockAlerts;
      });
    }
  }

  void _filterAlerts(String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
      
      if (filterKey == 'All') {
        _filteredAlertsList = _allAlertsList;
      } else {
        _filteredAlertsList = _allAlertsList.where((alert) {
          final filterKeyLower = filterKey.toLowerCase();
          final alertTypeName = alert.type.name.toLowerCase();
          
          if (filterKeyLower == 'emergencies' || filterKeyLower == 'emergency') {
            return alertTypeName == 'emergency';
          } else if (filterKeyLower == 'weather') {
            return alertTypeName == 'weather';
          } else if (filterKeyLower == 'services' || filterKeyLower == 'service') {
            return alertTypeName == 'service';
          }
          return true;
        }).toList();
      }
    });
  }

  Alert _parseAlert(dynamic json) {
    // Parse alert type
    AlertType alertType = AlertType.service;
    final typeStr = (json['type'] ?? json['alert_type'] ?? 'service').toString().toLowerCase();
    
    if (typeStr == 'emergency') {
      alertType = AlertType.emergency;
    } else if (typeStr == 'weather') {
      alertType = AlertType.weather;
    } else if (typeStr == 'service') {
      alertType = AlertType.service;
    }

    // Parse evacuation centers
    List<String>? evacuationCenters;
    if (json['evacuation_centers'] != null && json['evacuation_centers'] is List) {
      evacuationCenters = List<String>.from(json['evacuation_centers']);
    }

    return Alert(
      title: json['title'] ?? json['message'] ?? 'No title',
      type: alertType,
      date: _formatDate(json['date'] ?? json['created_at'] ?? json['published_at']),
      location: json['location'] ?? json['region'] ?? 'Unknown',
      time: json['time'],
      status: json['status'] ?? 'Active',
      details: json['details'] ?? json['description'] ?? json['message'],
      evacuationCenters: evacuationCenters,
    );
  }

  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'Recently';
    
    try {
      final DateTime parsedDate = DateTime.parse(dateTime.toString());
      final Duration difference = DateTime.now().difference(parsedDate);
      
      if (difference.inDays > 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          _buildFilterChips(),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          
          // Error Banner
          if (_hasAlertsError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using cached data: $_alertsErrorMessage',
                      style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.orange.shade700, size: 20),
                    onPressed: () => _fetchAlerts(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          
          // Alerts Title and Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.strings.alerts,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredAlertsList.length} ${context.strings.results}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Alerts List View
          Expanded(
            child: _buildAlertsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsContent() {
    if (_isLoadingAlerts) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredAlertsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasAlertsError 
                  ? 'Failed to load alerts. Pull down to retry.'
                  : 'All clear! No active alerts at the moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_hasAlertsError)
              ElevatedButton.icon(
                onPressed: () => _fetchAlerts(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAlerts,
      child: ListView.builder(
        itemCount: _filteredAlertsList.length,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return AlertCard(alert: _filteredAlertsList[index]);
        },
      ),
    );
  }

  // --- AppBar Widget ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      // The current time is typically handled by the OS status bar, but
      // we can emulate the layout elements below the status bar.
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     // Handle back button action
          //   },
          // ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.strings.searchForAlert,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {});
                  // Debounce search - perform search after user stops typing
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value && mounted) {
                      _performSearch(value);
                    }
                  });
                },
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list_rounded),
          //   onPressed: () {
          //     // Handle filter/settings action
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchModal()));
          //   },
          // ),
        ],
      ),
      // Set the height of the AppBar to be standard
      toolbarHeight: 60,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  void _performSearch(String query) {
    final searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      // Reset to show all alerts
      _fetchAlerts();
    } else {
      // Search alerts by title
      _searchAlerts(searchQuery);
    }
  }

  Future<void> _searchAlerts(String title) async {
    setState(() {
      _isLoadingAlerts = true;
      _hasAlertsError = false;
    });

    try {
      final response = await _apiService.getAlerts(title: title);
      
      if (response.success && response.data != null) {
        final List<dynamic> alertsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _allAlertsList = alertsData.map((json) => _parseAlert(json)).toList();
          _filteredAlertsList = _allAlertsList;
          _isLoadingAlerts = false;
        });
      } else {
        setState(() {
          _hasAlertsError = true;
          _alertsErrorMessage = response.message ?? 'No alerts found';
          _isLoadingAlerts = false;
          _allAlertsList = [];
          _filteredAlertsList = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasAlertsError = true;
        _alertsErrorMessage = 'Failed to search alerts: $e';
        _isLoadingAlerts = false;
        _allAlertsList = [];
        _filteredAlertsList = [];
      });
    }
  }

  // --- Filter Chips Widget ---
  Widget _buildFilterChips() {
    final strings = context.strings;
    final filterData = [
      {'key': 'All', 'label': strings.all, 'icon': null},
      {'key': 'Emergencies', 'label': strings.emergencies, 'icon': Icons.local_fire_department_outlined},
      {'key': 'Weather', 'label': strings.weather, 'icon': Icons.cloud_outlined},
      {'key': 'Services', 'label': strings.services, 'icon': Icons.settings_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filterData.map((filterItem) {
          final filterKey = filterItem['key'] as String;
          final filterLabel = filterItem['label'] as String;
          final iconData = filterItem['icon'] as IconData?;
          final isSelected = _selectedFilter == filterKey;
          Color? iconColor = isSelected ? Colors.white : Colors.grey.shade600;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filterLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              avatar: iconData != null
                  ? Icon(iconData, size: 18, color: iconColor)
                  : null,
              selected: isSelected,
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                ),
              ),
              onSelected: (bool selected) {
                _filterAlerts(filterKey);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

 
}

// --- Alert Card Widget (Reusable Component) ---

class AlertCard extends StatelessWidget {
  final Alert alert;
  
  const AlertCard({required this.alert, super.key});

  Color get _borderColor {
    switch (alert.type) {
      case AlertType.emergency:
        return Colors.red.shade400; 
      case AlertType.weather:
        return Colors.blue.shade400; 
      case AlertType.service:
        return Colors.green.shade400; 
    }
  }

  Color get _tagColor {
    switch (alert.type) {
      case AlertType.emergency:
        return Colors.red.shade50; // Very light red/pink background
      case AlertType.weather:
        return Colors.blue.shade50;  // Very light blue background
      case AlertType.service:
        return Colors.green.shade50; // Example
    }
  }

  IconData get _tagIcon {
    switch (alert.type) {
      case AlertType.emergency:
        return Icons.local_fire_department_outlined; 
      case AlertType.weather:
        return Icons.cloud_outlined;
      case AlertType.service:
        return Icons.settings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AlertDetailPage(alert: alert)));
      },
     child:Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Tag (Emergency/Weather)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _tagColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_tagIcon, size: 16, color: _borderColor),
                const SizedBox(width: 4),
                Text(
                  alert.type.name.capitalize(),
                  style: TextStyle(
                    //color: _borderColor.shade900,
                    color: _borderColor.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Alert Title
          Text(
            alert.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Date and Location Row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(alert.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(alert.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    )
  );
  }
}

// Extension to capitalize the first letter of the enum name
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
