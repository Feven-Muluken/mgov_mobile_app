import 'package:flutter/material.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/pages/filter_search_modal.dart';
import 'package:mgov_apps/features/gov_connect/pages/news_detail_page.dart';

// --- Data Model and Enum for Alerts ---

enum NewsCategory { health, community, technology, governance, infrastructure, jobs, publicHealth }


class NewsArticle {
  final String title;
  final String category;
  final String snippet;
  final String timeAgo;
  final List<String> imageUrls;
  final String? date;
  final String? time;
  final String? headline;
  final String? articleBody;

  NewsArticle({
    required this.title,
    required this.category,
    required this.snippet,
    required this.timeAgo,
    required this.imageUrls,
    this.date,
    this.time,
    this.headline,
    this.articleBody
  });
}



// final List<NewsArticle> mockNews = [
//   NewsArticle(
//     title: 'Government Launches Youth Skill Development Program',
//     category: 'Jobs & Youth',
//     snippet: 'New initiative aims to train over 10,000 young individuals in IT and trades.',
//     timeAgo: '2 hours ago',
//     imageUrls: ['https://picsum.photos/id/1015/600/400',
//     'https://picsum.photos/800/600?random=1', 
//     'https://picsum.photos/800/600?random=2',
//     'https://picsum.photos/800/600?random=3',
//     'https://picsum.photos/800/600?random=4',
    
//     ],

//     date: 'Jan 21, 2025',
//     time: '6:30 AM',
//     headline: 'The Ministry of Innovation and Technology has announced a major nationwide rollout of the new digital ID system starting this August, aimed at improving access to government services and strengthening digital security.',
        
//     articleBody: 'The Ministry of Innovation and Technology (MinT) revealed plans to officially launch the national digital ID system. The rollout will begin in major cities and gradually expand across all regions. The ID, known as "Fayda" (or similar), is intended to consolidate multiple government identification systems into a single, secure digital identity.\n\n'
//         'Key features of the new system include biometric verification and decentralized data storage to enhance privacy and prevent fraud. Officials stated that this initiative is a crucial step toward realizing a fully digitized public service sector, enabling citizens to access healthcare, banking, and government aid more efficiently.',
        

//   ),
//   NewsArticle(
//     title: 'New Public Health Clinic Opens in Oromia Region',
//     category: 'Public Health',
//     snippet: 'The facility will provide essential services and vaccinations to rural communities.',
//     timeAgo: '1 day ago',
//     imageUrls: ['https://picsum.photos/id/350/600/400',] // Mock image
//   ),
//   NewsArticle(
//     title: 'Progress on New Rail Line Infrastructure',
//     category: 'Infrastructure',
//     snippet: 'The project is 60% complete and on track for an early 2026 launch.',
//     timeAgo: '3 days ago',
//     imageUrls: ['https://picsum.photos/id/1025/600/400',] // Mock image
//   ),
// ];

