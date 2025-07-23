enum DecisionStatus {
  pending,
  approved,
  rejected,
  inProgress,
}

enum Priority {
  low,
  medium,
  high,
  urgent,
}

class Decision {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DecisionStatus status;
  final String category;
  final Priority priority;
  final List<String> tags;
  final DateTime? deadline;
  final String? notes;

  Decision({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.category,
    required this.priority,
    this.tags = const [],
    this.deadline,
    this.notes,
  });

  Decision copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DecisionStatus? status,
    String? category,
    Priority? priority,
    List<String>? tags,
    DateTime? deadline,
    String? notes,
  }) {
    return Decision(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'category': category,
      'priority': priority.name,
      'tags': tags,
      'deadline': deadline?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Decision.fromJson(Map<String, dynamic> json) {
    return Decision(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      status: DecisionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      category: json['category'],
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      tags: List<String>.from(json['tags'] ?? []),
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline']) 
          : null,
      notes: json['notes'],
    );
  }
}