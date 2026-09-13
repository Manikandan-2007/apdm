import 'language.dart';

enum MessageSender { user, ai }

enum AudioPlaybackState { none, playing, paused, completed }

/// Represents an individual voice or text exchange within a conversation session.
/// Enriched to support multilingual detection, audio references, and memory contexts.
class ChatMessage {
  final String id;
  final String? conversationId;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isPartial;
  final AppLanguage detectedLanguage;
  final AudioPlaybackState audioState;
  final String? audioUrl;
  final String? memoryContextRef;

  const ChatMessage({
    required this.id,
    this.conversationId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isPartial = false,
    this.detectedLanguage = AppLanguage.english,
    this.audioState = AudioPlaybackState.none,
    this.audioUrl,
    this.memoryContextRef,
  });

  bool get isFromUser => sender == MessageSender.user;
  bool get isFromAi => sender == MessageSender.ai;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isPartial,
    AppLanguage? detectedLanguage,
    AudioPlaybackState? audioState,
    String? audioUrl,
    String? memoryContextRef,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isPartial: isPartial ?? this.isPartial,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      audioState: audioState ?? this.audioState,
      audioUrl: audioUrl ?? this.audioUrl,
      memoryContextRef: memoryContextRef ?? this.memoryContextRef,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'isPartial': isPartial,
      'detectedLanguage': detectedLanguage.name,
      'audioState': audioState.name,
      'audioUrl': audioUrl,
      'memoryContextRef': memoryContextRef,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String?,
      text: json['text'] as String,
      sender: json['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPartial: json['isPartial'] as bool? ?? false,
      detectedLanguage: json['detectedLanguage'] != null
          ? AppLanguage.values.firstWhere(
              (l) => l.name == json['detectedLanguage'],
              orElse: () => AppLanguage.english,
            )
          : AppLanguage.english,
      audioState: json['audioState'] != null
          ? AudioPlaybackState.values.firstWhere(
              (a) => a.name == json['audioState'],
              orElse: () => AudioPlaybackState.none,
            )
          : AudioPlaybackState.none,
      audioUrl: json['audioUrl'] as String?,
      memoryContextRef: json['memoryContextRef'] as String?,
    );
  }
}