// --- The Main Page Widget ---

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String _selectedFilter = 'All';

  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  // State variables for news
  bool _isLoadingNews = true;
  bool _hasNewsError = false;
  String _newsErrorMessage = '';
  List<NewsArticle> _allNewsList = [];
  List<NewsArticle> _filteredNewsList = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
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

  Future<void> _fetchNews({String? category}) async {
    setState(() {
      _isLoadingNews = true;
      _hasNewsError = false;
    });

    try {
      final response = await _apiService.getNews(category: category);
      
      if (response.success && response.data != null) {
        // Parse the news from API response
        final List<dynamic> newsData = response.data is List 
            ? response.data 
            : (response.data['results'] ?? response.data['data'] ?? []);
        
        setState(() {
          _allNewsList = newsData.map((json) => _parseNews(json)).toList();
          _filteredNewsList = _allNewsList;
          _isLoadingNews = false;
        });
      } else {
        setState(() {
          _hasNewsError = true;
          _newsErrorMessage = response.message;
          _isLoadingNews = false;
          _allNewsList = [];
          _filteredNewsList = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasNewsError = true;
        _newsErrorMessage = 'Failed to load news: $e';
        _isLoadingNews = false;
        _allNewsList = [];
        _filteredNewsList = [];
      });
    }
  }

  void _filterNews(String filterKey) {
    setState(() {
      _selectedFilter = filterKey;
      
      if (filterKey == 'All') {
        _filteredNewsList = _allNewsList;
      } else {
        _filteredNewsList = _allNewsList.where((news) {
          return news.category.toLowerCase() == filterKey.toLowerCase() ||
                 news.category.toLowerCase().contains(filterKey.toLowerCase());
        }).toList();
      }
    });
  }

  NewsArticle _parseNews(dynamic json) {
    // Parse image URLs
    List<String> imageUrls = [];
    if (json['image'] != null) {
      if (json['image'] is List) {
        imageUrls = List<String>.from(json['image']);
      } else if (json['image'] is String) {
        imageUrls = [json['image']];
      }
    } else if (json['featured_images'] != null) {
      if (json['featured_images'] is List) {
        imageUrls = List<String>.from(json['featured_images']);
      } else if (json['featured_images'] is String) {
        imageUrls = [json['featured_images']];
      }
    } else if (json['images'] != null && json['images'] is List) {
      imageUrls = List<String>.from(json['images']);
    }
    
    // Default image if none provided
    if (imageUrls.isEmpty) {
      imageUrls = ['https://picsum.photos/600/400'];
    }

    return NewsArticle(
      title: json['title'] ?? 'No title',
      category: json['category'] ?? 'General',
      snippet: json['description'] ?? json['snippet'] ?? json['excerpt'] ?? '',
      timeAgo: _formatTimeAgo(json['created_at'] ?? json['published_at']),
      imageUrls: imageUrls,
      date: json['date'],
      time: json['time'],
      headline: json['headline'],
      articleBody: json['body'] ?? json['content'] ?? json['article_body'],
    );
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
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          _buildFilterChips(),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          
          // Error Banner
          if (_hasNewsError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _newsErrorMessage,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red.shade700, size: 20),
                    onPressed: () => _fetchNews(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          
          // News Title and Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.strings.news,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredNewsList.length} ${context.strings.results}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // News List View
          Expanded(
            child: _buildNewsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsContent() {
    if (_isLoadingNews) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredNewsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasNewsError 
                  ? 'Failed to load news. Pull down to retry.'
                  : 'Check back later for updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_hasNewsError)
              ElevatedButton.icon(
                onPressed: () => _fetchNews(),
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
      onRefresh: _fetchNews,
      child: ListView.builder(
        itemCount: _filteredNewsList.length,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return NewsCard(news: _filteredNewsList[index]);
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
                  hintText: context.strings.searchForNews,
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
      // Reset to show all news
      _fetchNews();
    } else {
      // Search news by title
      _searchNews(searchQuery);
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
          _allNewsList = newsData.map((json) => _parseNews(json)).toList();
          _filteredNewsList = _allNewsList;
          _isLoadingNews = false;
        });
      } else {
        setState(() {
          _hasNewsError = true;
          _newsErrorMessage = response.message ?? 'No news found';
          _isLoadingNews = false;
          _allNewsList = [];
          _filteredNewsList = [];
        });
      }
    } catch (e) {
      setState(() {
        _hasNewsError = true;
        _newsErrorMessage = 'Failed to search news: $e';
        _isLoadingNews = false;
        _allNewsList = [];
        _filteredNewsList = [];
      });
    }
  }

  // --- Filter Chips Widget ---
  Widget _buildFilterChips() {
    final strings = context.strings;
    final filterData = [
      {'key': 'All', 'label': strings.all},
      {'key': 'Health', 'label': strings.health},
      {'key': 'Community', 'label': strings.community},
      {'key': 'Technology', 'label': strings.technology},
      {'key': 'Governance', 'label': strings.governance},
      {'key': 'Jobs', 'label': strings.jobs},
      {'key': 'Public Health', 'label': strings.publicHealth},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: filterData.map((filterItem) {
          final filterKey = filterItem['key'] as String;
          final filterLabel = filterItem['label'] as String;
          final isSelected = _selectedFilter == filterKey;

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
                _filterNews(filterKey);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

 
}

// --- Alert Card Widget (Reusable Component) ---

class NewsCard extends StatelessWidget {
  final NewsArticle news;
  
  const NewsCard({required this.news, super.key});

  // Color get _borderColor {
  //   switch (news.category) {
  //     case NewsCategory.health:
  //       return Colors.red.shade400; 
  //     case NewsCategory.community:
  //       return Colors.blue.shade400; 
  //     case NewsCategory.technology:
  //       return Colors.green.shade400; 
  //   }
  // }

  // Color get _tagColor {
  //   switch (news.category) {
  //     case NewsCategory.health:
  //       return Colors.red.shade50; // Very light red/pink background
  //     case NewsCategory.community:
  //       return Colors.blue.shade50;  // Very light blue background
  //     case NewsCategory.technology:
  //       return Colors.green.shade50; // Example
  //   }
  // }

  // IconData get _tagIcon {
  //   switch (news.category) {
  //     case NewsCategory.health:
  //       return Icons.local_fire_department_outlined; 
  //     case NewsCategory.community:
  //       return Icons.cloud_outlined;
  //     case NewsCategory.technology:
  //       return Icons.settings_outlined;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation to NewsDetailPage when it's ready
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(article: news)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${news.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
     child:Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
        //border: Border.all(color: Colors.blue, width: 1.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade200,
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),  
          child: Column(
            children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                 news.imageUrls.first,
                //  width: 120,
                //  height: 90,
                 fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
          
          const SizedBox(height: 10),
          Padding(
          padding: EdgeInsets.all(10),  
          child: Column(
          children: [  
          Text(
            news.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            news.snippet,
            style: const TextStyle(
              //fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          ]
          )
          ),
          const SizedBox(height: 10),
           ]
          )
          ),

          SizedBox(height: 10),
          
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(news.timeAgo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const Spacer(),
              
              const SizedBox(width: 4),
              Text(news.category, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
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
