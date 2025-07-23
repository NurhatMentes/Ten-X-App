import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/decision.dart';
import '../models/decision_model.dart';

/// Karar remote data source interface'i
abstract class DecisionRemoteDataSource {
  /// Yeni karar oluşturma
  Future<DecisionModel> createDecision(DecisionModel decision);
  
  /// Karar güncelleme
  Future<DecisionModel> updateDecision(DecisionModel decision);
  
  /// Karar silme
  Future<bool> deleteDecision(String decisionId);
  
  /// ID'ye göre karar getirme
  Future<DecisionModel> getDecisionById(String decisionId);
  
  /// Kullanıcının kararlarını getirme
  Future<List<DecisionModel>> getUserDecisions(String userId);
  
  /// Herkese açık kararları getirme
  Future<List<DecisionModel>> getPublicDecisions({
    int limit = 10,
    String? lastDecisionId,
    String? category,
  });
  
  /// Arkadaşların kararlarını getirme
  Future<List<DecisionModel>> getFriendsDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Kategoriye göre kararları getirme
  Future<List<DecisionModel>> getDecisionsByCategory({
    required String category,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Etiketlere göre kararları getirme
  Future<List<DecisionModel>> getDecisionsByTags({
    required List<String> tags,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Karara oy verme
  Future<DecisionModel> voteDecision({
    required String decisionId,
    required String userId,
    required int optionIndex,
  });
  
  /// Karardan oy kaldırma
  Future<DecisionModel> removeVote({
    required String decisionId,
    required String userId,
    required int optionIndex,
  });
  
  /// Karar durumunu güncelleme
  Future<DecisionModel> updateDecisionStatus({
    required String decisionId,
    required DecisionStatus status,
  });
  
  /// Kullanıcının oy verdiği kararları getirme
  Future<List<DecisionModel>> getUserVotedDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Popüler kararları getirme
  Future<List<DecisionModel>> getPopularDecisions({
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Yakındaki kararları getirme
  Future<List<DecisionModel>> getNearbyDecisions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 10,
    String? lastDecisionId,
  });
  
  /// Kararları arama
  Future<List<DecisionModel>> searchDecisions({
    required String query,
    int limit = 10,
    String? lastDecisionId,
  });
}

/// Firestore implementasyonu
class DecisionRemoteDataSourceImpl implements DecisionRemoteDataSource {
  /// Firestore instance
  final FirebaseFirestore firestore;
  
  /// DecisionRemoteDataSourceImpl constructor'ı
  DecisionRemoteDataSourceImpl({required this.firestore});
  
  /// Kararlar koleksiyonu referansı
  CollectionReference get _decisionsCollection => 
      firestore.collection(AppConstants.decisionsCollection);
  
  @override
  Future<DecisionModel> createDecision(DecisionModel decision) async {
    try {
      // Yeni döküman oluştur
      final docRef = _decisionsCollection.doc();
      
      // ID'yi güncelle
      final updatedDecision = decision.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Firestore'a kaydet
      await docRef.set(updatedDecision.toFirestore());
      
      return updatedDecision;
    } catch (e) {
      throw FirestoreFailure('Karar oluşturulurken hata: $e');
    }
  }
  
  @override
  Future<DecisionModel> updateDecision(DecisionModel decision) async {
    try {
      // Güncellenme zamanını güncelle
      final updatedDecision = decision.copyWith(updatedAt: DateTime.now());
      
      // Firestore'da güncelle
      await _decisionsCollection
          .doc(decision.id)
          .update(updatedDecision.toFirestore());
      
      return updatedDecision;
    } catch (e) {
      throw FirestoreFailure('Karar güncellenirken hata: $e');
    }
  }
  
  @override
  Future<bool> deleteDecision(String decisionId) async {
    try {
      await _decisionsCollection.doc(decisionId).delete();
      return true;
    } catch (e) {
      throw FirestoreFailure('Karar silinirken hata: $e');
    }
  }
  
  @override
  Future<DecisionModel> getDecisionById(String decisionId) async {
    try {
      final docSnapshot = await _decisionsCollection.doc(decisionId).get();
      
      if (!docSnapshot.exists) {
        throw FirestoreFailure('Karar bulunamadı: $decisionId');
      }
      
      return DecisionModel.fromFirestore(docSnapshot);
    } catch (e) {
      throw FirestoreFailure('Karar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getUserDecisions(String userId) async {
    try {
      final querySnapshot = await _decisionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Kullanıcı kararları getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getPublicDecisions({
    int limit = 10,
    String? lastDecisionId,
    String? category,
  }) async {
    try {
      Query query = _decisionsCollection
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      return querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Herkese açık kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getFriendsDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Kullanıcının arkadaşlarını getir
      // Not: Gerçek uygulamada arkadaşlık sistemi implementasyonuna göre değişir
      final friendsCollection = firestore.collection(AppConstants.firestoreFriendsCollection);
      final friendsSnapshot = await friendsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();
      
      final friendIds = friendsSnapshot.docs
          .map((doc) => doc.get('friendId') as String)
          .toList();
      
      if (friendIds.isEmpty) {
        return [];
      }
      
      // Arkadaşların kararlarını getir
      Query query = _decisionsCollection
          .where('userId', whereIn: friendIds)
          .where('visibility', whereIn: ['public', 'friends'])
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      return querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Arkadaşların kararları getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getDecisionsByCategory({
    required String category,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      Query query = _decisionsCollection
          .where('category', isEqualTo: category)
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      return querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Kategoriye göre kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getDecisionsByTags({
    required List<String> tags,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Not: Firestore'da array-contains-any en fazla 10 değer alabilir
      final limitedTags = tags.take(10).toList();
      
      Query query = _decisionsCollection
          .where('tags', arrayContainsAny: limitedTags)
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      return querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreFailure('Etiketlere göre kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<DecisionModel> voteDecision({
    required String decisionId,
    required String userId,
    required int optionIndex,
  }) async {
    try {
      // Transaction kullanarak atomik işlem yap
      return await firestore.runTransaction<DecisionModel>((transaction) async {
        // Kararı getir
        final docRef = _decisionsCollection.doc(decisionId);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw FirestoreFailure('Karar bulunamadı: $decisionId');
        }
        
        final decision = DecisionModel.fromFirestore(docSnapshot);
        
        // Oy ekle
        final votes = Map<int, List<String>>.from(decision.votes);
        if (votes[optionIndex] == null) {
          votes[optionIndex] = [];
        }
        
        if (!votes[optionIndex]!.contains(userId)) {
          votes[optionIndex]!.add(userId);
        }
        
        // Güncelle
        final updatedDecision = decision.copyWith(
          votes: votes,
          updatedAt: DateTime.now(),
        );
        
        transaction.update(docRef, {
          'votes.$optionIndex': FieldValue.arrayUnion([userId]),
          'updatedAt': Timestamp.fromDate(updatedDecision.updatedAt),
        });
        
        return updatedDecision;
      });
    } catch (e) {
      throw FirestoreFailure('Oy verilirken hata: $e');
    }
  }
  
  @override
  Future<DecisionModel> removeVote({
    required String decisionId,
    required String userId,
    required int optionIndex,
  }) async {
    try {
      // Transaction kullanarak atomik işlem yap
      return await firestore.runTransaction<DecisionModel>((transaction) async {
        // Kararı getir
        final docRef = _decisionsCollection.doc(decisionId);
        final docSnapshot = await transaction.get(docRef);
        
        if (!docSnapshot.exists) {
          throw FirestoreFailure('Karar bulunamadı: $decisionId');
        }
        
        final decision = DecisionModel.fromFirestore(docSnapshot);
        
        // Oy kaldır
        final votes = Map<int, List<String>>.from(decision.votes);
        if (votes[optionIndex] != null && votes[optionIndex]!.contains(userId)) {
          votes[optionIndex]!.remove(userId);
          
          // Eğer liste boş kaldıysa, key'i kaldır
          if (votes[optionIndex]!.isEmpty) {
            votes.remove(optionIndex);
          }
        }
        
        // Güncelle
        final updatedDecision = decision.copyWith(
          votes: votes,
          updatedAt: DateTime.now(),
        );
        
        transaction.update(docRef, {
          'votes.$optionIndex': FieldValue.arrayRemove([userId]),
          'updatedAt': Timestamp.fromDate(updatedDecision.updatedAt),
        });
        
        return updatedDecision;
      });
    } catch (e) {
      throw FirestoreFailure('Oy kaldırılırken hata: $e');
    }
  }
  
  @override
  Future<DecisionModel> updateDecisionStatus({
    required String decisionId,
    required DecisionStatus status,
  }) async {
    try {
      // Kararı getir
      final docRef = _decisionsCollection.doc(decisionId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw FirestoreFailure('Karar bulunamadı: $decisionId');
      }
      
      final decision = DecisionModel.fromFirestore(docSnapshot);
      
      // Durumu güncelle
      final updatedDecision = decision.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      
      // Firestore'da güncelle
      await docRef.update({
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(updatedDecision.updatedAt),
      });
      
      return updatedDecision;
    } catch (e) {
      throw FirestoreFailure('Karar durumu güncellenirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getUserVotedDecisions({
    required String userId,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Not: Firestore'da doğrudan votes içinde userId'yi arayamayız
      // Tüm aktif ve herkese açık kararları getirip, client-side filtreleme yapacağız
      Query query = _decisionsCollection
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      // Daha fazla veri getir, çünkü filtreleme yapacağız
      final querySnapshot = await query.limit(limit * 3).get();
      
      // Kullanıcının oy verdiği kararları filtrele
      final decisions = querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .where((decision) => decision.hasUserVoted(userId))
          .take(limit)
          .toList();
      
      return decisions;
    } catch (e) {
      throw FirestoreFailure('Kullanıcının oy verdiği kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getPopularDecisions({
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Not: Firestore'da doğrudan oy sayısına göre sıralama yapamayız
      // Tüm aktif ve herkese açık kararları getirip, client-side sıralama yapacağız
      Query query = _decisionsCollection
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      // Daha fazla veri getir, çünkü sıralama yapacağız
      final querySnapshot = await query.limit(limit * 3).get();
      
      // Oy sayısına göre sırala
      final decisions = querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .toList()
          ..sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
      
      return decisions.take(limit).toList();
    } catch (e) {
      throw FirestoreFailure('Popüler kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> getNearbyDecisions({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Not: Basit bir implementasyon, gerçek uygulamada GeoFirestore kullanılabilir
      // Tüm aktif ve herkese açık kararları getirip, client-side filtreleme yapacağız
      Query query = _decisionsCollection
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }
      
      // Daha fazla veri getir, çünkü filtreleme yapacağız
      final querySnapshot = await query.limit(limit * 3).get();
      
      // Konum bilgisi olan kararları filtrele
      // Not: Gerçek uygulamada konum bilgisi lat/lng olarak saklanmalı
      final decisions = querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .where((decision) => decision.location != null)
          .take(limit)
          .toList();
      
      return decisions;
    } catch (e) {
      throw FirestoreFailure('Yakındaki kararlar getirilirken hata: $e');
    }
  }
  
  @override
  Future<List<DecisionModel>> searchDecisions({
    required String query,
    int limit = 10,
    String? lastDecisionId,
  }) async {
    try {
      // Not: Firestore'da tam metin araması yapamayız
      // Tüm aktif ve herkese açık kararları getirip, client-side filtreleme yapacağız
      Query firestoreQuery = _decisionsCollection
          .where('visibility', isEqualTo: 'public')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true);
      
      // Pagination için son döküman
      if (lastDecisionId != null) {
        final lastDocSnapshot = await _decisionsCollection.doc(lastDecisionId).get();
        if (lastDocSnapshot.exists) {
          firestoreQuery = firestoreQuery.startAfterDocument(lastDocSnapshot);
        }
      }
      
      // Daha fazla veri getir, çünkü filtreleme yapacağız
      final querySnapshot = await firestoreQuery.limit(limit * 5).get();
      
      // Başlık, açıklama ve etiketlerde arama yap
      final lowercaseQuery = query.toLowerCase();
      final decisions = querySnapshot.docs
          .map((doc) => DecisionModel.fromFirestore(doc))
          .where((decision) {
            final titleMatch = decision.title.toLowerCase().contains(lowercaseQuery);
            final descriptionMatch = decision.description?.toLowerCase().contains(lowercaseQuery) ?? false;
            final categoryMatch = decision.category.toLowerCase().contains(lowercaseQuery);
            final tagsMatch = decision.tags?.any(
              (tag) => tag.toLowerCase().contains(lowercaseQuery),
            ) ?? false;
            
            return titleMatch || descriptionMatch || categoryMatch || tagsMatch;
          })
          .take(limit)
          .toList();
      
      return decisions;
    } catch (e) {
      throw FirestoreFailure('Kararlar aranırken hata: $e');
    }
  }
}