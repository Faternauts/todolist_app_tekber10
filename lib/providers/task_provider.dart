import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Task> get allTasks {
    // Update status for all tasks
    for (var task in _tasks) {
      task.updateStatus();
    }
    return _tasks;
  }

  List<Task> get ongoingTasks => allTasks.where((task) => task.status == TaskStatus.ongoing).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
  List<Task> get completedTasks => allTasks.where((task) => task.status == TaskStatus.completed).toList()..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
  List<Task> get missedTasks => allTasks.where((task) => task.status == TaskStatus.missed).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
  
  // Clear all tasks (for logout)
  void clearTasks() {
    _tasks = [];
    notifyListeners();
    print('✅ Tasks cleared');
  }
  
  // Add task
  Future<Task> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Map status enum ke string sesuai Supabase enum
      String statusString;
      switch (task.status) {
        case TaskStatus.ongoing:
          statusString = 'ongoing';
          break;
        case TaskStatus.completed:
          statusString = 'completed';
          break;
        case TaskStatus.missed:
          statusString = 'missed';
          break;
      }

      // Map priority enum ke string sesuai Supabase enum
      String priorityString;
      switch (task.priority) {
        case TaskPriority.low:
          priorityString = 'low';
          break;
        case TaskPriority.medium:
          priorityString = 'medium';
          break;
        case TaskPriority.high:
          priorityString = 'high';
          break;
      }

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final taskData = {
        'user_id': currentUser.id,
        'title': task.title,
        'description': task.description,
        'start_date': task.startDate?.toIso8601String().split('T')[0], // format date only
        'due_date': task.deadline.toIso8601String().split('T')[0], // format date only
        'status': statusString,
        'priority': priorityString,
        'duration_minutes': 30, // default 30 menit
        'steps': task.steps ?? [],
      };

      final response = await supabase.from('notes').insert(taskData).select().single();

      // Update task id dengan uuid dari Supabase
      final newTask = Task(
        id: response['id'],
        title: task.title,
        description: task.description,
        startDate: task.startDate,
        deadline: task.deadline,
        status: task.status,
        priority: task.priority,
        createdAt: DateTime.parse(response['created_at']),
        completedAt: task.completedAt,
        steps: task.steps,
      );

      _tasks.add(newTask);
      _isLoading = false;
      notifyListeners();
      
      return newTask;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error adding task: $e');
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(String id, Task updatedTask) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Map status enum ke string
      String statusString;
      switch (updatedTask.status) {
        case TaskStatus.ongoing:
          statusString = 'ongoing';
          break;
        case TaskStatus.completed:
          statusString = 'completed';
          break;
        case TaskStatus.missed:
          statusString = 'missed';
          break;
      }

      // Map priority enum ke string
      String priorityString;
      switch (updatedTask.priority) {
        case TaskPriority.low:
          priorityString = 'low';
          break;
        case TaskPriority.medium:
          priorityString = 'medium';
          break;
        case TaskPriority.high:
          priorityString = 'high';
          break;
      }

      final taskData = {
        'title': updatedTask.title,
        'description': updatedTask.description,
        'start_date': updatedTask.startDate?.toIso8601String().split('T')[0],
        'due_date': updatedTask.deadline.toIso8601String().split('T')[0],
        'status': statusString,
        'priority': priorityString,
        'steps': updatedTask.steps ?? [],
      };

      await supabase.from('notes').update(taskData).eq('id', id);

      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating task: $e');
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabase.from('notes').delete().eq('id', id);
      _tasks.removeWhere((task) => task.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Delete multiple tasks
  Future<void> deleteTasks(List<String> ids) async {
    try {
      _isLoading = true;
      notifyListeners();

      for (final id in ids) {
        await supabase.from('notes').delete().eq('id', id);
      }
      _tasks.removeWhere((task) => ids.contains(task.id));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting tasks: $e');
      rethrow;
    }
  }

  // Mark task as completed
  Future<void> markAsCompleted(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      await supabase.from('notes').update({
        'status': 'completed',
      }).eq('id', id);

      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index].status = TaskStatus.completed;
        _tasks[index].completedAt = now;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error marking task as completed: $e');
      rethrow;
    }
  }

  // Load tasks from Supabase
  Future<void> loadTasks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      print('🔍 DEBUG: Loading tasks for user: ${currentUser.id}');
      print('🔍 DEBUG: User email: ${currentUser.email}');

      final response = await supabase.from('notes').select().eq('user_id', currentUser.id).order('created_at', ascending: false);
      
      print('🔍 DEBUG: Loaded ${(response as List).length} tasks');

      _tasks = (response as List).map((json) {
        // Map string status dari Supabase ke enum
        TaskStatus status;
        switch (json['status']) {
          case 'ongoing':
            status = TaskStatus.ongoing;
            break;
          case 'completed':
            status = TaskStatus.completed;
            break;
          case 'missed':
            status = TaskStatus.missed;
            break;
          default:
            status = TaskStatus.ongoing;
        }

        // Map string priority dari Supabase ke enum
        TaskPriority priority;
        switch (json['priority']) {
          case 'low':
            priority = TaskPriority.low;
            break;
          case 'medium':
            priority = TaskPriority.medium;
            break;
          case 'high':
            priority = TaskPriority.high;
            break;
          default:
            priority = TaskPriority.medium;
        }

        // Parse date dari Supabase (format: YYYY-MM-DD)
        DateTime deadline;
        if (json['due_date'] != null) {
          deadline = DateTime.parse(json['due_date']);
        } else {
          deadline = DateTime.now().add(Duration(days: 1));
        }

        DateTime? startDate;
        if (json['start_date'] != null) {
          startDate = DateTime.parse(json['start_date']);
        }

        return Task(
          id: json['id'],
          title: json['title'],
          description: json['description'] ?? '',
          startDate: startDate,
          deadline: deadline,
          status: status,
          priority: priority,
          createdAt: DateTime.parse(json['created_at']),
          completedAt: null, // notes table tidak punya completed_at
          steps: json['steps'] != null && json['steps'] is List
              ? List<Map<String, dynamic>>.from((json['steps'] as List).map((x) => x is Map ? Map<String, dynamic>.from(x) : {'step': x.toString(), 'estimatedMinutes': 10}))
              : null,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading tasks: $e');
    }
  }

  // Get task by id
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  // Get weekly statistics
  WeeklyStats getWeeklyStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfPreviousWeek = startOfWeek;

    // Initialize counts
    List<int> dailyCounts = List.filled(7, 0);
    int currentWeekTotal = 0;
    int previousWeekTotal = 0;

    for (var task in allTasks) {
// Only count completed tasks
      if (task.status != TaskStatus.completed) continue;

      final createdAt = task.createdAt;
      
      // Check if task is in current week
      if (createdAt.compareTo(startOfWeek) >= 0 && createdAt.isBefore(endOfWeek)) {
        final dayIndex = createdAt.weekday - 1;
        dailyCounts[dayIndex]++;
        currentWeekTotal++;
      }
      
      // Check if task is in previous week
      if (createdAt.compareTo(startOfPreviousWeek) >= 0 && createdAt.isBefore(endOfPreviousWeek)) {
        previousWeekTotal++;
      }
    }

    // Calculate progress
    double progress = 0;
    if (previousWeekTotal > 0) {
      progress = ((currentWeekTotal - previousWeekTotal) / previousWeekTotal) * 100;
    } else if (currentWeekTotal > 0) {
      progress = 100;
    }

    // Find max for scaling
    int maxCount = dailyCounts.reduce((curr, next) => curr > next ? curr : next);
    if (maxCount == 0) maxCount = 1;

    return WeeklyStats(
      dailyCounts: dailyCounts,
      progress: progress,
      maxCount: maxCount,
    );
  }
}

class WeeklyStats {
  final List<int> dailyCounts;
  final double progress;
  final int maxCount;

  WeeklyStats({
    required this.dailyCounts,
    required this.progress,
    required this.maxCount,
  });
}
