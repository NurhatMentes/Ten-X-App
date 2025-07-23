import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/decision.dart';

/// Karar model sınıfı
class DecisionModel extends Decision {
  /// DecisionModel constructor'ı
  const DecisionModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.category,
    required super.options,
    required super.votes,
    required super.createdAt,
    required super.updatedAt,
    super.expiresAt,
    required super.status,
    required super.visibility,
    super.tags,
    super.imageUrl,
    super.location,
    super.minVotes,
    super.maxVotes,
    super.allowMultipleVotes = false,
    super.isAnonymous = false,
  });
  
  /// Firestore DocumentSnapshot'dan DecisionModel oluşturan factory metodu
  factory DecisionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Oyları dönüştür (Map<String, List<String>> -> Map<int, List<String>>)
    final votesData = data['votes'] as Map<String, dynamic>? ?? {};
    final Map<int, List<String>> votes = {};
    
    votesData.forEach((key, value) {
      final optionIndex = int.parse(key);
      final votersList = List<String>.from(value as List<dynamic>);
      votes[optionIndex] = votersList;
    });
    
    return DecisionModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      category: data['category'] as String,
      options: List<String>.from(data['options'] as List<dynamic>),
      votes: votes,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      status: DecisionStatusExtension.fromString(data['status'] as String),
      visibility: DecisionVisibilityExtension.fromString(data['visibility'] as String),
      tags: data['tags'] != null 
          ? List<String>.from(data['tags'] as List<dynamic>) 
          : null,
      imageUrl: data['imageUrl'] as String?,
      location: data['location'] as String?,
      minVotes: data['minVotes'] as int?,
      maxVotes: data['maxVotes'] as int?,
      allowMultipleVotes: data['allowMultipleVotes'] as bool? ?? false,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
    );
  }
  
  /// JSON'dan DecisionModel oluşturan factory metodu
  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    // Oyları dönüştür (Map<String, List<String>> -> Map<int, List<String>>)
    final votesData = json['votes'] as Map<String, dynamic>? ?? {};
    final Map<int, List<String>> votes = {};
    
    votesData.forEach((key, value) {
      final optionIndex = int.parse(key);
      final votersList = List<String>.from(value as List<dynamic>);
      votes[optionIndex] = votersList;
    });
    
    return DecisionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      votes: votes,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      status: DecisionStatusExtension.fromString(json['status'] as String),
      visibility: DecisionVisibilityExtension.fromString(json['visibility'] as String),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List<dynamic>) 
          : null,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      minVotes: json['minVotes'] as int?,
      maxVotes: json['maxVotes'] as int?,
      allowMultipleVotes: json['allowMultipleVotes'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }
  
  /// Decision entity'den DecisionModel oluşturan factory metodu
  factory DecisionModel.fromEntity(Decision decision) {
    return DecisionModel(
      id: decision.id,
      userId: decision.userId,
      title: decision.title,
      description: decision.description,
      category: decision.category,
      options: decision.options,
      votes: decision.votes,
      createdAt: decision.createdAt,
      updatedAt: decision.updatedAt,
      expiresAt: decision.expiresAt,
      status: decision.status,
      visibility: decision.visibility,
      tags: decision.tags,
      imageUrl: decision.imageUrl,
      location: decision.location,
      minVotes: decision.minVotes,
      maxVotes: decision.maxVotes,
      allowMultipleVotes: decision.allowMultipleVotes,
      isAnonymous: decision.isAnonymous,
    );
  }
  
  /// Firestore'a kaydetmek için Map oluşturan metod
  Map<String, dynamic> toFirestore() {
    // Oyları dönüştür (Map<int, List<String>> -> Map<String, List<String>>)
    final Map<String, List<String>> votesData = {};
    votes.forEach((key, value) {
      votesData[key.toString()] = value;
    });
    
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'options': options,
      'votes': votesData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'status': status.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'tags': tags,
      'imageUrl': imageUrl,
      'location': location,
      'minVotes': minVotes,
      'maxVotes': maxVotes,
      'allowMultipleVotes': allowMultipleVotes,
      'isAnonymous': isAnonymous,
    };
  }
  
  /// JSON'a dönüştüren metod
  Map<String, dynamic> toJson() {
    // Oyları dönüştür (Map<int, List<String>> -> Map<String, List<String>>)
    final Map<String, List<String>> votesData = {};
    votes.forEach((key, value) {
      votesData[key.toString()] = value;
    });
    
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'options': options,
      'votes': votesData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'visibility': visibility.toString().split('.').last,
      'tags': tags,
      'imageUrl': imageUrl,
      'location': location,
      'minVotes': minVotes,
      'maxVotes': maxVotes,
      'allowMultipleVotes': allowMultipleVotes,
      'isAnonymous': isAnonymous,
    };
  }
  
  /// Entity'e dönüştüren metod
  Decision toEntity() {
    return Decision(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      options: options,
      votes: votes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
      status: status,
      visibility: visibility,
      tags: tags,
      imageUrl: imageUrl,
      location: location,
      minVotes: minVotes,
      maxVotes: maxVotes,
      allowMultipleVotes: allowMultipleVotes,
      isAnonymous: isAnonymous,
    );
  }
  
  /// DecisionModel kopyalama metodu
  @override
  DecisionModel copyWith({
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
    return DecisionModel(
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
}