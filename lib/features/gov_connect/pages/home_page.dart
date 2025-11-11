import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_detail_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_page.dart' as alert_page;
import 'package:mgov_apps/features/gov_connect/pages/emergency_contacts_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/filter_search_modal.dart';
import 'package:mgov_apps/features/gov_connect/pages/news_detail_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/news_page.dart' as news_page;
import 'package:mgov_apps/features/gov_connect/pages/profile_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/surveys_polls_page.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';

// --- Data Models for the UI (Mock Data) ---

class Alert {
  final String title;
  final String type;
  final String snippet;
  final Color color;

  Alert({
    required this.title,
    required this.type,
    required this.snippet,
    required this.color,
  });
}

class NewsArticle {
  final String title;
  final String category;
  final String snippet;
  final String timeAgo;
  final List<dynamic> imageUrl;

  NewsArticle({
    required this.title,
    required this.category,
    required this.snippet,
    required this.timeAgo,
    required this.imageUrl,
  });
}

// Mock Data
// final List<Alert> mockAlerts = [
//   Alert(
//     title: 'Flood Warning in Addis Ababa',
//     type: 'EMERGENCY',
//     snippet: 'Evacuate low-lying areas. Check local news for shelter locations.',
//     color: Colors.red.shade700,
//   ),
//   Alert(
//     title: 'Severe Thunderstorm Expected',
//     type: 'WEATHER',
//     snippet: 'Heavy rains and strong winds are expected tomorrow afternoon.',
//     color: Colors.blue.shade700,
//   ),
//   Alert(
//     title: 'Water Service Interruption',
//     type: 'SERVICE',
//     snippet: 'Scheduled maintenance on Monday, 8am-5pm in Zone 3.',
//     color: Colors.orange.shade700,
//   ),
// ];

final List<NewsArticle> mockNews = [
  NewsArticle(
    title: 'Government Launches Youth Skill Development Program',
    category: 'Jobs & Youth',
    snippet: 'New initiative aims to train over 10,000 young individuals in IT and trades.',
    timeAgo: '2 hours ago',
    imageUrl: ['https://picsum.photos/id/1015/600/400'], // Mock image
  ),
  NewsArticle(
    title: 'New Public Health Clinic Opens in Oromia Region',
    category: 'Public Health',
    snippet: 'The facility will provide essential services and vaccinations to rural communities.',
    timeAgo: '1 day ago',
    imageUrl: ['https://picsum.photos/id/350/600/400',] // Mock image
  ),
  NewsArticle(
    title: 'Progress on New Rail Line Infrastructure',
    category: 'Infrastructure',
    snippet: 'The project is 60% complete and on track for an early 2026 launch.',
    timeAgo: '3 days ago',
    imageUrl: ['https://picsum.photos/id/1025/600/400'], // Mock image
  ),
];

// --- Widgets ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

@override
State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  int _selectedIndex = 0;
  bool _isGuest = false;

  // The screens that will be displayed in the body of the Scaffold
  List<Widget> get _widgetOptions {
    if (_isGuest) {
      // Guest users: only Home, Alerts, and News
      return <Widget>[
        HomeDashboardPage(onNavigateToTab: _onItemTapped, isGuest: _isGuest),
        const alert_page.AlertsPage(),
        const news_page.NewsPage(),
      ];
    } else {
      // Registered users: all pages including Surveys
      return <Widget>[
        HomeDashboardPage(onNavigateToTab: _onItemTapped, isGuest: _isGuest),
        const alert_page.AlertsPage(),
        const news_page.NewsPage(),
        const SurveysPollsPage(),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkGuestStatus() async {
    final isGuestValue = await getFromLocalStorage('is_guest');
    setState(() {
      _isGuest = isGuestValue == 'true';
    });
  }

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: _buildAppBar(context),
      body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
        items: _isGuest 
          ? <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: context.strings.home),
              BottomNavigationBarItem(icon: const Icon(Icons.notifications_active), label: context.strings.alerts),
              BottomNavigationBarItem(icon: const Icon(Icons.article), label: context.strings.news),
            ]
          : <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: context.strings.home),
              BottomNavigationBarItem(icon: const Icon(Icons.notifications_active), label: context.strings.alerts),
              BottomNavigationBarItem(icon: const Icon(Icons.article), label: context.strings.news),
              BottomNavigationBarItem(icon: const Icon(Icons.poll), label: context.strings.surveys),
            ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E88E5), // Primary blue color
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all labels are always visible
        backgroundColor: Colors.white,
        )
    );
  }

}

class HomeDashboardPage extends StatefulWidget{
  final Function(int)? onNavigateToTab;
  final bool isGuest;

