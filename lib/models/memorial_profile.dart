/// Represents profile details regarding the person whose memories are preserved.
/// Editable mock data supporting any family member (e.g. Father/Appa, Mother/Amma, Grandparent).
class MemorialProfile {
  final String id;
  final String lovedOneName;
  final String relationship; // e.g. "Father", "Mother", "Grandmother", "Spouse"
  final String lifespan; // e.g. "1954 – 2022"
  final String biography;
  final String favoritePhrase;
  final String avatarInitials;

  const MemorialProfile({
    required this.id,
    required this.lovedOneName,
    required this.relationship,
    required this.lifespan,
    required this.biography,
    required this.favoritePhrase,
    required this.avatarInitials,
  });

  MemorialProfile copyWith({
    String? id,
    String? lovedOneName,
    String? relationship,
    String? lifespan,
    String? biography,
    String? favoritePhrase,
    String? avatarInitials,
  }) {
    return MemorialProfile(
      id: id ?? this.id,
      lovedOneName: lovedOneName ?? this.lovedOneName,
      relationship: relationship ?? this.relationship,
      lifespan: lifespan ?? this.lifespan,
      biography: biography ?? this.biography,
      favoritePhrase: favoritePhrase ?? this.favoritePhrase,
      avatarInitials: avatarInitials ?? this.avatarInitials,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lovedOneName': lovedOneName,
      'relationship': relationship,
      'lifespan': lifespan,
      'biography': biography,
      'favoritePhrase': favoritePhrase,
      'avatarInitials': avatarInitials,
    };
  }

  factory MemorialProfile.fromJson(Map<String, dynamic> json) {
    return MemorialProfile(
      id: json['id'] as String,
      lovedOneName: json['lovedOneName'] as String,
      relationship: json['relationship'] as String,
      lifespan: json['lifespan'] as String,
      biography: json['biography'] as String,
      favoritePhrase: json['favoritePhrase'] as String,
      avatarInitials: json['avatarInitials'] as String,
    );
  }

  /// Default sample profile (Appa - Sundaram), fully editable in Settings/Profile.
  static MemorialProfile defaultProfile() {
    return const MemorialProfile(
      id: 'profile_default',
      lovedOneName: 'Appa (Sundaram)',
      relationship: 'Father',
      lifespan: '1954 – 2022',
      biography:
          'A quiet, loving father and civil engineer who loved traditional Carnatic music, filter coffee in the morning, evening walks, and helping anyone in need.',
      favoritePhrase: '"Porumaiyum uzhaippum endrume veen pogadhu." (Patience and hard work never fail.)',
      avatarInitials: 'SU',
    );
  }
}
