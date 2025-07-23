import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/decision.dart';
import '../../domain/repositories/decision_repository.dart';
import '../../domain/usecases/create_decision.dart';
import '../../domain/usecases/vote_decision.dart';
import 'decision_event.dart';
import 'decision_state.dart';

/// Karar oylama BLoC'u
class DecisionBloc extends Bloc<DecisionEvent, DecisionState> {
  /// Karar repository'si
  final DecisionRepository repository;
  
  /// Karar oluşturma use case'i
  final CreateDecision createDecisionUseCase;
  
  /// Oy verme use case'i
  final VoteDecision voteDecisionUseCase;
  
  /// DecisionBloc constructor'ı
  DecisionBloc({
    required this.repository,
    required this.createDecisionUseCase,
    required this.voteDecisionUseCase,
  }) : super(const DecisionInitial()) {
    // Event handler'ları kaydet
    on<CreateDecisionEvent>(_onCreateDecision);
    on<UpdateDecisionEvent>(_onUpdateDecision);
    on<DeleteDecisionEvent>(_onDeleteDecision);
    on<GetDecisionEvent>(_onGetDecision);
    on<GetUserDecisionsEvent>(_onGetUserDecisions);
    on<GetPublicDecisionsEvent>(_onGetPublicDecisions);
    on<GetFriendsDecisionsEvent>(_onGetFriendsDecisions);
    on<GetDecisionsByCategoryEvent>(_onGetDecisionsByCategory);
    on<GetDecisionsByTagsEvent>(_onGetDecisionsByTags);
    on<VoteDecisionEvent>(_onVoteDecision);
    on<RemoveVoteEvent>(_onRemoveVote);
    on<UpdateDecisionStatusEvent>(_onUpdateDecisionStatus);
    on<GetUserVotedDecisionsEvent>(_onGetUserVotedDecisions);
    on<GetPopularDecisionsEvent>(_onGetPopularDecisions);
    on<GetNearbyDecisionsEvent>(_onGetNearbyDecisions);
    on<SearchDecisionsEvent>(_onSearchDecisions);
    on<RefreshDecisionsEvent>(_onRefreshDecisions);
    on<ClearDecisionsEvent>(_onClearDecisions);
  }
  
