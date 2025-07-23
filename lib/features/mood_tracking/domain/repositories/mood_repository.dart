import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/mood_entry.dart';

/// Ruh hali takibi için repository interface
abstract class MoodRepository {
  /// Yeni bir ruh hali girişi ekleme
  Future<Either<Failure, MoodEntry>> addMoodEntry(MoodEntry moodEntry);
  
  /// Belirli bir ruh hali girişini güncelleme
  Future<Either<Failure, MoodEntry>> updateMoodEntry(MoodEntry moodEntry);
  
  /// Belirli bir ruh hali girişini silme
  Future<Either<Failure, bool>> deleteMoodEntry(String id);
  
  /// Belirli bir ruh hali girişini getirme
  Future<Either<Failure, MoodEntry>> getMoodEntry(String id);
  
  /// Kullanıcının tüm ruh hali girişlerini getirme
  Future<Either<Failure, List<MoodEntry>>> getUserMoodEntries(String userId);
  
  /// Belirli bir tarih aralığındaki ruh hali girişlerini getirme
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Belirli bir ruh hali emoji'sine göre girişleri getirme
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByEmoji(
    String userId,
    String moodEmoji,
  );
  
  /// Kullanıcının bugünkü ruh hali girişini getirme
  Future<Either<Failure, MoodEntry?>> getTodayMoodEntry(String userId);
  
  /// Kullanıcının ruh hali istatistiklerini getirme
  Future<Either<Failure, Map<String, int>>> getUserMoodStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}