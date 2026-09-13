import 'chat_message.dart';

/// Represents a past or active dialogue session with the memorial companion.
class ConversationSession {
  final String id;
  final String title;
  final DateTime startedAt;
  final int durationSeconds;
  final List<ChatMessage> messages;
  final String summaryPreview;
  final List<String> topics;

  const ConversationSession({
    required this.id,
    required this.title,
    required this.startedAt,
    this.durationSeconds = 0,
    this.messages = const [],
    required this.summaryPreview,
    this.topics = const [],
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  ConversationSession copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    int? durationSeconds,
    List<ChatMessage>? messages,
    String? summaryPreview,
    List<String>? topics,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      messages: messages ?? this.messages,
      summaryPreview: summaryPreview ?? this.summaryPreview,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'messages': messages.map((m) => m.toJson()).toList(),
      'summaryPreview': summaryPreview,
      'topics': topics,
    };
  }

  factory ConversationSession.fromJson(Map<String, dynamic> json) {
    return ConversationSession(
      id: json['id'] as String,
      title: json['title'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      summaryPreview: json['summaryPreview'] as String? ?? '',
      topics: (json['topics'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}
