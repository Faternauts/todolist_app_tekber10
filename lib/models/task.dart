import 'package:intl/intl.dart';

enum TaskStatus { ongoing, completed, missed }

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  DateTime? startDate;
  DateTime deadline;
  TaskStatus status;
  TaskPriority priority;
  DateTime createdAt;
  DateTime? completedAt;
  List<String>? steps; // AI-generated task breakdown steps

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.startDate,
    required this.deadline,
    this.status = TaskStatus.ongoing,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.completedAt,
    this.steps,
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
      'startDate': startDate?.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'status': status.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'steps': steps,
    };
  }

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      deadline: DateTime.parse(json['deadline']),
      status: TaskStatus.values[json['status']],
      priority: TaskPriority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      steps: json['steps'] != null
          ? List<String>.from(json['steps'])
          : null,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? completedAt,
    List<String>? steps,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      steps: steps ?? this.steps,
    );
  }
}
