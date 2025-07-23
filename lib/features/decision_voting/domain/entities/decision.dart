import 'package:equatable/equatable.dart';

/// Karar entity'si
class Decision extends Equatable {
  /// Karar ID'si
  final String id;
  
  /// Karar oluşturan kullanıcı ID'si
  final String userId;
  
  /// Karar başlığı
  final String title;
  
  /// Karar açıklaması
  final String? description;
  
  /// Karar kategorisi
  final String category;
  
  /// Karar seçenekleri
  final List<String> options;
  
  /// Oylar (seçenek index'i -> oy veren kullanıcı ID'leri)
  final Map<int, List<String>> votes;
  
  /// Karar oluşturulma tarihi
  final DateTime createdAt;
  
  /// Karar güncellenme tarihi
  final DateTime updatedAt;
  
  /// Karar bitiş tarihi (opsiyonel)
  final DateTime? expiresAt;
  
  /// Karar durumu (aktif, tamamlandı, iptal edildi)
  final DecisionStatus status;
  
  /// Karar görünürlüğü (herkese açık, sadece arkadaşlar, özel)
  final DecisionVisibility visibility;
  
  /// Karar etiketleri
  final List<String>? tags;
  
  /// Karar resmi URL'si (opsiyonel)
  final String? imageUrl;
  
  /// Karar konumu (opsiyonel)
  final String? location;
  
  /// Minimum oy sayısı (opsiyonel)
  final int? minVotes;
  
  /// Maksimum oy sayısı (opsiyonel)
  final int? maxVotes;
  
  /// Çoklu seçim yapılabilir mi?
  final bool allowMultipleVotes;
  
  /// Anonim oylama mı?
  final bool isAnonymous;
  
  /// Decision constructor'ı
  const Decision({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.options,
    required this.votes,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.status,
    required this.visibility,
    this.tags,
    this.imageUrl,
    this.location,
    this.minVotes,
    this.maxVotes,
    this.allowMultipleVotes = false,
    this.isAnonymous = false,
  });
  
  /// Toplam oy sayısını döndüren getter
  int get totalVotes {
    return votes.values.fold(0, (sum, voters) => sum + voters.length);
  }
  
  /// En çok oy alan seçeneği döndüren getter
  int? get winningOption {
    if (votes.isEmpty) return null;
    
    int maxVotes = 0;
    int? winningIndex;
    
    votes.forEach((index, voters) {
      if (voters.length > maxVotes) {
        maxVotes = voters.length;
        winningIndex = index;
      }
    });
    
    return winningIndex;
  }
  
  /// Belirli bir kullanıcının oyunu döndüren getter
  List<int> getUserVotes(String userId) {
    final userVotes = <int>[];
    votes.forEach((index, voters) {
      if (voters.contains(userId)) {
        userVotes.add(index);
      }
    });
    return userVotes;
  }
  
  /// Kullanıcının oy verip vermediğini kontrol eden getter
  bool hasUserVoted(String userId) {
    return votes.values.any((voters) => voters.contains(userId));
  }
  
  /// Kararın aktif olup olmadığını kontrol eden getter
  bool get isActive {
    if (status != DecisionStatus.active) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxVotes != null && totalVotes >= maxVotes!) return false;
    return true;
  }
  
  /// Kararın süresi dolmuş mu kontrol eden getter
  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }
  
  /// Minimum oy sayısına ulaşılmış mı kontrol eden getter
  bool get hasMinVotes {
    return minVotes == null || totalVotes >= minVotes!;
  }
  
  /// Maksimum oy sayısına ulaşılmış mı kontrol eden getter
  bool get hasMaxVotes {
    return maxVotes != null && totalVotes >= maxVotes!;
  }
  
  /// Seçenek için oy yüzdesini hesaplayan metod
  double getOptionPercentage(int optionIndex) {
    if (totalVotes == 0) return 0.0;
    final optionVotes = votes[optionIndex]?.length ?? 0;
    return (optionVotes / totalVotes) * 100;
  }
  
  /// Seçenek için oy sayısını döndüren metod
  int getOptionVoteCount(int optionIndex) {
    return votes[optionIndex]?.length ?? 0;
  }
  
  /// Decision kopyalama metodu
  Decision copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    List<String>? options,
    Map<int, List<String>>? votes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
    DecisionStatus? status,
    DecisionVisibility? visibility,
    List<String>? tags,
    String? imageUrl,
    String? location,
    int? minVotes,
    int? maxVotes,
    bool? allowMultipleVotes,
    bool? isAnonymous,
  }) {
    return Decision(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      options: options ?? this.options,
      votes: votes ?? this.votes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      minVotes: minVotes ?? this.minVotes,
      maxVotes: maxVotes ?? this.maxVotes,
      allowMultipleVotes: allowMultipleVotes ?? this.allowMultipleVotes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        options,
        votes,
        createdAt,
        updatedAt,
        expiresAt,
        status,
        visibility,
        tags,
        imageUrl,
        location,
        minVotes,
        maxVotes,
        allowMultipleVotes,
        isAnonymous,
      ];
  
  @override
  String toString() {
    return 'Decision(id: $id, title: $title, category: $category, '
        'totalVotes: $totalVotes, status: $status, visibility: $visibility)';
  }
}

/// Karar durumu enum'u
enum DecisionStatus {
  /// Aktif karar
  active,
  
  /// Tamamlanmış karar
  completed,
  
  /// İptal edilmiş karar
  cancelled,
  
  /// Taslak karar
  draft,
}

/// Karar görünürlüğü enum'u
enum DecisionVisibility {
  /// Herkese açık
  public,
  
  /// Sadece arkadaşlar
  friends,
  
  /// Özel (sadece davet edilenler)
  private,
}

/// DecisionStatus extension'ı
extension DecisionStatusExtension on DecisionStatus {
  /// Durumu string'e çeviren getter
  String get displayName {
    switch (this) {
      case DecisionStatus.active:
        return 'Aktif';
      case DecisionStatus.completed:
        return 'Tamamlandı';
      case DecisionStatus.cancelled:
        return 'İptal Edildi';
      case DecisionStatus.draft:
        return 'Taslak';
    }
  }
  
  /// String'den DecisionStatus'a çeviren static metod
  static DecisionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return DecisionStatus.active;
      case 'completed':
        return DecisionStatus.completed;
      case 'cancelled':
        return DecisionStatus.cancelled;
      case 'draft':
        return DecisionStatus.draft;
      default:
        return DecisionStatus.active;
    }
  }
}

/// DecisionVisibility extension'ı
extension DecisionVisibilityExtension on DecisionVisibility {
  /// Görünürlüğü string'e çeviren getter
  String get displayName {
    switch (this) {
      case DecisionVisibility.public:
        return 'Herkese Açık';
      case DecisionVisibility.friends:
        return 'Sadece Arkadaşlar';
      case DecisionVisibility.private:
        return 'Özel';
    }
  }
  
  /// String'den DecisionVisibility'e çeviren static metod
  static DecisionVisibility fromString(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public':
        return DecisionVisibility.public;
      case 'friends':
        return DecisionVisibility.friends;
      case 'private':
        return DecisionVisibility.private;
      default:
        return DecisionVisibility.public;
    }
  }
}