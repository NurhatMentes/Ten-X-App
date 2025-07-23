import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/decision.dart';
import '../repositories/decision_repository.dart';

/// Karara oy verme use case'i
class VoteDecision {
  /// Decision repository
  final DecisionRepository repository;
  
  /// VoteDecision constructor'ı
  const VoteDecision(this.repository);
  
  /// Karara oy verme metodu
  Future<Either<Failure, Decision>> call(VoteDecisionParams params) async {
    // Önce kararı getir ve doğrula
    final decisionResult = await repository.getDecisionById(params.decisionId);
    
    return decisionResult.fold(
      (failure) => Left(failure),
      (decision) async {
        // Karar doğrulamalarını yap
        final validationResult = _validateVote(decision, params);
        if (validationResult != null) {
          return Left(ValidationFailure(validationResult));
        }
        
        // Eğer çoklu seçim yapılamıyorsa, önceki oyları kaldır
        if (!decision.allowMultipleVotes) {
          final userVotes = decision.getUserVotes(params.userId);
          for (final voteIndex in userVotes) {
            final removeResult = await repository.removeVote(
              decisionId: params.decisionId,
              userId: params.userId,
              optionIndex: voteIndex,
            );
            if (removeResult.isLeft()) {
              return removeResult;
            }
          }
        }
        
        // Oy ver
        return await repository.voteDecision(
          decisionId: params.decisionId,
          userId: params.userId,
          optionIndex: params.optionIndex,
        );
      },
    );
  }
  
  /// Oy verme doğrulamalarını yapan metod
  String? _validateVote(Decision decision, VoteDecisionParams params) {
    // Karar aktif mi?
    if (!decision.isActive) {
      if (decision.status == DecisionStatus.completed) {
        return 'Bu karar tamamlanmış, oy verilemez';
      } else if (decision.status == DecisionStatus.cancelled) {
        return 'Bu karar iptal edilmiş, oy verilemez';
      } else if (decision.status == DecisionStatus.draft) {
        return 'Bu karar henüz taslak durumda, oy verilemez';
      }
    }
    
    // Karar süresi dolmuş mu?
    if (decision.isExpired) {
      return 'Bu kararın süresi dolmuş, oy verilemez';
    }
    
    // Maksimum oy sayısına ulaşılmış mı?
    if (decision.hasMaxVotes) {
      return 'Bu karar maksimum oy sayısına ulaşmış, oy verilemez';
    }
    
    // Seçenek geçerli mi?
    if (params.optionIndex < 0 || params.optionIndex >= decision.options.length) {
      return 'Geçersiz seçenek';
    }
    
    // Kullanıcı zaten bu seçeneğe oy vermiş mi?
    final userVotes = decision.getUserVotes(params.userId);
    if (userVotes.contains(params.optionIndex)) {
      return 'Bu seçeneğe zaten oy verdiniz';
    }
    
    // Çoklu seçim yapılamıyorsa ve kullanıcı başka bir seçeneğe oy vermişse
    if (!decision.allowMultipleVotes && userVotes.isNotEmpty) {
      // Bu durumda önceki oy kaldırılacak, hata değil
    }
    
    // Kullanıcı kendi kararına oy verebilir mi? (isteğe bağlı kısıtlama)
    // if (decision.userId == params.userId) {
    //   return 'Kendi kararınıza oy veremezsiniz';
    // }
    
    return null;
  }
}

/// Karara oy verme parametreleri
class VoteDecisionParams extends Equatable {
  /// Karar ID'si
  final String decisionId;
  
  /// Oy veren kullanıcı ID'si
  final String userId;
  
  /// Seçenek index'i
  final int optionIndex;
  
  /// VoteDecisionParams constructor'ı
  const VoteDecisionParams({
    required this.decisionId,
    required this.userId,
    required this.optionIndex,
  });
  
  @override
  List<Object?> get props => [decisionId, userId, optionIndex];
}