  const HomeDashboardPage({super.key, this.onNavigateToTab, this.isGuest = false});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  // State variables for alerts
  bool _isLoadingAlerts = true;
  bool _hasAlertsError = false;
  String _alertsErrorMessage = '';
  List<Alert> _alerts = [];
  
  // State variables for news
  bool _isLoadingNews = true;
  bool _hasNewsError = false;
  String _newsErrorMessage = '';
  List<NewsArticle> _newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
    _fetchNews();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoadingAlerts = true;
      _hasAlertsError = false;
    });

    try {
      final response = await _apiService.getAlerts();
      
      if (response.success && response.data != null) {
        // Parse the alerts from API response
        final List<dynamic> alertsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _alerts = alertsData.map((json) => _parseAlert(json)).toList();
          _isLoadingAlerts = false;
          print(_alerts[0].title);
        });
      } else {
        setState(() {
          _hasAlertsError = true;
          _alertsErrorMessage = response.message;
          _isLoadingAlerts = false;
          // Use mock data as fallback
          //_alerts = mockAlerts;
        });
      }
    } catch (e) {
      setState(() {
        _hasAlertsError = true;
        _alertsErrorMessage = 'Failed to load alerts: $e';
        _isLoadingAlerts = false;
        // Use mock data as fallback
        //_alerts = mockAlerts;
      });
    }
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoadingNews = true;
      _hasNewsError = false;
    });

    try {
      final response = await _apiService.getNews();
      
      if (response.success && response.data != null) {
        // Parse the news from API response
        final List<dynamic> newsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _newsList = newsData.map((json) => _parseNews(json)).toList();
          _isLoadingNews = false;
          print(_newsList[0].imageUrl);
        });
      } else {
        setState(() {
          _hasNewsError = true;
          _newsErrorMessage = response.message;
          _isLoadingNews = false;
          // Use mock data as fallback
          //_newsList = mockNews;
        });
      }
    } catch (e) {
      setState(() {
        _hasNewsError = true;
        _newsErrorMessage = 'Failed to load news: $e';
        _isLoadingNews = false;
        // Use mock data as fallback
        //_newsList = mockNews;
      });
    }
  }

  Alert _parseAlert(dynamic json) {
    return Alert(
      title: json['title'] ?? json['message'] ?? 'No title',
      type: json['type'] ?? json['alert_type'] ?? 'SERVICE',
      snippet: json['description'] ?? json['snippet'] ?? json['message'] ?? '',
      color: _getAlertColor(json['category'] ?? json['alert_type'] ?? 'SERVICE'),
    );
  }

  NewsArticle _parseNews(dynamic json) {

    dynamic rawImage = json['featured_images'] ?? json['image'];

  List<dynamic> images;

  if (rawImage == null) {
    // No image at all → fallback placeholder
    images = ['https://picsum.photos/600/400'];
  } else if (rawImage is List) {
    // Already a list from API → keep it
    images = rawImage;
  } else if (rawImage is String) {
    // Single image string → wrap it in a list
    images = [rawImage];
  } else {
    // Unexpected type → fallback
    images = ['https://picsum.photos/600/400'];
  }

    return NewsArticle(
      title: json['title'] ?? 'No title',
      category: json['category'] ?? 'General',
      snippet: json['description'] ?? json['snippet'] ?? json['excerpt'] ?? '',
      timeAgo: _formatTimeAgo(json['created_at'] ?? json['published_at']),
      imageUrl:  images ,
    );
  }

  Color _getAlertColor(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return Colors.red.shade700;
      case 'WEATHER':
        return Colors.blue.shade700;
      case 'SERVICE':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatTimeAgo(dynamic dateTime) {
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
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

@override
Widget build(BuildContext context){
  return Scaffold( 
    backgroundColor: Colors.white,
    appBar: _buildAppBar(context),
    body:  SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const NewAlertBanner(),
            _buildSearchBar(context),
            const SizedBox(height: 20),
            _buildSectionHeader(
              context, 
              title: context.strings.alerts, 
              actionText: context.strings.viewAll,
              onTap: () { 
                // Navigate to the full Alerts screen
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Alerts page index
                }
              },
            ),
            if (_hasAlertsError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Using cached data: $_alertsErrorMessage',
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _isLoadingAlerts 
                ? const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : AlertsCarousel(alerts: _alerts),
            const SizedBox(height: 30),
            //const EmergencyContactsBlock(),
            const EmergencyContactCard(),
            const SizedBox(height: 30),
            _buildSectionHeader(
              context, 
              title: context.strings.latestNews, 
              actionText: context.strings.browseMoreNews,
              onTap: () { 
                // Navigate to the full News Feed screen
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(2); // Alerts page index
                }
              },
            ),
            if (_hasNewsError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Using cached data: $_newsErrorMessage',
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _isLoadingNews 
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : NewsFeed(news: _newsList),
            //const SizedBox(height: 40),
            elevatedButton(context),
            const SizedBox(height: 40),
          ],
        ),
      )
  );
} 

