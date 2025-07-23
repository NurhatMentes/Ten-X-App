import 'package:equatable/equatable.dart';

/// Ruh hali girişi entity sınıfı
class MoodEntry extends Equatable {
  /// Benzersiz kimlik
  final String id;
  
  /// Kullanıcı kimliği
  final String userId;
  
  /// Ruh hali emoji
  final String moodEmoji;
  
  /// Ruh hali açıklaması (opsiyonel)
  final String? description;
  
  /// Giriş tarihi
  final DateTime createdAt;
  
  /// Güncelleme tarihi
  final DateTime updatedAt;
  
  /// Konum bilgisi (opsiyonel)
  final String? location;
  
  /// Hava durumu bilgisi (opsiyonel)
  final String? weather;
  
  /// Aktivite bilgisi (opsiyonel)
  final String? activity;
  
  /// Etiketler (opsiyonel)
  final List<String>? tags;
  
  /// MoodEntry constructor'ı
  const MoodEntry({
    required this.id,
    required this.userId,
    required this.moodEmoji,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.weather,
    this.activity,
    this.tags,
  });
  
  /// Kopyalama metodu
  MoodEntry copyWith({
    String? id,
    String? userId,
    String? moodEmoji,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    String? weather,
    String? activity,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      activity: activity ?? this.activity,
      tags: tags ?? this.tags,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    moodEmoji,
    description,
    createdAt,
    updatedAt,
    location,
    weather,
    activity,
    tags,
  ];
  
  @override
  String toString() {
    return 'MoodEntry(id: $id, userId: $userId, moodEmoji: $moodEmoji, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, location: $location, weather: $weather, activity: $activity, tags: $tags)';
  }
}