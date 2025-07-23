import 'package:equatable/equatable.dart';

/// Mood BLoC için event'ler
abstract class MoodEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Ruh hali girişi ekleme event'i
class AddMoodEntryEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// Ruh hali emoji
  final String moodEmoji;
  
  /// Ruh hali açıklaması (opsiyonel)
  final String? description;
  
  /// Konum bilgisi (opsiyonel)
  final String? location;
  
  /// Hava durumu bilgisi (opsiyonel)
  final String? weather;
  
  /// Aktivite bilgisi (opsiyonel)
  final String? activity;
  
  /// Etiketler (opsiyonel)
  final List<String>? tags;
  
  /// AddMoodEntryEvent constructor'ı
  AddMoodEntryEvent({
    required this.userId,
    required this.moodEmoji,
    this.description,
    this.location,
    this.weather,
    this.activity,
    this.tags,
  });
  
  @override
  List<Object?> get props => [
    userId,
    moodEmoji,
    description,
    location,
    weather,
    activity,
    tags,
  ];
}

/// Ruh hali girişi güncelleme event'i
class UpdateMoodEntryEvent extends MoodEvent {
  /// Giriş kimliği
  final String id;
  
  /// Kullanıcı kimliği
  final String userId;
  
  /// Ruh hali emoji
  final String moodEmoji;
  
  /// Ruh hali açıklaması (opsiyonel)
  final String? description;
  
  /// Konum bilgisi (opsiyonel)
  final String? location;
  
  /// Hava durumu bilgisi (opsiyonel)
  final String? weather;
  
  /// Aktivite bilgisi (opsiyonel)
  final String? activity;
  
  /// Etiketler (opsiyonel)
  final List<String>? tags;
  
  /// Oluşturma tarihi
  final DateTime createdAt;
  
  /// UpdateMoodEntryEvent constructor'ı
  UpdateMoodEntryEvent({
    required this.id,
    required this.userId,
    required this.moodEmoji,
    this.description,
    required this.createdAt,
    this.location,
    this.weather,
    this.activity,
    this.tags,
  });
  
  @override
  List<Object?> get props => [
    id,
    userId,
    moodEmoji,
    description,
    createdAt,
    location,
    weather,
    activity,
    tags,
  ];
}

/// Ruh hali girişi silme event'i
class DeleteMoodEntryEvent extends MoodEvent {
  /// Giriş kimliği
  final String id;
  
  /// DeleteMoodEntryEvent constructor'ı
  DeleteMoodEntryEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

/// Belirli bir ruh hali girişini getirme event'i
class GetMoodEntryEvent extends MoodEvent {
  /// Giriş kimliği
  final String id;
  
  /// GetMoodEntryEvent constructor'ı
  GetMoodEntryEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

/// Kullanıcının tüm ruh hali girişlerini getirme event'i
class GetUserMoodEntriesEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// GetUserMoodEntriesEvent constructor'ı
  GetUserMoodEntriesEvent({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

/// Belirli bir tarih aralığındaki ruh hali girişlerini getirme event'i
class GetMoodEntriesByDateRangeEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// Başlangıç tarihi
  final DateTime startDate;
  
  /// Bitiş tarihi
  final DateTime endDate;
  
  /// GetMoodEntriesByDateRangeEvent constructor'ı
  GetMoodEntriesByDateRangeEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Belirli bir ruh hali emoji'sine göre girişleri getirme event'i
class GetMoodEntriesByEmojiEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// Ruh hali emoji
  final String moodEmoji;
  
  /// GetMoodEntriesByEmojiEvent constructor'ı
  GetMoodEntriesByEmojiEvent({
    required this.userId,
    required this.moodEmoji,
  });
  
  @override
  List<Object?> get props => [userId, moodEmoji];
}

/// Kullanıcının bugünkü ruh hali girişini getirme event'i
class GetTodayMoodEntryEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// GetTodayMoodEntryEvent constructor'ı
  GetTodayMoodEntryEvent({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

/// Kullanıcının ruh hali istatistiklerini getirme event'i
class GetUserMoodStatsEvent extends MoodEvent {
  /// Kullanıcı kimliği
  final String userId;
  
  /// Başlangıç tarihi
  final DateTime startDate;
  
  /// Bitiş tarihi
  final DateTime endDate;
  
  /// GetUserMoodStatsEvent constructor'ı
  GetUserMoodStatsEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [userId, startDate, endDate];
}