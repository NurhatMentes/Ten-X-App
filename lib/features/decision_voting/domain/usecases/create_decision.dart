import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/decision.dart';
import '../repositories/decision_repository.dart';

/// Karar oluşturma use case'i
class CreateDecision {
  /// Decision repository
  final DecisionRepository repository;
  
  /// CreateDecision constructor'ı
  const CreateDecision(this.repository);
  
  /// Karar oluşturma metodu
  Future<Either<Failure, Decision>> call(CreateDecisionParams params) async {
    // Parametreleri doğrula
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(ValidationFailure(validationResult));
    }
    
    // Yeni karar oluştur
    final decision = Decision(
      id: '', // Firestore tarafından otomatik oluşturulacak
      userId: params.userId,
      title: params.title,
      description: params.description,
      category: params.category,
      options: params.options,
      votes: {}, // Başlangıçta boş
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      expiresAt: params.expiresAt,
      status: DecisionStatus.active,
      visibility: params.visibility,
      tags: params.tags,
      imageUrl: params.imageUrl,
      location: params.location,
      minVotes: params.minVotes,
      maxVotes: params.maxVotes,
      allowMultipleVotes: params.allowMultipleVotes,
      isAnonymous: params.isAnonymous,
    );
    
    return await repository.createDecision(decision);
  }
  
  /// Parametreleri doğrulayan metod
  String? _validateParams(CreateDecisionParams params) {
    if (params.title.trim().isEmpty) {
      return 'Karar başlığı boş olamaz';
    }
    
    if (params.title.length > 200) {
      return 'Karar başlığı 200 karakterden uzun olamaz';
    }
    
    if (params.description != null && params.description!.length > 1000) {
      return 'Karar açıklaması 1000 karakterden uzun olamaz';
    }
    
    if (params.options.length < 2) {
      return 'En az 2 seçenek olmalıdır';
    }
    
    if (params.options.length > 10) {
      return 'En fazla 10 seçenek olabilir';
    }
    
    for (final option in params.options) {
      if (option.trim().isEmpty) {
        return 'Seçenekler boş olamaz';
      }
      if (option.length > 100) {
        return 'Seçenekler 100 karakterden uzun olamaz';
      }
    }
    
    // Seçeneklerin benzersiz olup olmadığını kontrol et
    final uniqueOptions = params.options.map((e) => e.trim().toLowerCase()).toSet();
    if (uniqueOptions.length != params.options.length) {
      return 'Seçenekler benzersiz olmalıdır';
    }
    
    if (params.minVotes != null && params.minVotes! < 1) {
      return 'Minimum oy sayısı 1\'den küçük olamaz';
    }
    
    if (params.maxVotes != null && params.maxVotes! < 1) {
      return 'Maksimum oy sayısı 1\'den küçük olamaz';
    }
    
    if (params.minVotes != null && 
        params.maxVotes != null && 
        params.minVotes! > params.maxVotes!) {
      return 'Minimum oy sayısı maksimum oy sayısından büyük olamaz';
    }
    
    if (params.expiresAt != null && params.expiresAt!.isBefore(DateTime.now())) {
      return 'Bitiş tarihi geçmişte olamaz';
    }
    
    if (params.tags != null && params.tags!.length > 10) {
      return 'En fazla 10 etiket eklenebilir';
    }
    
    if (params.tags != null) {
      for (final tag in params.tags!) {
        if (tag.trim().isEmpty) {
          return 'Etiketler boş olamaz';
        }
        if (tag.length > 20) {
          return 'Etiketler 20 karakterden uzun olamaz';
        }
      }
    }
    
    return null;
  }
}

/// Karar oluşturma parametreleri
class CreateDecisionParams extends Equatable {
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
  
  /// Karar bitiş tarihi (opsiyonel)
  final DateTime? expiresAt;
  
  /// Karar görünürlüğü
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
  
  /// CreateDecisionParams constructor'ı
  const CreateDecisionParams({
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.options,
    this.expiresAt,
    required this.visibility,
    this.tags,
    this.imageUrl,
    this.location,
    this.minVotes,
    this.maxVotes,
    this.allowMultipleVotes = false,
    this.isAnonymous = false,
  });
  
  @override
  List<Object?> get props => [
        userId,
        title,
        description,
        category,
        options,
        expiresAt,
        visibility,
        tags,
        imageUrl,
        location,
        minVotes,
        maxVotes,
        allowMultipleVotes,
        isAnonymous,
      ];
}