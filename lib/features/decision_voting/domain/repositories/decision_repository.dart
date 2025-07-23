import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/decision.dart';

/// Karar repository interface'i
abstract class DecisionRepository {
  /// Yeni karar oluşturma
  Future<Either<Failure, Decision>> createDecision(Decision decision);
  
  /// Karar güncelleme
  Future<Either<Failure, Decision>> updateDecision(Decision decision);
  
  /// Karar silme
  Future<Either<Failure, bool>> deleteDecision(String decisionId);
  
  /// ID'ye göre karar getirme
  Future<Either<Failure, Decision>> getDecisionById(String decisionId);
  
  /// Kullanıcının kararlarını getirme
  Future<Either<Failure, List<Decision>>> getUserDecisions(String userId);
  
  /// Herkese açık kararları getirme
  Future<Either<Failure, List<Decision>>> getPublicDecisions({
    int limit = 10,
    String? lastDecisionId,
    String? category,
  });
  
  /// Arkadaşların kararlarını getirme
  Future<Either<Failure, List<Decision>>> getFriendsDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Kategoriye göre kararları getirme
  Future<Either<Failure, List<Decision>>> getDecisionsByCategory({
    required String category,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Etiketlere göre kararları getirme
  Future<Either<Failure, List<Decision>>> getDecisionsByTags({
    required List<String> tags,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Karara oy verme
  Future<Either<Failure, Decision>> voteDecision({
    required String decisionId,
    required String userId,
    required int optionIndex,
  });
  
  /// Karardan oy kaldırma
  Future<Either<Failure, Decision>> removeVote({
    required String decisionId,
    required String userId,
    required int optionIndex,
  });
  
  /// Karar durumunu güncelleme
  Future<Either<Failure, Decision>> updateDecisionStatus({
    required String decisionId,
    required DecisionStatus status,
  });
  
  /// Kullanıcının oy verdiği kararları getirme
  Future<Either<Failure, List<Decision>>> getUserVotedDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Popüler kararları getirme
  Future<Either<Failure, List<Decision>>> getPopularDecisions({
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Yakındaki kararları getirme
  Future<Either<Failure, List<Decision>>> getNearbyDecisions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Kararları arama
  Future<Either<Failure, List<Decision>>> searchDecisions({
    required String query,
    int limit = 10,
    String? lastDecisionId,
  });
}