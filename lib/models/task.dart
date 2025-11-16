import 'package:intl/intl.dart';

enum TaskStatus { ongoing, completed, missed }

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  String category;
  DateTime deadline;
  TaskStatus status;
  TaskPriority priority;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.deadline,
    this.status = TaskStatus.ongoing,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.completedAt,
  });

  // Check if task is missed
  bool get isMissed {
    if (status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(deadline);
  }

  // Auto update status
  void updateStatus() {
    if (status != TaskStatus.completed && isMissed) {
      status = TaskStatus.missed;
    }
  }

  String get formattedDeadline {
    return DateFormat('dd MMM yyyy, HH:mm').format(deadline);
  }

  String get shortDeadline {
    return DateFormat('dd MMM yyyy').format(deadline);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'status': status.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      deadline: DateTime.parse(json['deadline']),
      status: TaskStatus.values[json['status']],
      priority: TaskPriority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? deadline,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
