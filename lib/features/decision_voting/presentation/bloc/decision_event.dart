import 'package:equatable/equatable.dart';

import '../../domain/entities/decision.dart';

/// Karar oylama event'leri için abstract sınıf
abstract class DecisionEvent extends Equatable {
  /// DecisionEvent constructor'ı
  const DecisionEvent();
  
  @override
  List<Object?> get props => [];
}

/// Karar oluşturma event'i
class CreateDecisionEvent extends DecisionEvent {
  /// Oluşturulacak karar
  final Decision decision;
  
  /// CreateDecisionEvent constructor'ı
  const CreateDecisionEvent({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Karar güncelleme event'i
class UpdateDecisionEvent extends DecisionEvent {
  /// Güncellenecek karar
  final Decision decision;
  
  /// UpdateDecisionEvent constructor'ı
  const UpdateDecisionEvent({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Karar silme event'i
class DeleteDecisionEvent extends DecisionEvent {
  /// Silinecek karar ID'si
  final String decisionId;
  
  /// DeleteDecisionEvent constructor'ı
  const DeleteDecisionEvent({required this.decisionId});
  
  @override
  List<Object?> get props => [decisionId];
}

/// Karar getirme event'i
class GetDecisionEvent extends DecisionEvent {
  /// Getirilecek karar ID'si
  final String decisionId;
  
  /// GetDecisionEvent constructor'ı
  const GetDecisionEvent({required this.decisionId});
  
  @override
  List<Object?> get props => [decisionId];
}

/// Kullanıcının kararlarını getirme event'i
class GetUserDecisionsEvent extends DecisionEvent {
  /// Kullanıcı ID'si
  final String userId;
  
  /// GetUserDecisionsEvent constructor'ı
  const GetUserDecisionsEvent({required this.userId});
  
  @override
  List<Object?> get props => [userId];
}

/// Herkese açık kararları getirme event'i
class GetPublicDecisionsEvent extends DecisionEvent {
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// Kategori filtresi
  final String? category;
  
  /// GetPublicDecisionsEvent constructor'ı
  const GetPublicDecisionsEvent({
    this.limit = 10,
    this.lastDecisionId,
    this.category,
  });
  
  @override
  List<Object?> get props => [limit, lastDecisionId, category];
}

/// Arkadaşların kararlarını getirme event'i
class GetFriendsDecisionsEvent extends DecisionEvent {
  /// Kullanıcı ID'si
  final String userId;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetFriendsDecisionsEvent constructor'ı
  const GetFriendsDecisionsEvent({
    required this.userId,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [userId, limit, lastDecisionId];
}

/// Kategoriye göre kararları getirme event'i
class GetDecisionsByCategoryEvent extends DecisionEvent {
  /// Kategori
  final String category;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetDecisionsByCategoryEvent constructor'ı
  const GetDecisionsByCategoryEvent({
    required this.category,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [category, limit, lastDecisionId];
}

/// Etiketlere göre kararları getirme event'i
class GetDecisionsByTagsEvent extends DecisionEvent {
  /// Etiketler
  final List<String> tags;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetDecisionsByTagsEvent constructor'ı
  const GetDecisionsByTagsEvent({
    required this.tags,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [tags, limit, lastDecisionId];
}

/// Karara oy verme event'i
class VoteDecisionEvent extends DecisionEvent {
  /// Karar ID'si
  final String decisionId;
  
  /// Kullanıcı ID'si
  final String userId;
  
  /// Seçenek indeksi
  final int optionIndex;
  
  /// VoteDecisionEvent constructor'ı
  const VoteDecisionEvent({
    required this.decisionId,
    required this.userId,
    required this.optionIndex,
  });
  
  @override
  List<Object?> get props => [decisionId, userId, optionIndex];
}

/// Karardan oy kaldırma event'i
class RemoveVoteEvent extends DecisionEvent {
  /// Karar ID'si
  final String decisionId;
  
  /// Kullanıcı ID'si
  final String userId;
  
  /// Seçenek indeksi
  final int optionIndex;
  
  /// RemoveVoteEvent constructor'ı
  const RemoveVoteEvent({
    required this.decisionId,
    required this.userId,
    required this.optionIndex,
  });
  
  @override
  List<Object?> get props => [decisionId, userId, optionIndex];
}

/// Karar durumunu güncelleme event'i
class UpdateDecisionStatusEvent extends DecisionEvent {
  /// Karar ID'si
  final String decisionId;
  
  /// Yeni durum
  final DecisionStatus status;
  
  /// UpdateDecisionStatusEvent constructor'ı
  const UpdateDecisionStatusEvent({
    required this.decisionId,
    required this.status,
  });
  
  @override
  List<Object?> get props => [decisionId, status];
}

/// Kullanıcının oy verdiği kararları getirme event'i
class GetUserVotedDecisionsEvent extends DecisionEvent {
  /// Kullanıcı ID'si
  final String userId;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetUserVotedDecisionsEvent constructor'ı
  const GetUserVotedDecisionsEvent({
    required this.userId,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [userId, limit, lastDecisionId];
}

/// Popüler kararları getirme event'i
class GetPopularDecisionsEvent extends DecisionEvent {
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetPopularDecisionsEvent constructor'ı
  const GetPopularDecisionsEvent({
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [limit, lastDecisionId];
}

/// Yakındaki kararları getirme event'i
class GetNearbyDecisionsEvent extends DecisionEvent {
  /// Enlem
  final double latitude;
  
  /// Boylam
  final double longitude;
  
  /// Yarıçap (km)
  final double radiusInKm;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// GetNearbyDecisionsEvent constructor'ı
  const GetNearbyDecisionsEvent({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusInKm,
    limit,
    lastDecisionId,
  ];
}

/// Kararları arama event'i
class SearchDecisionsEvent extends DecisionEvent {
  /// Arama sorgusu
  final String query;
  
  /// Sayfa limiti
  final int limit;
  
  /// Son karar ID'si (pagination için)
  final String? lastDecisionId;
  
  /// SearchDecisionsEvent constructor'ı
  const SearchDecisionsEvent({
    required this.query,
    this.limit = 10,
    this.lastDecisionId,
  });
  
  @override
  List<Object?> get props => [query, limit, lastDecisionId];
}

/// Kararları yenileme event'i
class RefreshDecisionsEvent extends DecisionEvent {
  /// RefreshDecisionsEvent constructor'ı
  const RefreshDecisionsEvent();
}

/// Karar listesini temizleme event'i
class ClearDecisionsEvent extends DecisionEvent {
  /// ClearDecisionsEvent constructor'ı
  const ClearDecisionsEvent();
}