class RagRequest {
  final String query;

  RagRequest({required this.query});

  Map<String, dynamic> toJson() => {
    'query': query,
  };
}

class RagResponse {
  final String answer;
  final List<String> sources;

  RagResponse({
    required this.answer,
    required this.sources,
  });

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    return RagResponse(
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class RagCacheEntry {
  final String query;
  final String answer;
  final List<String> sources;
  final int timestamp;

  static const int cacheDurationMs = 24 * 60 * 60 * 1000; // 24 hours

  RagCacheEntry({
    required this.query,
    required this.answer,
    required this.sources,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  bool isExpired() {
    return DateTime.now().millisecondsSinceEpoch - timestamp >
        cacheDurationMs;
  }

  Map<String, dynamic> toJson() => {
    'query': query,
    'answer': answer,
    'sources': sources,
    'timestamp': timestamp,
  };

  factory RagCacheEntry.fromJson(Map<String, dynamic> json) {
    return RagCacheEntry(
      query: json['query'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}

// State management
abstract class RagState {}

class RagIdle extends RagState {}

class RagLoading extends RagState {}

class RagSuccess extends RagState {
  final String answer;
  final List<String> sources;
  final bool fromCache;

  RagSuccess({
    required this.answer,
    required this.sources,
    this.fromCache = false,
  });
}

class RagError extends RagState {
  final String message;

  RagError(this.message);
}