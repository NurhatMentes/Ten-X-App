import 'package:equatable/equatable.dart';

import '../../domain/entities/decision.dart';

/// Karar oylama state'leri için abstract sınıf
abstract class DecisionState extends Equatable {
  /// DecisionState constructor'ı
  const DecisionState();
  
  @override
  List<Object?> get props => [];
}

/// Başlangıç state'i
class DecisionInitial extends DecisionState {
  /// DecisionInitial constructor'ı
  const DecisionInitial();
}

/// Yükleniyor state'i
class DecisionLoading extends DecisionState {
  /// Yükleme mesajı
  final String? message;
  
  /// DecisionLoading constructor'ı
  const DecisionLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Karar oluşturuldu state'i
class DecisionCreated extends DecisionState {
  /// Oluşturulan karar
  final Decision decision;
  
  /// DecisionCreated constructor'ı
  const DecisionCreated({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Karar güncellendi state'i
class DecisionUpdated extends DecisionState {
  /// Güncellenen karar
  final Decision decision;
  
  /// DecisionUpdated constructor'ı
  const DecisionUpdated({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Karar silindi state'i
class DecisionDeleted extends DecisionState {
  /// Silinen karar ID'si
  final String decisionId;
  
  /// DecisionDeleted constructor'ı
  const DecisionDeleted({required this.decisionId});
  
  @override
  List<Object?> get props => [decisionId];
}

/// Karar yüklendi state'i
class DecisionLoaded extends DecisionState {
  /// Yüklenen karar
  final Decision decision;
  
  /// DecisionLoaded constructor'ı
  const DecisionLoaded({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Kararlar yüklendi state'i
class DecisionsLoaded extends DecisionState {
  /// Yüklenen kararlar
  final List<Decision> decisions;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// Yenileniyor mu?
  final bool isRefreshing;
  
  /// DecisionsLoaded constructor'ı
  const DecisionsLoaded({
    required this.decisions,
    this.hasMore = false,
    this.isRefreshing = false,
  });
  
  @override
  List<Object?> get props => [decisions, hasMore, isRefreshing];
  
  /// Kopyalama metodu
  DecisionsLoaded copyWith({
    List<Decision>? decisions,
    bool? hasMore,
    bool? isRefreshing,
  }) {
    return DecisionsLoaded(
      decisions: decisions ?? this.decisions,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Kullanıcının kararları yüklendi state'i
class UserDecisionsLoaded extends DecisionState {
  /// Kullanıcının kararları
  final List<Decision> decisions;
  
  /// Kullanıcı ID'si
  final String userId;
  
  /// UserDecisionsLoaded constructor'ı
  const UserDecisionsLoaded({
    required this.decisions,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [decisions, userId];
}

/// Herkese açık kararlar yüklendi state'i
class PublicDecisionsLoaded extends DecisionState {
  /// Herkese açık kararlar
  final List<Decision> decisions;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// Kategori filtresi
  final String? category;
  
  /// PublicDecisionsLoaded constructor'ı
  const PublicDecisionsLoaded({
    required this.decisions,
    this.hasMore = false,
    this.category,
  });
  
  @override
  List<Object?> get props => [decisions, hasMore, category];
}

/// Arkadaşların kararları yüklendi state'i
class FriendsDecisionsLoaded extends DecisionState {
  /// Arkadaşların kararları
  final List<Decision> decisions;
  
  /// Kullanıcı ID'si
  final String userId;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// FriendsDecisionsLoaded constructor'ı
  const FriendsDecisionsLoaded({
    required this.decisions,
    required this.userId,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, userId, hasMore];
}

/// Kategoriye göre kararlar yüklendi state'i
class DecisionsByCategoryLoaded extends DecisionState {
  /// Kategoriye göre kararlar
  final List<Decision> decisions;
  
  /// Kategori
  final String category;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// DecisionsByCategoryLoaded constructor'ı
  const DecisionsByCategoryLoaded({
    required this.decisions,
    required this.category,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, category, hasMore];
}

/// Etiketlere göre kararlar yüklendi state'i
class DecisionsByTagsLoaded extends DecisionState {
  /// Etiketlere göre kararlar
  final List<Decision> decisions;
  
  /// Etiketler
  final List<String> tags;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// DecisionsByTagsLoaded constructor'ı
  const DecisionsByTagsLoaded({
    required this.decisions,
    required this.tags,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, tags, hasMore];
}

/// Oy verildi state'i
class VoteSubmitted extends DecisionState {
  /// Güncellenen karar
  final Decision decision;
  
  /// Oy verilen seçenek indeksi
  final int optionIndex;
  
  /// VoteSubmitted constructor'ı
  const VoteSubmitted({
    required this.decision,
    required this.optionIndex,
  });
  
  @override
  List<Object?> get props => [decision, optionIndex];
}

/// Oy kaldırıldı state'i
class VoteRemoved extends DecisionState {
  /// Güncellenen karar
  final Decision decision;
  
  /// Oy kaldırılan seçenek indeksi
  final int optionIndex;
  
  /// VoteRemoved constructor'ı
  const VoteRemoved({
    required this.decision,
    required this.optionIndex,
  });
  
  @override
  List<Object?> get props => [decision, optionIndex];
}

/// Karar durumu güncellendi state'i
class DecisionStatusUpdated extends DecisionState {
  /// Güncellenen karar
  final Decision decision;
  
  /// DecisionStatusUpdated constructor'ı
  const DecisionStatusUpdated({required this.decision});
  
  @override
  List<Object?> get props => [decision];
}

/// Kullanıcının oy verdiği kararlar yüklendi state'i
class UserVotedDecisionsLoaded extends DecisionState {
  /// Kullanıcının oy verdiği kararlar
  final List<Decision> decisions;
  
  /// Kullanıcı ID'si
  final String userId;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// UserVotedDecisionsLoaded constructor'ı
  const UserVotedDecisionsLoaded({
    required this.decisions,
    required this.userId,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, userId, hasMore];
}

/// Popüler kararlar yüklendi state'i
class PopularDecisionsLoaded extends DecisionState {
  /// Popüler kararlar
  final List<Decision> decisions;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// PopularDecisionsLoaded constructor'ı
  const PopularDecisionsLoaded({
    required this.decisions,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, hasMore];
}

/// Yakındaki kararlar yüklendi state'i
class NearbyDecisionsLoaded extends DecisionState {
  /// Yakındaki kararlar
  final List<Decision> decisions;
  
  /// Enlem
  final double latitude;
  
  /// Boylam
  final double longitude;
  
  /// Yarıçap (km)
  final double radiusInKm;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// NearbyDecisionsLoaded constructor'ı
  const NearbyDecisionsLoaded({
    required this.decisions,
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [
    decisions,
    latitude,
    longitude,
    radiusInKm,
    hasMore,
  ];
}

/// Arama sonuçları yüklendi state'i
class SearchResultsLoaded extends DecisionState {
  /// Arama sonuçları
  final List<Decision> decisions;
  
  /// Arama sorgusu
  final String query;
  
  /// Daha fazla veri var mı?
  final bool hasMore;
  
  /// SearchResultsLoaded constructor'ı
  const SearchResultsLoaded({
    required this.decisions,
    required this.query,
    this.hasMore = false,
  });
  
  @override
  List<Object?> get props => [decisions, query, hasMore];
}

/// Hata state'i
class DecisionError extends DecisionState {
  /// Hata mesajı
  final String message;
  
  /// Hata kodu
  final String? code;
  
  /// DecisionError constructor'ı
  const DecisionError({
    required this.message,
    this.code,
  });
  
  @override
  List<Object?> get props => [message, code];
}

/// Boş state'i
class DecisionEmpty extends DecisionState {
  /// Boş mesajı
  final String message;
  
  /// DecisionEmpty constructor'ı
  const DecisionEmpty({this.message = 'Henüz karar bulunmuyor'});
  
  @override
  List<Object?> get props => [message];
}

/// Yenileniyor state'i
class DecisionRefreshing extends DecisionState {
  /// Mevcut kararlar
  final List<Decision> currentDecisions;
  
  /// DecisionRefreshing constructor'ı
  const DecisionRefreshing({required this.currentDecisions});
  
  @override
  List<Object?> get props => [currentDecisions];
}

/// Daha fazla yükleniyor state'i
class DecisionLoadingMore extends DecisionState {
  /// Mevcut kararlar
  final List<Decision> currentDecisions;
  
  /// DecisionLoadingMore constructor'ı
  const DecisionLoadingMore({required this.currentDecisions});
  
  @override
  List<Object?> get props => [currentDecisions];
}