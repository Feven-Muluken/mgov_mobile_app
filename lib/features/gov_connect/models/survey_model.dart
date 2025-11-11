/// Survey Model for Gov Connect App

class Survey {
  final int id;
  final String title;
  final String description;
  final List<String> targetUserTypes;
  final List<String> targetApps;
  final List<String> targetRegions;
  final String? startDate;
  final String? endDate;
  final String status;
  final bool isAnonymous;
  final bool allowMultipleResponses;
  final bool showResultsAfterCompletion;
  final bool publishResultsPublicly;
  final SurveyAuthor author;
  final int responseCount;
  final bool isActive;
  final List<SurveyQuestion> questions;
  final String createdAt;
  final String updatedAt;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.targetUserTypes,
    required this.targetApps,
    required this.targetRegions,
    this.startDate,
    this.endDate,
    required this.status,
    required this.isAnonymous,
    required this.allowMultipleResponses,
    required this.showResultsAfterCompletion,
    required this.publishResultsPublicly,
    required this.author,
    required this.responseCount,
    required this.isActive,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      targetUserTypes: List<String>.from(json['target_user_types'] ?? []),
      targetApps: List<String>.from(json['target_apps'] ?? []),
      targetRegions: List<String>.from(json['target_regions'] ?? []),
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      isAnonymous: json['is_anonymous'] ?? false,
      allowMultipleResponses: json['allow_multiple_responses'] ?? false,
      showResultsAfterCompletion: json['show_results_after_completion'] ?? false,
      publishResultsPublicly: json['publish_results_publicly'] ?? false,
      author: SurveyAuthor.fromJson(json['author']),
      responseCount: json['response_count'] ?? 0,
      isActive: json['is_active'] ?? false,
      questions: (json['questions'] as List?)
              ?.map((q) => SurveyQuestion.fromJson(q))
              .toList() ??
          [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_user_types': targetUserTypes,
      'target_apps': targetApps,
      'target_regions': targetRegions,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'is_anonymous': isAnonymous,
      'allow_multiple_responses': allowMultipleResponses,
      'show_results_after_completion': showResultsAfterCompletion,
      'publish_results_publicly': publishResultsPublicly,
      'author': author.toJson(),
      'response_count': responseCount,
      'is_active': isActive,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SurveyAuthor {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String displayName;

  SurveyAuthor({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  factory SurveyAuthor.fromJson(Map<String, dynamic> json) {
    return SurveyAuthor(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      displayName: json['display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
    };
  }
}

class SurveyQuestion {
  final int id;
  final String questionText;
  final String questionType;
  final bool isRequired;
  final List<String> options;
  final int order;

  SurveyQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.isRequired,
    required this.options,
    required this.order,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'text',
      isRequired: json['is_required'] ?? false,
      options: List<String>.from(json['options'] ?? []),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_type': questionType,
      'is_required': isRequired,
      'options': options,
      'order': order,
    };
  }
}


