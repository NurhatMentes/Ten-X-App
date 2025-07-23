import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_remote_data_source.dart';
import '../models/mood_entry_model.dart';

/// MoodRepository'nin implementasyonu
class MoodRepositoryImpl implements MoodRepository {
  /// Remote data source
  final MoodRemoteDataSource remoteDataSource;
  
  /// Network bilgisi
  final NetworkInfo networkInfo;
  
  /// MoodRepositoryImpl constructor'ı
  const MoodRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, MoodEntry>> addMoodEntry(MoodEntry moodEntry) async {
    if (await networkInfo.isConnected) {
      try {
        final moodEntryModel = MoodEntryModel.fromEntity(moodEntry);
        final result = await remoteDataSource.addMoodEntry(moodEntryModel);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, MoodEntry>> updateMoodEntry(MoodEntry moodEntry) async {
    if (await networkInfo.isConnected) {
      try {
        final moodEntryModel = MoodEntryModel.fromEntity(moodEntry);
        final result = await remoteDataSource.updateMoodEntry(moodEntryModel);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteMoodEntry(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteMoodEntry(id);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, MoodEntry>> getMoodEntry(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMoodEntry(id);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<MoodEntry>>> getUserMoodEntries(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserMoodEntries(userId);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMoodEntriesByDateRange(
          userId,
          startDate,
          endDate,
        );
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<MoodEntry>>> getMoodEntriesByEmoji(
    String userId,
    String moodEmoji,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMoodEntriesByEmoji(
          userId,
          moodEmoji,
        );
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, MoodEntry?>> getTodayMoodEntry(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getTodayMoodEntry(userId);
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, int>>> getUserMoodStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserMoodStats(
          userId,
          startDate,
          endDate,
        );
        return Right(result);
      } on FirestoreFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
}