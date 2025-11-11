import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_detail_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/alert_page.dart' as alert_page;
import 'package:mgov_apps/features/gov_connect/pages/news_detail_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/news_page.dart' as news_page;

class SavedContentPage extends StatefulWidget {
  const SavedContentPage({super.key});

  @override
  State<SavedContentPage> createState() => _SavedContentPageState();
}

class _SavedContentPageState extends State<SavedContentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // Bookmarked titles
  List<String> _bookmarkedAlerts = [];
  List<String> _bookmarkedNews = [];
  
  // Filtered items
  List<alert_page.Alert> _savedAlerts = [];
  List<news_page.NewsArticle> _savedNews = [];
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load bookmarked titles
      final alertsJson = await getFromLocalStorage('bookmarked_alerts');
      final newsJson = await getFromLocalStorage('bookmarked_news');
      
      if (alertsJson != null) {
        _bookmarkedAlerts = List<String>.from(jsonDecode(alertsJson));
      }
      
      if (newsJson != null) {
        _bookmarkedNews = List<String>.from(jsonDecode(newsJson));
      }

      // Fetch all alerts and news
      await Future.wait([
        _fetchAndFilterAlerts(),
        _fetchAndFilterNews(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load saved content: $e';
      });
    }
  }

  Future<void> _fetchAndFilterAlerts() async {
    try {
      final response = await _apiService.getAlerts();
      
      if (response.success && response.data != null) {
        final List<dynamic> alertsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        final allAlerts = alertsData.map((json) => _parseAlert(json)).toList();
        
        // Filter to only bookmarked alerts
        setState(() {
          _savedAlerts = allAlerts.where((alert) => 
            _bookmarkedAlerts.contains(alert.title)
          ).toList();
        });
      }
    } catch (e) {
      print('Error fetching alerts: $e');
    }
  }

  Future<void> _fetchAndFilterNews() async {
    try {
      final response = await _apiService.getNews();
      
      if (response.success && response.data != null) {
        final List<dynamic> newsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        final allNews = newsData.map((json) => _parseNews(json)).toList();
        
        // Filter to only bookmarked news
        setState(() {
          _savedNews = allNews.where((news) => 
            _bookmarkedNews.contains(news.title)
          ).toList();
        });
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  alert_page.Alert _parseAlert(dynamic json) {
    return alert_page.Alert(
      title: json['title'] ?? json['message'] ?? 'No title',
      type: _getAlertType(json['type'] ?? json['alert_type'] ?? 'SERVICE'),
      date: json['date'] ?? json['created_at'] ?? '',
      location: json['location'] ?? json['address'] ?? '',
      time: json['time'],
      status: json['status'],
      details: json['description'] ?? json['details'] ?? json['message'],
      evacuationCenters: json['evacuation_centers'] != null 
          ? List<String>.from(json['evacuation_centers'])
          : null,
    );
  }

  news_page.NewsArticle _parseNews(dynamic json) {
    dynamic rawImage = json['featured_images'] ?? json['image'];
    List<String> images;

    if (rawImage == null) {
      images = ['https://picsum.photos/600/400'];
    } else if (rawImage is List) {
      images = rawImage.map((e) => e.toString()).toList();
    } else if (rawImage is String) {
      images = [rawImage];
    } else {
      images = ['https://picsum.photos/600/400'];
    }

    return news_page.NewsArticle(
      title: json['title'] ?? 'No title',
      category: json['category'] ?? 'General',
      snippet: json['description'] ?? json['snippet'] ?? json['excerpt'] ?? '',
      timeAgo: _formatTimeAgo(json['created_at'] ?? json['published_at']),
      imageUrls: images,
      date: json['date'],
      time: json['time'],
      headline: json['headline'],
      articleBody: json['body'] ?? json['content'] ?? json['article_body'],
    );
  }

  alert_page.AlertType _getAlertType(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return alert_page.AlertType.emergency;
      case 'WEATHER':
        return alert_page.AlertType.weather;
      case 'SERVICE':
      default:
        return alert_page.AlertType.service;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Saved Content', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(text: 'Alerts'),
            Tab(text: 'News'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSavedContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAlertsTab(),
                    _buildNewsTab(),
                  ],
                ),
    );
  }

  Widget _buildAlertsTab() {
    if (_savedAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved alerts',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedAlerts.length,
        itemBuilder: (context, index) {
          final alert = _savedAlerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.warning_amber_rounded,
                color: alert.type == alert_page.AlertType.emergency
                    ? Colors.red
                    : Colors.blue,
              ),
              title: Text(
                alert.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(alert.location),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlertDetailPage(alert: alert),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsTab() {
    if (_savedNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved news',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedContent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedNews.length,
        itemBuilder: (context, index) {
          final news = _savedNews[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: news.imageUrls.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        news.imageUrls.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.article),
                    ),
              title: Text(
                news.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(news.timeAgo),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(article: news),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}




