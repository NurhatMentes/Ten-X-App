import 'package:equatable/equatable.dart';
import '../../domain/entities/mood_entry.dart';

/// Mood BLoC için state'ler
abstract class MoodState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Başlangıç state'i
class MoodInitial extends MoodState {}

/// Yükleniyor state'i
class MoodLoading extends MoodState {}

/// Ruh hali girişi ekleme başarılı state'i
class MoodEntryAdded extends MoodState {
  /// Eklenen ruh hali girişi
  final MoodEntry moodEntry;
  
  /// MoodEntryAdded constructor'ı
  MoodEntryAdded({required this.moodEntry});
  
  @override
  List<Object?> get props => [moodEntry];
}

/// Ruh hali girişi güncelleme başarılı state'i
class MoodEntryUpdated extends MoodState {
  /// Güncellenen ruh hali girişi
  final MoodEntry moodEntry;
  
  /// MoodEntryUpdated constructor'ı
  MoodEntryUpdated({required this.moodEntry});
  
  @override
  List<Object?> get props => [moodEntry];
}

/// Ruh hali girişi silme başarılı state'i
class MoodEntryDeleted extends MoodState {
  /// Silinen giriş kimliği
  final String id;
  
  /// MoodEntryDeleted constructor'ı
  MoodEntryDeleted({required this.id});
  
  @override
  List<Object?> get props => [id];
}

/// Belirli bir ruh hali girişi yükleme başarılı state'i
class MoodEntryLoaded extends MoodState {
  /// Yüklenen ruh hali girişi
  final MoodEntry moodEntry;
  
  /// MoodEntryLoaded constructor'ı
  MoodEntryLoaded({required this.moodEntry});
  
  @override
  List<Object?> get props => [moodEntry];
}

/// Kullanıcının tüm ruh hali girişleri yükleme başarılı state'i
class UserMoodEntriesLoaded extends MoodState {
  /// Yüklenen ruh hali girişleri listesi
  final List<MoodEntry> moodEntries;
  
  /// UserMoodEntriesLoaded constructor'ı
  UserMoodEntriesLoaded({required this.moodEntries});
  
  @override
  List<Object?> get props => [moodEntries];
}

/// Belirli bir tarih aralığındaki ruh hali girişleri yükleme başarılı state'i
class MoodEntriesByDateRangeLoaded extends MoodState {
  /// Yüklenen ruh hali girişleri listesi
  final List<MoodEntry> moodEntries;
  
  /// Başlangıç tarihi
  final DateTime startDate;
  
  /// Bitiş tarihi
  final DateTime endDate;
  
  /// MoodEntriesByDateRangeLoaded constructor'ı
  MoodEntriesByDateRangeLoaded({
    required this.moodEntries,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [moodEntries, startDate, endDate];
}

/// Belirli bir ruh hali emoji'sine göre girişleri yükleme başarılı state'i
class MoodEntriesByEmojiLoaded extends MoodState {
  /// Yüklenen ruh hali girişleri listesi
  final List<MoodEntry> moodEntries;
  
  /// Ruh hali emoji
  final String moodEmoji;
  
  /// MoodEntriesByEmojiLoaded constructor'ı
  MoodEntriesByEmojiLoaded({
    required this.moodEntries,
    required this.moodEmoji,
  });
  
  @override
  List<Object?> get props => [moodEntries, moodEmoji];
}

/// Kullanıcının bugünkü ruh hali girişi yükleme başarılı state'i
class TodayMoodEntryLoaded extends MoodState {
  /// Yüklenen ruh hali girişi (null olabilir)
  final MoodEntry? moodEntry;
  
  /// TodayMoodEntryLoaded constructor'ı
  TodayMoodEntryLoaded({required this.moodEntry});
  
  @override
  List<Object?> get props => [moodEntry];
}

/// Kullanıcının ruh hali istatistikleri yükleme başarılı state'i
class UserMoodStatsLoaded extends MoodState {
  /// Yüklenen ruh hali istatistikleri
  final Map<String, int> stats;
  
  /// Başlangıç tarihi
  final DateTime startDate;
  
  /// Bitiş tarihi
  final DateTime endDate;
  
  /// UserMoodStatsLoaded constructor'ı
  UserMoodStatsLoaded({
    required this.stats,
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [stats, startDate, endDate];
}

/// Hata state'i
class MoodError extends MoodState {
  /// Hata mesajı
  final String message;
  
  /// MoodError constructor'ı
  MoodError({required this.message});
  
  @override
  List<Object?> get props => [message];
}