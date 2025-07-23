import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/decision.dart';
import '../../domain/repositories/decision_repository.dart';
import '../datasources/decision_remote_data_source.dart';
import '../models/decision_model.dart';

/// Karar repository implementasyonu
class DecisionRepositoryImpl implements DecisionRepository {
  /// Remote data source
  final DecisionRemoteDataSource remoteDataSource;
  
  /// Network bilgisi
  final NetworkInfo networkInfo;
  
  /// DecisionRepositoryImpl constructor'ı
  DecisionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, Decision>> createDecision(Decision decision) async {
    if (await networkInfo.isConnected) {
      try {
        final decisionModel = DecisionModel.fromEntity(decision);
        final result = await remoteDataSource.createDecision(decisionModel);
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Decision>> updateDecision(Decision decision) async {
    if (await networkInfo.isConnected) {
      try {
        final decisionModel = DecisionModel.fromEntity(decision);
        final result = await remoteDataSource.updateDecision(decisionModel);
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> deleteDecision(String decisionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteDecision(decisionId);
        return Right(result);
      } on Exception catch (e) {
          return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Decision>> getDecisionById(String decisionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDecisionById(decisionId);
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<Decision>>> getUserDecisions(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserDecisions(userId);
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<Decision>>> getPublicDecisions({
    int limit = 10,
    String? lastDecisionId,
    String? category,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getPublicDecisions(
          limit: limit,
          lastDecisionId: lastDecisionId,
          category: category,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<Decision>>> getFriendsDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getFriendsDecisions(
          userId: userId,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<Decision>>> getDecisionsByCategory({
    required String category,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDecisionsByCategory(
          category: category,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }

  @override
  Future<Either<Failure, List<Decision>>> getDecisionsByTags({
    required List<String> tags,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDecisionsByTags(
          tags: tags,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Decision>> voteDecision({
    required String decisionId,
    required String userId,
    required int optionIndex,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.voteDecision(
          decisionId: decisionId,
          userId: userId,
          optionIndex: optionIndex,
        );
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Decision>> removeVote({
    required String decisionId,
    required String userId,
    required int optionIndex,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.removeVote(
          decisionId: decisionId,
          userId: userId,
          optionIndex: optionIndex,
        );
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, Decision>> updateDecisionStatus({
    required String decisionId,
    required DecisionStatus status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateDecisionStatus(
          decisionId: decisionId,
          status: status,
        );
        return Right(result.toEntity());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<Decision>>> getUserVotedDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserVotedDecisions(
          userId: userId,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<Decision>>> getPopularDecisions({
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getPopularDecisions(
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<Decision>>> getNearbyDecisions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getNearbyDecisions(
          latitude: latitude,
          longitude: longitude,
          radiusInKm: radiusInKm,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
  
  @override
  Future<Either<Failure, List<Decision>>> searchDecisions({
    required String query,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.searchDecisions(
          query: query,
          limit: limit,
          lastDecisionId: lastDecisionId,
        );
        return Right(result.map((model) => model.toEntity()).toList());
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('İnternet bağlantısı yok'));
    }
  }
}