/// Poll Model for Gov Connect App

class Poll {
  final int id;
  final String question;
  final String description;
  final List<String> options;
  final List<String> targetUserTypes;
  final List<String> targetApps;
  final List<String> targetRegions;
  final String status;
  final String? startDate;
  final String? endDate;
  final bool showResultsAfterVote;
  final bool showResultsBeforeVote;
  final Author author;
  final int voteCount;
  final bool isActive;
  final bool userHasVoted;
  final String createdAt;
  final String updatedAt;

  Poll({
    required this.id,
    required this.question,
    required this.description,
    required this.options,
    required this.targetUserTypes,
    required this.targetApps,
    required this.targetRegions,
    required this.status,
    this.startDate,
    this.endDate,
    required this.showResultsAfterVote,
    required this.showResultsBeforeVote,
    required this.author,
    required this.voteCount,
    required this.isActive,
    required this.userHasVoted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      question: json['question'],
      description: json['description'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      targetUserTypes: List<String>.from(json['target_user_types'] ?? []),
      targetApps: List<String>.from(json['target_apps'] ?? []),
      targetRegions: List<String>.from(json['target_regions'] ?? []),
      status: json['status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      showResultsAfterVote: json['show_results_after_vote'] ?? false,
      showResultsBeforeVote: json['show_results_before_vote'] ?? false,
      author: Author.fromJson(json['author']),
      voteCount: json['vote_count'] ?? 0,
      isActive: json['is_active'] ?? false,
      userHasVoted: json['user_has_voted'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'description': description,
      'options': options,
      'target_user_types': targetUserTypes,
      'target_apps': targetApps,
      'target_regions': targetRegions,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'show_results_after_vote': showResultsAfterVote,
      'show_results_before_vote': showResultsBeforeVote,
      'author': author.toJson(),
      'vote_count': voteCount,
      'is_active': isActive,
      'user_has_voted': userHasVoted,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Author {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String displayName;

  Author({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
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


