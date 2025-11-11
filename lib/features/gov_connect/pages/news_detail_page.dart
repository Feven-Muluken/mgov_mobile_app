import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/features/gov_connect/pages/news_page.dart';

// --- Mock Data Model ---



// --- The News Detail Page Widget ---

class NewsDetailPage extends StatefulWidget {
  final NewsArticle article;

  const NewsDetailPage({required this.article, super.key});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {

  final ApiService _apiService = ApiService();

  // State variables for news
  bool _isLoadingNews = true;
  bool _hasNewsError = false;
  String _newsErrorMessage = '';
  List<NewsArticle> _allNewsList = [];
  List<NewsArticle> _filteredNewsList = [];
  
  // Bookmark state
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _loadBookmarkState();
  }

  /// Load bookmark state from storage
  Future<void> _loadBookmarkState() async {
    try {
      final bookmarksJson = await getFromLocalStorage('bookmarked_news');
      if (bookmarksJson != null) {
        final List<dynamic> bookmarks = jsonDecode(bookmarksJson);
        setState(() {
          _isBookmarked = bookmarks.contains(widget.article.title);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle bookmark state
  Future<void> _toggleBookmark() async {
    try {
      final bookmarksJson = await getFromLocalStorage('bookmarked_news');
      List<String> bookmarks = [];
      
      if (bookmarksJson != null) {
        bookmarks = List<String>.from(jsonDecode(bookmarksJson));
      }

      setState(() {
        if (_isBookmarked) {
          // Remove bookmark
          bookmarks.remove(widget.article.title);
          _isBookmarked = false;
        } else {
          // Add bookmark
          bookmarks.add(widget.article.title);
          _isBookmarked = true;
        }
      });

      // Save updated bookmarks
      await saveToLocalStorage('bookmarked_news', jsonEncode(bookmarks));

      // Show feedback message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked 
                  ? 'News article bookmarked' 
                  : 'Bookmark removed',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: _isBookmarked ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share news article details
  Future<void> _shareNewsArticle(BuildContext context) async {
    try {
      // Format news article information for sharing
      final StringBuffer shareText = StringBuffer();
      shareText.writeln('📰 NEWS ARTICLE');
      shareText.writeln('');
      shareText.writeln(widget.article.title);
      shareText.writeln('');
      
      if (widget.article.headline != null && widget.article.headline!.isNotEmpty) {
        shareText.writeln('Headline:');
        shareText.writeln(widget.article.headline);
        shareText.writeln('');
      }
      
      if (widget.article.snippet.isNotEmpty) {
        shareText.writeln('Summary:');
        shareText.writeln(widget.article.snippet);
        shareText.writeln('');
      }
      
      if (widget.article.date != null || widget.article.time != null) {
        shareText.writeln('Published: ${widget.article.date ?? ''}${widget.article.time != null ? ', ${widget.article.time}' : ''}');
      }
      
      if (widget.article.category.isNotEmpty) {
        shareText.writeln('Category: ${widget.article.category}');
      }
      
      shareText.writeln('');
      shareText.writeln('Shared via MyGov Connect App');

      // Share the news article
      await Share.share(
        shareText.toString(),
        subject: widget.article.title,
      );
    } catch (e) {
      // Show error message if sharing fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      //_selectedFilter = filterKey;
      
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
      } else if (json['featured_image'] is String) {
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
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    print(widget.article.imageUrls);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel (Header)
            _buildImageCarousel(context),

            // Article Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      widget.article.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Article Title
                  Text(
                    widget.article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Issued Date/Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Issued',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.article.date}, ${widget.article.time}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Headline Section
                  const Text(
                    'Headline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.article.headline ?? "no headline provided",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600, // Headline is bold in appearance
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Article Body Section
                  const Text(
                    'Article',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.article.articleBody ?? "no body provided",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20,),

                  
                  const SizedBox(height: 40),
                ],
              ),
            ),

            _buildSectionHeader(
            context, 
            title: 'Similar News', 
            actionText: 'Browse More News',
            onTap: () { 
              // Navigate to the full News Feed screen

            },
          ),
          const SizedBox(height: 20,),
          NewsCarousel(allNewsList: _allNewsList,),
          const SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }

  // --- AppBar Widget ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('News', style: TextStyle(color: Colors.black)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? Colors.blue.shade700 : Colors.grey,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.grey),
          onPressed: () => _shareNewsArticle(context),
        ),
      ],
    );
  }

  // --- Image Carousel Widget ---
  Widget _buildImageCarousel(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 250, // Fixed height for the carousel
          child: PageView.builder(
            itemCount: widget.article.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.article.imageUrls[index],
                fit: BoxFit.cover,
                // Add a placeholder/error builder for real-world usage
              );
            },
          ),
        ),
        
        // Navigation Arrows (Overlay)
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Arrow
              _currentPage > 0 
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        // Logic to go to the previous page (requires PageController)
                      },
                    )
                  : const SizedBox(width: 48), // Spacer
              
              // Right Arrow
              _currentPage < widget.article.imageUrls.length - 1
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () {
                        // Logic to go to the next page (requires PageController)
                      },
                    )
                  : const SizedBox(width: 48), // Spacer
            ],
          ),
        ),

        // Dots Indicator (Overlay)
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.article.imageUrls.length,
              (index) => Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
                // color: Theme.of(context).primaryColor,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class NewsCarousel extends StatelessWidget {
 final List<NewsArticle> allNewsList;
  const NewsCarousel({super.key, required this.allNewsList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Height for the horizontal scroll view
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allNewsList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == allNewsList.length - 1 ? 16.0 : 8.0,
            ),
            child: NewsCard(news: allNewsList[index]),
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle news;
  
  const NewsCard({required this.news, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(article: news)));
      },
      
     child:Container(
      //margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: 250,
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(
            width: double.infinity,    
            child:ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                news.imageUrls.first,
                 //width: 400,
                 height: 90,
                fit: BoxFit.cover,
              ),
            ),
            ),
            //const SizedBox(width: 10),
          
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
            maxLines: 2,
            overflow: TextOverflow.clip,
          ),
          const SizedBox(height: 10,),
          Text(
            news.snippet,
            style: const TextStyle(
              //fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.clip,
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
              
              //const SizedBox(width: 4),
              Text(news.category, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    )
  );
  }
}

