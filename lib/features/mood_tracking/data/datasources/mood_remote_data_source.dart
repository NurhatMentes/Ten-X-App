import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

/// Ruh hali takibi için remote data source interface
abstract class MoodRemoteDataSource {
  /// Yeni bir ruh hali girişi ekleme
  Future<MoodEntryModel> addMoodEntry(MoodEntryModel moodEntry);
  
  /// Belirli bir ruh hali girişini güncelleme
  Future<MoodEntryModel> updateMoodEntry(MoodEntryModel moodEntry);
  
  /// Belirli bir ruh hali girişini silme
  Future<bool> deleteMoodEntry(String id);
  
  /// Belirli bir ruh hali girişini getirme
  Future<MoodEntryModel> getMoodEntry(String id);
  
  /// Kullanıcının tüm ruh hali girişlerini getirme
  Future<List<MoodEntryModel>> getUserMoodEntries(String userId);
  
  /// Belirli bir tarih aralığındaki ruh hali girişlerini getirme
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Belirli bir ruh hali emoji'sine göre girişleri getirme
  Future<List<MoodEntryModel>> getMoodEntriesByEmoji(
    String userId,
    String moodEmoji,
  );
  
  /// Kullanıcının bugünkü ruh hali girişini getirme
  Future<MoodEntryModel?> getTodayMoodEntry(String userId);
  
  /// Kullanıcının ruh hali istatistiklerini getirme
  Future<Map<String, int>> getUserMoodStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

/// MoodRemoteDataSource'un Firestore implementasyonu
class MoodRemoteDataSourceImpl implements MoodRemoteDataSource {
  /// Firestore instance'ı
  final FirebaseFirestore firestore;
  
  /// MoodRemoteDataSourceImpl constructor'ı
  const MoodRemoteDataSourceImpl({required this.firestore});
  
  /// Mood entries collection referansı
  CollectionReference get _moodCollection => 
      firestore.collection(AppConstants.moodEntriesCollection);
  
  @override
  Future<MoodEntryModel> addMoodEntry(MoodEntryModel moodEntry) async {
    try {
      final docRef = await _moodCollection.add(moodEntry.toFirestore());
      final doc = await docRef.get();
      return MoodEntryModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreFailure('Ruh hali girişi eklenirken hata oluştu: $e');
    }
  }
  
  @override
  Future<MoodEntryModel> updateMoodEntry(MoodEntryModel moodEntry) async {
    try {
      await _moodCollection.doc(moodEntry.id).update(moodEntry.toFirestore());
      final doc = await _moodCollection.doc(moodEntry.id).get();
      return MoodEntryModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreFailure('Ruh hali girişi güncellenirken hata oluştu: $e');
    }
  }
  
  @override
  Future<bool> deleteMoodEntry(String id) async {
    try {
      await _moodCollection.doc(id).delete();
      return true;
    } catch (e) {
      throw FirestoreFailure('Ruh hali girişi silinirken hata oluştu: $e');
    }
  }
  
  @override
  Future<MoodEntryModel> getMoodEntry(String id) async {
    try {
      final doc = await _moodCollection.doc(id).get();
      if (!doc.exists) {
        throw FirestoreFailure('Ruh hali girişi bulunamadı');
      }
      return MoodEntryModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreFailure('Ruh hali girişi getirilirken hata oluştu: $e');
    }
  }
  
  @override
  Future<List<MoodEntryModel>> getUserMoodEntries(String userId) async {
    try {
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MoodEntryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Kullanıcı ruh hali girişleri getirilirken hata oluştu: $e');
    }
  }
  
  @override
  Future<List<MoodEntryModel>> getMoodEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MoodEntryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Tarih aralığındaki ruh hali girişleri getirilirken hata oluştu: $e');
    }
  }
  
  @override
  Future<List<MoodEntryModel>> getMoodEntriesByEmoji(
    String userId,
    String moodEmoji,
  ) async {
    try {
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: userId)
          .where('moodEmoji', isEqualTo: moodEmoji)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MoodEntryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Emoji\'ye göre ruh hali girişleri getirilirken hata oluştu: $e');
    }
  }
  
  @override
  Future<MoodEntryModel?> getTodayMoodEntry(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return MoodEntryModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw FirestoreFailure('Bugünkü ruh hali girişi getirilirken hata oluştu: $e');
    }
  }
  
  @override
  Future<Map<String, int>> getUserMoodStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      
      final Map<String, int> stats = {};
      
      for (final doc in querySnapshot.docs) {
        final moodEntry = MoodEntryModel.fromFirestore(doc);
        stats[moodEntry.moodEmoji] = (stats[moodEntry.moodEmoji] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      throw FirestoreFailure('Ruh hali istatistikleri getirilirken hata oluştu: $e');
    }
  }
}