Widget elevatedButton(BuildContext context){
  return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child:Row(
        children: [
        Expanded(  
        child:ElevatedButton(
                onPressed: () async{
                    if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(2); 
                    }
                  },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF003399),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  context.strings.browseAllNews,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              
            ),
          )
        ]
      ),
);
}

AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: widget.isGuest
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              // Clear guest flag and navigate to login
              await removeFromLocalStorage('is_guest');
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        : null,
      automaticallyImplyLeading: !widget.isGuest,
      title: Text(
        context.strings.mygovConnect,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: widget.isGuest 
        ? [] // No settings/profile button for guests
        : [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (context) => const SettingsPage()),
                // );
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              },
            ),
          ],
      // Setting a small elevation to lift the AppBar off the body
      elevation: 4.0, 
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(16.0, ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
        Expanded(  
        child:TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: context.strings.searchMygovConnect,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          onChanged: (value) {
            setState(() {});
            // Debounce search - perform search after user stops typing
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: (value) {
            _performSearch(value);
          },
        ),
        ),

      //Spacer(),
      // IconButton(
      //   icon: const Icon(
      //     Icons.filter_list,
      //     // You can customize the color and size here
      //     color: Colors.grey, 
      //     //size: 24.0, 
      //   ),
      //   onPressed: () {
      //     // Action to perform when the button is pressed (e.g., open a filter menu)
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => FilterSearchModal()));
      //   },
      // )
        ],
      ),
    );
  }

  void _performSearch(String query) {
    final searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      // Reset to show all alerts and news
      _fetchAlerts();
      _fetchNews();
    } else {
      // Search alerts and news
      _searchAlerts(searchQuery);
      _searchNews(searchQuery);
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
          _alerts = alertsData.map((json) => _parseAlert(json)).toList();
          _isLoadingAlerts = false;
        });
      } else {
        setState(() {
          _hasAlertsError = true;
          _alertsErrorMessage = response.message ?? 'No alerts found';
          _isLoadingAlerts = false;
          _alerts = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasAlertsError = true;
        _alertsErrorMessage = 'Failed to search alerts: $e';
        _isLoadingAlerts = false;
        _alerts = [];
      });
    }
  }

  Future<void> _searchNews(String title) async {
    setState(() {
      _isLoadingNews = true;
      _hasNewsError = false;
    });

    try {
      final response = await _apiService.getNews(title: title);
      
      if (response.success && response.data != null) {
        final List<dynamic> newsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _newsList = newsData.map((json) => _parseNews(json)).toList();
          _isLoadingNews = false;
        });
      } else {
        setState(() {
          _hasNewsError = true;
          _newsErrorMessage = response.message ?? 'No news found';
          _isLoadingNews = false;
          _newsList = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasNewsError = true;
        _newsErrorMessage = 'Failed to search news: $e';
        _isLoadingNews = false;
        _newsList = [];
      });
    }
  }

  Widget _buildSectionHeader(
    BuildContext context, {
      required String title,
      required String actionText,
      required VoidCallback onTap,
    }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              '$actionText →',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// --- New Alert Banner Widget ---
class NewAlertBanner extends StatefulWidget {
  const NewAlertBanner({super.key});
@override
State<NewAlertBanner> createState() => _NewAlertBannerState();
}

class _NewAlertBannerState extends State<NewAlertBanner> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = true; // State to control the visibility/dismissal

  // Define the exact color from the video (a warm, slightly muted orange)
  final Color _bannerColor = const Color(0xFFE5A93D);


@override
void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Animation speed
    );

    // 2. Define the Animation (Slide from top)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5), // Start position: 1.5x its height above the screen
      end: Offset.zero,              // End position: fully visible (Offset.zero)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Use a smooth curve
    ));

    // 3. Start the animation when the widget is built
    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissBanner() {
    // Animate the banner back up (or fade out) before removing it
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink(); // Hide the widget when dismissed
    }

    return SlideTransition(
    position: _offsetAnimation,
    child: Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        //color: const Color(0xFFFFE0B2), // Light Orange/Amber background
        color: _bannerColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.warning_rounded, color: Colors.deepOrange, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.stringsNoListen.newAlertMessage,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Optionally add a close button
          InkWell(
            onTap: () {
              // TODO: Implement dismissal logic (e.g., set state or use a provider)
              _dismissBanner();
            },
            child: const Icon(Icons.close, color: Colors.deepOrange, size: 20),
          ),
        ],
      ),
    )
    );
  }
}

// --- Alerts Carousel Widget ---
class AlertsCarousel extends StatelessWidget {
  final List<Alert> alerts;
  const AlertsCarousel({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text('No alerts available at the moment'),
        ),
      );
    }

    return SizedBox(
      height: 140, // Height for the horizontal scroll view
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == alerts.length - 1 ? 16.0 : 8.0,
            ),
            child: AlertCard(alert: alerts[index]),
          );
        },
      ),
    );
  }
}

