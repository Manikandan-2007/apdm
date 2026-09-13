import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum MemoryCategory {
  personal('Personal', Icons.person_outline, AppColors.categoryPersonal),
  family('Family', Icons.people_outline, AppColors.categoryFamily),
  stories('Stories', Icons.auto_stories_outlined, AppColors.categoryStories),
  events('Important Events', Icons.event_note_outlined, AppColors.categoryEvents),
  favorites('Favourite Things', Icons.favorite_border, AppColors.categoryFavorites),
  messages('Messages', Icons.mail_outline, AppColors.categoryMessages);

  final String label;
  final IconData icon;
  final Color accentColor;

  const MemoryCategory(this.label, this.icon, this.accentColor);

  static MemoryCategory fromString(String val) {
    return MemoryCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => MemoryCategory.personal,
    );
  }
}

/// Represents a preserved memory or story regarding the loved one.
class Memory {
  final String id;
  final String title;
  final String content;
  final MemoryCategory category;
  final DateTime? memoryDate;
  final DateTime createdAt;
  final List<String> tags;
  final String? emotionTag;

  const Memory({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.memoryDate,
    required this.createdAt,
    this.tags = const [],
    this.emotionTag,
  });

  Memory copyWith({
    String? id,
    String? title,
    String? content,
    MemoryCategory? category,
    DateTime? memoryDate,
    DateTime? createdAt,
    List<String>? tags,
    String? emotionTag,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      memoryDate: memoryDate ?? this.memoryDate,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      emotionTag: emotionTag ?? this.emotionTag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'memoryDate': memoryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'emotionTag': emotionTag,
    };
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: MemoryCategory.fromString(json['category'] as String),
      memoryDate: json['memoryDate'] != null ? DateTime.parse(json['memoryDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      emotionTag: json['emotionTag'] as String?,
    );
  }
}
