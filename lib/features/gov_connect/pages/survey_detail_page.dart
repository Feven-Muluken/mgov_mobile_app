import 'package:flutter/material.dart';
import 'package:mgov_apps/features/gov_connect/pages/surveys_polls_page.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';

// --- The Survey Detail Page Widget ---

class SurveyDetailPage extends StatefulWidget {
  final SurveyOrPoll survey;

  const SurveyDetailPage({required this.survey, super.key});

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  // Map to store selected answers for radio questions: {questionIndex: selectedOption}
  final Map<int, String> _selectedAnswers = {};
  // Map to store text answers: {questionIndex: textController}
  final Map<int, TextEditingController> _textControllers = {};
  
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers for text questions
    for (int i = 0; i < widget.survey.questions!.length; i++) {
      if (widget.survey.questions![i].questionType == 'text') {
        _textControllers[i] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _textControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Helper to determine the color scheme based on the survey type (e.g., green for surveys)
  Color get _surveyColor {
    return widget.survey.type == SurveyType.survey
        ? Colors.lightGreen.shade700
        : Colors.purple.shade700;
  }

  Color get _surveyBackgroundColor {
    return widget.survey.type == SurveyType.survey
        ? Colors.lightGreen.shade50
        : Colors.purple.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90), // Make space for the fixed bottom button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Survey Header Section
                _buildHeaderSection(context),

                // Confidentiality Alert
                _buildConfidentialityAlert(),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.survey.description!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Questions Section
                      const Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Build each question dynamically
                      ..._buildQuestionWidgets(),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Extra space at bottom
              ],
            ),
          ),
          // Fixed Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSubmitButton(),
          ),
        ],
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
      title: const Text('Survey', style: TextStyle(color: Colors.black)),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.grey),
          onPressed: () {
            // Handle bookmark action
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.grey),
          onPressed: () {
            // Handle share action
          },
        ),
      ],
    );
  }

  // --- Header Section (Title, Dates, Participants, Status) ---
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      color: _surveyBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Survey Tag
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: _surveyColor, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.survey.type.name.capitalize(),
                style: TextStyle(
                  color: _surveyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            widget.survey.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 15),
          // Details Row: Days Remaining & Participants
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.survey.daysRemaining,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.survey.participantsOrVotes,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade600, // Always green for 'Active'
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.survey.status!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Confidentiality Alert Widget ---
  Widget _buildConfidentialityAlert() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your responses are confidential and anonymous.',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Question Widgets Builder ---
  List<Widget> _buildQuestionWidgets() {
    List<Widget> questionWidgets = [];
    for (int i = 0; i < widget.survey.questions!.length; i++) {
      final question = widget.survey.questions![i];
      questionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1} - ${question.questionText}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Render different input types based on questionType
              if (question.questionType == 'radio' || question.questionType == 'radio_scale')
                _buildRadioOptions(i, question),
              if (question.questionType == 'text')
                _buildTextInput(i),
            ],
          ),
        ),
      );
    }
    return questionWidgets;
  }

  // --- Radio Options Builder ---
  Widget _buildRadioOptions(int questionIndex, SurveyQuestion question) {
    return Column(
      children: question.options.map((option) {
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _selectedAnswers[questionIndex],
          onChanged: (String? value) {
            setState(() {
              _selectedAnswers[questionIndex] = value!;
            });
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  // --- Text Input Builder ---
  Widget _buildTextInput(int questionIndex) {
    return TextField(
      controller: _textControllers[questionIndex],
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        fillColor: Colors.grey.shade100,
        filled: true,
      ),
    );
  }

  // --- Submit Survey or Poll ---
  Future<void> _handleSubmission() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get token from storage
      final token = await getFromLocalStorage('access_token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to continue')),
          );
        }
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      ApiResponse response;

      if (widget.survey.type == SurveyType.poll) {
        // Submit Poll Vote
        response = await _submitPollVote(token);
      } else {
        // Submit Survey Response
        response = await _submitSurveyResponse(token);
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back after success
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true); // Pass true to indicate refresh needed
        } else {
          // Handle specific errors
          String errorMessage = response.message;
          
          // Debug logging for errors
          print('=== API ERROR DEBUG ===');
          print('Status Code: ${response.statusCode}');
          print('Message: ${response.message}');
          print('Data: ${response.data}');
          print('=======================');
          
          // Special handling for poll voting with 500 status code
          if (widget.survey.type == SurveyType.poll && response.statusCode == 500) {
            errorMessage = 'Voting already submitted';
          } else {
            if (response.data != null && response.data['errors'] != null) {
              final errors = response.data['errors'];
              if (errors is Map) {
                errorMessage = errors.values.first is List
                    ? errors.values.first[0]
                    : errors.values.first.toString();
              }
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ApiResponse> _submitPollVote(String token) async {
    // Get selected option index
    final selectedAnswer = _selectedAnswers[0]; // Polls have only one question
    if (selectedAnswer == null) {
      throw Exception('Please select an option');
    }

    // Find the index of the selected option
    final optionIndex = widget.survey.questions![0].options.indexOf(selectedAnswer);
    
    // Debug logging
    print('=== POLL VOTE DEBUG ===');
    print('Poll ID: ${widget.survey.id}');
    print('Selected Answer: $selectedAnswer');
    print('Option Index: $optionIndex');
    print('Available Options: ${widget.survey.questions![0].options}');
    print('Token: ${token.substring(0, 20)}...');
    print('=======================');
    
    if (optionIndex == -1) {
      throw Exception('Invalid option selected');
    }
    
    return await _apiService.votePoll(
      pollId: widget.survey.id!,
      selectedOption: optionIndex,
      appName: 'my_gov_connect',
      token: token,
    );
  }

  Future<ApiResponse> _submitSurveyResponse(String token) async {
    // Build responses map with question IDs
    Map<String, String> responses = {};

    for (int i = 0; i < widget.survey.questions!.length; i++) {
      final question = widget.survey.questions![i];
      String answer;

      if (question.questionType == 'radio' || question.questionType == 'radio_scale') {
        answer = _selectedAnswers[i] ?? '';
      } else if (question.questionType == 'text') {
        answer = _textControllers[i]?.text.trim() ?? '';
      } else {
        answer = '';
      }

      // Use index + 1 as question ID (or use actual question ID if available)
      responses['${i + 1}'] = answer;
    }

    // Debug logging
    print('=== SURVEY SUBMIT DEBUG ===');
    print('Survey ID: ${widget.survey.id}');
    print('Responses: $responses');
    print('Token: ${token.substring(0, 20)}...');
    print('===========================');

    return await _apiService.submitSurveyResponse(
      surveyId: widget.survey.id!,
      responses: responses,
      appName: 'my_gov_connect',
      isComplete: true,
      token: token,
    );
  }

  // --- Submit Button ---
  Widget _buildSubmitButton() {
    // Determine if all questions are answered
    bool allAnswered = true;
    for (int i = 0; i < widget.survey.questions!.length; i++) {
      final question = widget.survey.questions![i];
      if (question.questionType == 'radio' || question.questionType == 'radio_scale') {
        if (!_selectedAnswers.containsKey(i)) {
          allAnswered = false;
          break;
        }
      } else if (question.questionType == 'text') {
        if (_textControllers[i] == null || _textControllers[i]!.text.trim().isEmpty) {
          allAnswered = false;
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ElevatedButton(
        onPressed: (allAnswered && !_isSubmitting) ? _handleSubmission : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003399),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }
}
