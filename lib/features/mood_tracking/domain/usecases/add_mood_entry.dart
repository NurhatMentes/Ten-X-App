import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

/// Ruh hali girişi ekleme use case'i
class AddMoodEntry {
  /// MoodRepository referansı
  final MoodRepository repository;
  
  /// AddMoodEntry constructor'ı
  const AddMoodEntry(this.repository);
  
  /// Use case'i çalıştırma metodu
  Future<Either<Failure, MoodEntry>> call(AddMoodEntryParams params) async {
    // Bugün zaten bir giriş var mı kontrol et
    final todayEntryResult = await repository.getTodayMoodEntry(params.userId);
    
    return todayEntryResult.fold(
      (failure) => Left(failure),
      (todayEntry) async {
        if (todayEntry != null) {
          // Bugün zaten bir giriş varsa güncelle
          final updatedEntry = todayEntry.copyWith(
            moodEmoji: params.moodEmoji,
            description: params.description,
            updatedAt: DateTime.now(),
            location: params.location,
            weather: params.weather,
            activity: params.activity,
            tags: params.tags,
          );
          return await repository.updateMoodEntry(updatedEntry);
        } else {
          // Yeni giriş oluştur
          final newEntry = MoodEntry(
            id: '', // Firestore otomatik ID oluşturacak
            userId: params.userId,
            moodEmoji: params.moodEmoji,
            description: params.description,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            location: params.location,
            weather: params.weather,
            activity: params.activity,
            tags: params.tags,
          );
          return await repository.addMoodEntry(newEntry);
        }
      },
    );
  }
}

/// AddMoodEntry parametreleri
class AddMoodEntryParams {
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
  
  /// AddMoodEntryParams constructor'ı
  const AddMoodEntryParams({
    required this.userId,
    required this.moodEmoji,
    this.description,
    this.location,
    this.weather,
    this.activity,
    this.tags,
  });
}