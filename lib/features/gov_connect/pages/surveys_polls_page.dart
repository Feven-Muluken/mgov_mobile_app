import 'package:flutter/material.dart';
import 'package:mgov_apps/features/gov_connect/pages/submit_feedback_page.dart';
import 'package:mgov_apps/features/gov_connect/pages/survey_detail_page.dart';
import 'package:mgov_apps/core/localization/language_provider.dart';
import 'package:mgov_apps/features/gov_connect/models/poll_model.dart';
import 'package:mgov_apps/features/gov_connect/models/survey_model.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';

// --- Data Model and Enum ---

enum SurveyType { survey, poll }

class SurveyQuestion {
  final String questionText;
  final List<String> options;
  final String questionType; // e.g., 'radio', 'text', 'rating'

  SurveyQuestion({
    required this.questionText,
    required this.options,
    required this.questionType,
  });
}

class SurveyOrPoll {
  final SurveyType type;
  final String title;
  final String participantsOrVotes;
  final String daysRemaining;
  final String? category;
  final String? status;
  final String? description;
  final List<SurveyQuestion>? questions;
  final int? id;
  final bool? userHasVoted;

  SurveyOrPoll({
    required this.type,
    required this.title,
    required this.participantsOrVotes,
    required this.daysRemaining,
    this.category,
    this.status,
    this.description,
    this.questions,
    this.id,
    this.userHasVoted,
  });

  // Factory to create from Poll model
  factory SurveyOrPoll.fromPoll(Poll poll) {
    final daysRemaining = _calculateDaysRemaining(poll.endDate);
    return SurveyOrPoll(
      type: SurveyType.poll,
      title: poll.question,
      participantsOrVotes: '${poll.voteCount} votes',
      daysRemaining: daysRemaining,
      status: poll.status,
      description: poll.description,
      id: poll.id,
      userHasVoted: poll.userHasVoted,
      questions: [
        SurveyQuestion(
          questionText: poll.question,
          options: poll.options,
          questionType: 'radio',
        ),
      ],
    );
  }

  // Factory to create from Survey model
  factory SurveyOrPoll.fromSurvey(Survey survey) {
    final daysRemaining = _calculateDaysRemaining(survey.endDate);
    return SurveyOrPoll(
      type: SurveyType.survey,
      title: survey.title,
      participantsOrVotes: '${survey.responseCount} participants',
      daysRemaining: daysRemaining,
      status: survey.status,
      description: survey.description,
      id: survey.id,
      questions: survey.questions
          .map((q) => SurveyQuestion(
                questionText: q.questionText,
                options: q.options,
                questionType: q.questionType,
              ))
          .toList(),
    );
  }

  static String _calculateDaysRemaining(String? endDate) {
    if (endDate == null) return 'No deadline';
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      if (difference < 0) return 'Expired';
      if (difference == 0) return 'Ends today';
      return '$difference days remaining';
    } catch (e) {
      return 'No deadline';
    }
  }
}

// --- The Main Page Widget ---

class SurveysPollsPage extends StatefulWidget {
  const SurveysPollsPage({super.key});

  @override
  State<SurveysPollsPage> createState() => _SurveysPollsPageState();
}