// --- Individual Alert Card Widget ---
class AlertCard extends StatelessWidget {
  final Alert alert;
  const AlertCard({super.key, required this.alert});

  // Convert home_page Alert to alert_page Alert
  alert_page.Alert _convertToAlertPageAlert(Alert alert) {
    // Map String type to AlertType enum
    alert_page.AlertType alertType;
    switch (alert.type.toUpperCase()) {
      case 'EMERGENCY':
        alertType = alert_page.AlertType.emergency;
        break;
      case 'WEATHER':
        alertType = alert_page.AlertType.weather;
        break;
      case 'SERVICE':
        alertType = alert_page.AlertType.service;
        break;
      default:
        alertType = alert_page.AlertType.service;
    }

    return alert_page.Alert(
      title: alert.title,
      type: alertType,
      date: DateTime.now().toString().split(' ')[0], // Use current date as default
      location: '', // Default empty location
      details: alert.snippet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to Alert Detail Screen
        final convertedAlert = _convertToAlertPageAlert(alert);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertDetailPage(alert: convertedAlert),
          ),
        );
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          // border: Border(
          //   left: BorderSide(color: alert.color, width: 6),
          //   top: const BorderSide(color: Colors.grey, width: 1),
          //   right: const BorderSide(color: Colors.grey, width: 1),
          //   bottom: const BorderSide(color: Colors.grey, width: 1),
            
          //   ),
          border: Border.all(color: alert.color, width: 6),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: alert.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                alert.type,
                style: TextStyle(
                  color: alert.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              alert.snippet,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              context.strings.postedDaysAgo, // Mock date
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),   
    child: Container(
      // width: 400,
      // padding: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        //color: const Color(0xFFFDFCFB), // light background 
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
           // Color(0xFFFFFBF2), // light cream at top
            Color(0xFFFFEFD5),
            Color(0xFFFFFFFF), // white at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Text + Illustration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.strings.lookingForEmergencyContacts,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                  ],
                ),
              ),
              // Illustration (replace with Image.asset or SVG)
              const SizedBox(
                height: 100,
                width: 100,
                //child: Icon(Icons.support_agent, size: 80, color: Colors.amber),
                child: Image(image: AssetImage('assets/images/contact_illustrator.png'))
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                side: const BorderSide(color: Color(0xFF1A4D9E), width: 1.5),
              ),
              onPressed: () {
                // Navigate to emergency contacts
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyContactsPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.strings.emergencyContactsList,
                    style: const TextStyle(
                      //color: Colors.blue,
                      color: Color(0xFF1A4D9E),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Color(0xFF1A4D9E),),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    );
  }
}

// --- Emergency Contacts Block Widget ---
class EmergencyContactsBlock extends StatelessWidget {
  const EmergencyContactsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1), // Light blue background
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.contact_phone, color: Color(0xFF1E88E5), size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Looking for Emergency Contacts?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Emergency Contacts List
                    },
                    child: Text(
                      'Emergency Contacts List →',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- News Feed Widget (Vertical List) ---
class NewsFeed extends StatelessWidget {
  final List<NewsArticle> news;
  const NewsFeed({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No news available at the moment'),
        ),
      );
    }

    return ListView.builder(
      // Important to use shrinkWrap and never scrollable physics in a SingleChildScrollView
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemCount: news.length,
      itemBuilder: (context, index) {
        return NewsCard(article: news[index]);
      },
    );
  }
}

// --- Individual News Card Widget ---
class NewsCard extends StatelessWidget {
  final NewsArticle article;
  const NewsCard({super.key, required this.article});

  // Convert home_page NewsArticle to news_page NewsArticle
  news_page.NewsArticle _convertToNewsPageArticle(NewsArticle article) {
    // Convert List<dynamic> to List<String>
    List<String> imageUrls = article.imageUrl
        .map((item) => item.toString())
        .toList();

    return news_page.NewsArticle(
      title: article.title,
      category: article.category,
      snippet: article.snippet,
      timeAgo: article.timeAgo,
      imageUrls: imageUrls,
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Public Health':
        return Colors.green.shade700;
      case 'Infrastructure':
        return Colors.deepPurple.shade700;
      case 'Jobs & Youth':
        return Colors.teal.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to News Article Detail
        final convertedArticle = _convertToNewsPageArticle(article);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(article: convertedArticle),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                 article.imageUrl[0],
                 width: 120,
                 height: 90,
                 fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.snippet,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getColorForCategory(article.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(
                            color: _getColorForCategory(article.category),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Time Ago
                      Text(
                        article.timeAgo,
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}