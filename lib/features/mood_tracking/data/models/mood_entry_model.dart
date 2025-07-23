import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/mood_entry.dart';

/// MoodEntry için Firestore data model'i
class MoodEntryModel extends MoodEntry {
  /// MoodEntryModel constructor'ı
  const MoodEntryModel({
    required super.id,
    required super.userId,
    required super.moodEmoji,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.location,
    super.weather,
    super.activity,
    super.tags,
  });
  
  /// Firestore DocumentSnapshot'tan MoodEntryModel oluşturma
  factory MoodEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MoodEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      moodEmoji: data['moodEmoji'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      location: data['location'],
      weather: data['weather'],
      activity: data['activity'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }
  
  /// JSON'dan MoodEntryModel oluşturma
  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      moodEmoji: json['moodEmoji'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      location: json['location'],
      weather: json['weather'],
      activity: json['activity'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
  
  /// MoodEntry entity'sinden MoodEntryModel oluşturma
  factory MoodEntryModel.fromEntity(MoodEntry entity) {
    return MoodEntryModel(
      id: entity.id,
      userId: entity.userId,
      moodEmoji: entity.moodEmoji,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      location: entity.location,
      weather: entity.weather,
      activity: entity.activity,
      tags: entity.tags,
    );
  }
  
  /// Firestore'a kaydetmek için Map'e çevirme
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'moodEmoji': moodEmoji,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'location': location,
      'weather': weather,
      'activity': activity,
      'tags': tags,
    };
  }
  
  /// JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodEmoji': moodEmoji,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'weather': weather,
      'activity': activity,
      'tags': tags,
    };
  }
  
  /// MoodEntry entity'sine çevirme
  MoodEntry toEntity() {
    return MoodEntry(
      id: id,
      userId: userId,
      moodEmoji: moodEmoji,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: location,
      weather: weather,
      activity: activity,
      tags: tags,
    );
  }
  
  /// Kopyalama metodu
  @override
  MoodEntryModel copyWith({
    String? id,
    String? userId,
    String? moodEmoji,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    String? weather,
    String? activity,
    List<String>? tags,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      weather: weather ?? this.weather,
      activity: activity ?? this.activity,
      tags: tags ?? this.tags,
    );
  }
}