  /// Karar oluşturma handler'ı
  Future<void> _onCreateDecision(
    CreateDecisionEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Karar oluşturuluyor...'));
    
    final params = CreateDecisionParams(
      title: event.decision.title,
      description: event.decision.description,
      category: event.decision.category,
      options: event.decision.options,
      userId: event.decision.userId,
      visibility: event.decision.visibility,
      expiresAt: event.decision.expiresAt,
      tags: event.decision.tags,
      imageUrl: event.decision.imageUrl,
      location: event.decision.location,
      minVotes: event.decision.minVotes,
      maxVotes: event.decision.maxVotes,
      allowMultipleVotes: event.decision.allowMultipleVotes,
      isAnonymous: event.decision.isAnonymous,
    );
    
    final result = await createDecisionUseCase(params);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(DecisionCreated(decision: decision)),
    );
  }
  
  /// Karar güncelleme handler'ı
  Future<void> _onUpdateDecision(
    UpdateDecisionEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Karar güncelleniyor...'));
    
    final result = await repository.updateDecision(event.decision);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(DecisionUpdated(decision: decision)),
    );
  }
  
  /// Karar silme handler'ı
  Future<void> _onDeleteDecision(
    DeleteDecisionEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Karar siliniyor...'));
    
    final result = await repository.deleteDecision(event.decisionId);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (success) => emit(DecisionDeleted(decisionId: event.decisionId)),
    );
  }
  
  /// Karar getirme handler'ı
  Future<void> _onGetDecision(
    GetDecisionEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Karar yükleniyor...'));
    
    final result = await repository.getDecisionById(event.decisionId);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(DecisionLoaded(decision: decision)),
    );
  }
  
  /// Kullanıcının kararlarını getirme handler'ı
  Future<void> _onGetUserDecisions(
    GetUserDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Kararlarınız yükleniyor...'));
    
    final result = await repository.getUserDecisions(event.userId);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Henüz karar oluşturmamışsınız'));
        } else {
          emit(UserDecisionsLoaded(
            decisions: decisions,
            userId: event.userId,
          ));
        }
      },
    );
  }
  
  /// Herkese açık kararları getirme handler'ı
  Future<void> _onGetPublicDecisions(
    GetPublicDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    // Eğer yenileme değilse loading göster
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Kararlar yükleniyor...'));
    } else {
      // Pagination için mevcut state'i koru
      if (state is DecisionsLoaded) {
        final currentState = state as DecisionsLoaded;
        emit(DecisionLoadingMore(currentDecisions: currentState.decisions));
      }
    }
    
    final result = await repository.getPublicDecisions(
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
      category: event.category,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        List<Decision> allDecisions = decisions;
        
        // Pagination için mevcut kararları birleştir
        if (event.lastDecisionId != null && state is DecisionsLoaded) {
          final currentState = state as DecisionsLoaded;
          allDecisions = [...currentState.decisions, ...decisions];
        }
        
        if (allDecisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Henüz karar bulunmuyor'));
        } else {
          emit(PublicDecisionsLoaded(
            decisions: allDecisions,
            hasMore: decisions.length == event.limit,
            category: event.category,
          ));
        }
      },
    );
  }
  
  /// Arkadaşların kararlarını getirme handler'ı
  Future<void> _onGetFriendsDecisions(
    GetFriendsDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Arkadaşların kararları yükleniyor...'));
    }
    
    final result = await repository.getFriendsDecisions(
      userId: event.userId,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Arkadaşlarınızın kararı bulunmuyor'));
        } else {
          emit(FriendsDecisionsLoaded(
            decisions: decisions,
            userId: event.userId,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Kategoriye göre kararları getirme handler'ı
  Future<void> _onGetDecisionsByCategory(
    GetDecisionsByCategoryEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Kategori kararları yükleniyor...'));
    }
    
    final result = await repository.getDecisionsByCategory(
      category: event.category,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Bu kategoride karar bulunmuyor'));
        } else {
          emit(DecisionsByCategoryLoaded(
            decisions: decisions,
            category: event.category,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Etiketlere göre kararları getirme handler'ı
  Future<void> _onGetDecisionsByTags(
    GetDecisionsByTagsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Etiket kararları yükleniyor...'));
    }
    
    final result = await repository.getDecisionsByTags(
      tags: event.tags,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Bu etiketlerde karar bulunmuyor'));
        } else {
          emit(DecisionsByTagsLoaded(
            decisions: decisions,
            tags: event.tags,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Oy verme handler'ı
  Future<void> _onVoteDecision(
    VoteDecisionEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Oy veriliyor...'));
    
    final params = VoteDecisionParams(
      decisionId: event.decisionId,
      userId: event.userId,
      optionIndex: event.optionIndex,
    );
    
    final result = await voteDecisionUseCase(params);
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(VoteSubmitted(
        decision: decision,
        optionIndex: event.optionIndex,
      )),
    );
  }
  
  /// Oy kaldırma handler'ı
  Future<void> _onRemoveVote(
    RemoveVoteEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Oy kaldırılıyor...'));
    
    final result = await repository.removeVote(
      decisionId: event.decisionId,
      userId: event.userId,
      optionIndex: event.optionIndex,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(VoteRemoved(
        decision: decision,
        optionIndex: event.optionIndex,
      )),
    );
  }
  
  /// Karar durumunu güncelleme handler'ı
  Future<void> _onUpdateDecisionStatus(
    UpdateDecisionStatusEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionLoading(message: 'Karar durumu güncelleniyor...'));
    
    final result = await repository.updateDecisionStatus(
      decisionId: event.decisionId,
      status: event.status,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decision) => emit(DecisionStatusUpdated(decision: decision)),
    );
  }
  
  /// Kullanıcının oy verdiği kararları getirme handler'ı
  Future<void> _onGetUserVotedDecisions(
    GetUserVotedDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Oy verdiğiniz kararlar yükleniyor...'));
    }
    
    final result = await repository.getUserVotedDecisions(
      userId: event.userId,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Henüz hiçbir karara oy vermemişsiniz'));
        } else {
          emit(UserVotedDecisionsLoaded(
            decisions: decisions,
            userId: event.userId,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Popüler kararları getirme handler'ı
  Future<void> _onGetPopularDecisions(
    GetPopularDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Popüler kararlar yükleniyor...'));
    }
    
    final result = await repository.getPopularDecisions(
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Popüler karar bulunmuyor'));
        } else {
          emit(PopularDecisionsLoaded(
            decisions: decisions,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Yakındaki kararları getirme handler'ı
  Future<void> _onGetNearbyDecisions(
    GetNearbyDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Yakındaki kararlar yükleniyor...'));
    }
    
    final result = await repository.getNearbyDecisions(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: event.radiusInKm,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Yakınlarda karar bulunmuyor'));
        } else {
          emit(NearbyDecisionsLoaded(
            decisions: decisions,
            latitude: event.latitude,
            longitude: event.longitude,
            radiusInKm: event.radiusInKm,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Kararları arama handler'ı
  Future<void> _onSearchDecisions(
    SearchDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    if (event.lastDecisionId == null) {
      emit(const DecisionLoading(message: 'Arama yapılıyor...'));
    }
    
    final result = await repository.searchDecisions(
      query: event.query,
      limit: event.limit,
      lastDecisionId: event.lastDecisionId,
    );
    
    result.fold(
      (failure) => emit(DecisionError(message: failure.message)),
      (decisions) {
        if (decisions.isEmpty) {
          emit(const DecisionEmpty(message: 'Arama sonucu bulunamadı'));
        } else {
          emit(SearchResultsLoaded(
            decisions: decisions,
            query: event.query,
            hasMore: decisions.length == event.limit,
          ));
        }
      },
    );
  }
  
  /// Kararları yenileme handler'ı
  Future<void> _onRefreshDecisions(
    RefreshDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    // Mevcut state'e göre yenileme yap
    if (state is PublicDecisionsLoaded) {
      final currentState = state as PublicDecisionsLoaded;
      emit(DecisionRefreshing(currentDecisions: currentState.decisions));
      
      add(GetPublicDecisionsEvent(
        limit: currentState.decisions.length,
        category: currentState.category,
      ));
    } else if (state is UserDecisionsLoaded) {
      final currentState = state as UserDecisionsLoaded;
      emit(DecisionRefreshing(currentDecisions: currentState.decisions));
      
      add(GetUserDecisionsEvent(userId: currentState.userId));
    } else if (state is FriendsDecisionsLoaded) {
      final currentState = state as FriendsDecisionsLoaded;
      emit(DecisionRefreshing(currentDecisions: currentState.decisions));
      
      add(GetFriendsDecisionsEvent(
        userId: currentState.userId,
        limit: currentState.decisions.length,
      ));
    } else {
      // Varsayılan olarak herkese açık kararları yenile
      add(const GetPublicDecisionsEvent());
    }
  }
  
  /// Kararları temizleme handler'ı
  Future<void> _onClearDecisions(
    ClearDecisionsEvent event,
    Emitter<DecisionState> emit,
  ) async {
    emit(const DecisionInitial());
  }
}