class _SurveysPollsPageState extends State<SurveysPollsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  
  final ApiService _apiService = ApiService();
  List<SurveyOrPoll> _allSurveysPolls = [];
  List<SurveyOrPoll> _filteredSurveysPolls = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize TabController for "All" and "My participations"
    _tabController = TabController(length: 2, vsync: this);
    _fetchSurveysAndPolls();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchSurveysAndPolls() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from storage
      final token = await getFromLocalStorage('access_token');

      // Fetch both surveys and polls in parallel
      final results = await Future.wait([
        _apiService.getSurveys(token: token),
        _apiService.getPolls(token: token),
      ]);

      final surveysResponse = results[0];
      final pollsResponse = results[1];

      List<SurveyOrPoll> combinedList = [];

      // Process surveys
      if (surveysResponse.success && surveysResponse.data != null) {
        final surveysData = surveysResponse.data['results'] as List?;
        if (surveysData != null) {
          for (var surveyJson in surveysData) {
            try {
              final survey = Survey.fromJson(surveyJson);
              combinedList.add(SurveyOrPoll.fromSurvey(survey));
            } catch (e) {
              print('Error parsing survey: $e');
            }
          }
        }
      }

      // Process polls
      if (pollsResponse.success && pollsResponse.data != null) {
        final pollsData = pollsResponse.data['results'] as List?;
        if (pollsData != null) {
          for (var pollJson in pollsData) {
            try {
              final poll = Poll.fromJson(pollJson);
              combinedList.add(SurveyOrPoll.fromPoll(poll));
            } catch (e) {
              print('Error parsing poll: $e');
            }
          }
        }
      }

      setState(() {
        _allSurveysPolls = combinedList;
        _filteredSurveysPolls = combinedList;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load surveys and polls: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredSurveysPolls = _allSurveysPolls;
      } else if (_selectedCategory == 'Surveys') {
        _filteredSurveysPolls = _allSurveysPolls
            .where((item) => item.type == SurveyType.survey)
            .toList();
      } else if (_selectedCategory == 'Polls') {
        _filteredSurveysPolls = _allSurveysPolls
            .where((item) => item.type == SurveyType.poll)
            .toList();
      } else {
        // Filter by category (Transport, Health, etc.)
        _filteredSurveysPolls = _allSurveysPolls
            .where((item) => item.category == _selectedCategory)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Chips Row
          _buildCategoryChips(),
          
          // TabBar (All | My participations)
          _buildTabBar(),
          
          // Alerts Title and Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.strings.surveysPolls,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredSurveysPolls.length} ${context.strings.results}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Surveys/Polls List View (Tab Content)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchSurveysAndPolls,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: All Surveys & Polls
                          _buildSurveyListView(_filteredSurveysPolls),
                          
                          // Tab 2: My Participations
                          _buildMyParticipations(),
                        ],
                      ),
          ),
        ],
      ),
      
    );
  }

  // --- AppBar Widget ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {},
          // ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              // child: TextField(
              //   decoration: InputDecoration(
              //     hintText: context.strings.searchForSurveyPoll,
              //     border: InputBorder.none,
              //     prefixIcon: const Icon(Icons.search, color: Colors.grey),
              //     contentPadding: const EdgeInsets.symmetric(vertical: 8),
              //   ),
              // ),
              child: Text(
                "Survey and Poll Submission"
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.filter_list_rounded),
          //   onPressed: () {},
          // ),
        ],
      ),
      toolbarHeight: 60,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  // --- Category Chips Widget ---
  Widget _buildCategoryChips() {
    final strings = context.strings;
    final categoryData = [
      {'key': 'Surveys', 'label': strings.surveys},
      {'key': 'Polls', 'label': strings.polls},
      {'key': 'All', 'label': strings.all},
      {'key': 'Transport', 'label': strings.transport},
      {'key': 'Health', 'label': strings.health},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: categoryData.map((categoryItem) {
          final categoryKey = categoryItem['key'] as String;
          final categoryLabel = categoryItem['label'] as String;
          final isSelected = _selectedCategory == categoryKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                categoryLabel,
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
                setState(() {
                  _selectedCategory = categoryKey;
                });
                _applyFilters();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- TabBar Widget ---
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Expanded( 
        child:TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue.shade700,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          tabs: [
            Tab(text: context.strings.all),
            Tab(text: context.strings.myParticipations),
          ],
        ),
        ),

        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {
            // TODO: handle feedback action here
            Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitFeedbackPage()));
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Feedback', style: TextStyle(color: Colors.blue),),
        ),
        ]
        ),
      ),
    );
  }
  
  // --- ListView Builder ---
  Widget _buildSurveyListView(List<SurveyOrPoll> data) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No surveys or polls available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchSurveysAndPolls,
      child: ListView.builder(
        itemCount: data.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return SurveyPollCard(
            item: data[index],
            onRefresh: _fetchSurveysAndPolls,
          );
        },
      ),
    );
  }

  Widget _buildMyParticipations() {
    final myParticipations = _filteredSurveysPolls
        .where((item) => item.userHasVoted == true)
        .toList();

    if (myParticipations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              context.strings.noActiveParticipations,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSurveysAndPolls,
      child: ListView.builder(
        itemCount: myParticipations.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return SurveyPollCard(
            item: myParticipations[index],
            onRefresh: _fetchSurveysAndPolls,
          );
        },
      ),
    );
  }
}

// --- Survey/Poll Card Widget (Reusable Component) ---

class SurveyPollCard extends StatefulWidget {
  final SurveyOrPoll item;
  final VoidCallback? onRefresh;
  
  const SurveyPollCard({required this.item, this.onRefresh, super.key});

  @override
  State<SurveyPollCard> createState() => _SurveyPollCardState();
}

class _SurveyPollCardState extends State<SurveyPollCard> {
  Color get _cardColor {
    return widget.item.type == SurveyType.survey
        ? Colors.lightGreen.shade50
        : Colors.purple.shade50;
  }

  Color get _iconColor {
    return widget.item.type == SurveyType.survey
        ? Colors.lightGreen.shade700
        : Colors.purple.shade700;
  }

  IconData get _iconData {
    return widget.item.type == SurveyType.survey
        ? Icons.assignment_outlined
        : Icons.bar_chart_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
    onTap: () async {
      final result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => SurveyDetailPage(survey: widget.item))
      );
      // Refresh if submission was successful
      if (result == true && widget.onRefresh != null) {
        widget.onRefresh!();
      }
    },  
    child:Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        //color: Colors.white,
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)
          ),  
          
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconData, size: 16, color: _iconColor),
                const SizedBox(width: 4),
                Text(
                  widget.item.type.name.capitalize(),
                  style: TextStyle(
                    color: _iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // Title
          Text(
            widget.item.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
              // Participants/Votes
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(widget.item.participantsOrVotes, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 10),

            ]
           )  
          ),  
           
          const SizedBox(height: 5),

          // Remaining Days Row
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(widget.item.daysRemaining, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),

          // Category Tag (Right side)
              if (widget.item.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.item.category!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          ],
          ),
        ],
      ),
    ),
    );
  }
}

// Extension to capitalize the first letter of the enum name
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}