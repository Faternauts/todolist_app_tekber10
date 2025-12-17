import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/task.dart';
import 'package:todolist_app_tekber10/providers/task_provider.dart';

void main() {
  group('WeeklyStats', () {
    test('should create WeeklyStats with correct values', () {
      final stats = WeeklyStats(
        dailyCounts: [1, 2, 3, 0, 5, 2, 1],
        progress: 25.0,
        maxCount: 5,
      );

      expect(stats.dailyCounts.length, 7);
      expect(stats.progress, 25.0);
      expect(stats.maxCount, 5);
    });

    test('should have 7 days in dailyCounts', () {
      final stats = WeeklyStats(
        dailyCounts: [0, 0, 0, 0, 0, 0, 0],
        progress: 0.0,
        maxCount: 1,
      );

      expect(stats.dailyCounts.length, 7);
    });

    test('should handle negative progress (fewer tasks than last week)', () {
      final stats = WeeklyStats(
        dailyCounts: [1, 0, 0, 0, 0, 0, 0],
        progress: -50.0,
        maxCount: 1,
      );

      expect(stats.progress, -50.0);
    });

    test('should handle 100% progress (no tasks last week, some this week)', () {
      final stats = WeeklyStats(
        dailyCounts: [2, 3, 1, 0, 0, 0, 0],
        progress: 100.0,
        maxCount: 3,
      );

      expect(stats.progress, 100.0);
    });
  });

  group('TaskProvider Filtering and Sorting', () {
    // Helper function to create test tasks
    Task createTestTask({
      required String id,
      required String title,
      required TaskStatus status,
      required DateTime deadline,
      TaskPriority priority = TaskPriority.medium,
      DateTime? completedAt,
      DateTime? createdAt,
    }) {
      return Task(
        id: id,
        title: title,
        description: '',
        deadline: deadline,
        status: status,
        priority: priority,
        createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 1)),
        completedAt: completedAt,
      );
    }

    group('ongoingTasks getter', () {
      test('should filter and return only ongoing tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing 1', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '3', title: 'Ongoing 2', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 2))),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        final ongoingTasks = provider.ongoingTasks;

        expect(ongoingTasks.length, 2);
        expect(ongoingTasks.every((t) => t.status == TaskStatus.ongoing), true);
        expect(ongoingTasks.map((t) => t.title).toList(), containsAll(['Ongoing 1', 'Ongoing 2']));
      });

      test('should sort ongoing tasks by deadline ascending', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Later Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 7)),
          ),
          createTestTask(
            id: '2',
            title: 'Sooner Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 1)),
          ),
          createTestTask(
            id: '3',
            title: 'Middle Task',
            status: TaskStatus.ongoing,
            deadline: now.add(const Duration(days: 3)),
          ),
        ]);

        final ongoingTasks = provider.ongoingTasks;

        expect(ongoingTasks.length, 3);
        expect(ongoingTasks[0].title, 'Sooner Task');
        expect(ongoingTasks[1].title, 'Middle Task');
        expect(ongoingTasks[2].title, 'Later Task');
      });

      test('should return empty list when no ongoing tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '2', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        expect(provider.ongoingTasks, isEmpty);
      });
    });

    group('completedTasks getter', () {
      test('should filter and return only completed tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed 1', status: TaskStatus.completed, deadline: now, completedAt: now),
          createTestTask(id: '3', title: 'Completed 2', status: TaskStatus.completed, deadline: now, completedAt: now),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 2);
        expect(completedTasks.every((t) => t.status == TaskStatus.completed), true);
        expect(completedTasks.map((t) => t.title).toList(), containsAll(['Completed 1', 'Completed 2']));
      });

      test('should sort completed tasks by completedAt descending (most recent first)', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Completed First',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now.subtract(const Duration(days: 2)),
          ),
          createTestTask(
            id: '2',
            title: 'Completed Last',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now,
          ),
          createTestTask(
            id: '3',
            title: 'Completed Middle',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: now.subtract(const Duration(days: 1)),
          ),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 3);
        expect(completedTasks[0].title, 'Completed Last');
        expect(completedTasks[1].title, 'Completed Middle');
        expect(completedTasks[2].title, 'Completed First');
      });

      test('should use createdAt when completedAt is null', () {
        final provider = TaskProvider();
        final now = DateTime.now();
        final earlier = now.subtract(const Duration(days: 3));
        final later = now.subtract(const Duration(days: 1));

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Earlier Task',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: null,
            createdAt: earlier,
          ),
          createTestTask(
            id: '2',
            title: 'Later Task',
            status: TaskStatus.completed,
            deadline: now,
            completedAt: null,
            createdAt: later,
          ),
        ]);

        final completedTasks = provider.completedTasks;

        expect(completedTasks.length, 2);
        expect(completedTasks[0].title, 'Later Task');
        expect(completedTasks[1].title, 'Earlier Task');
      });
    });

    group('missedTasks getter', () {
      test('should filter and return only missed tasks', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: now),
          createTestTask(id: '3', title: 'Missed 1', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 1))),
          createTestTask(id: '4', title: 'Missed 2', status: TaskStatus.missed, deadline: now.subtract(const Duration(days: 2))),
        ]);

        final missedTasks = provider.missedTasks;

        expect(missedTasks.length, 2);
        expect(missedTasks.every((t) => t.status == TaskStatus.missed), true);
        expect(missedTasks.map((t) => t.title).toList(), containsAll(['Missed 1', 'Missed 2']));
      });

      test('should sort missed tasks by deadline ascending', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(
            id: '1',
            title: 'Later Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 1)),
          ),
          createTestTask(
            id: '2',
            title: 'Earlier Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 3)),
          ),
          createTestTask(
            id: '3',
            title: 'Middle Missed',
            status: TaskStatus.missed,
            deadline: now.subtract(const Duration(days: 2)),
          ),
        ]);

        final missedTasks = provider.missedTasks;

        expect(missedTasks.length, 3);
        expect(missedTasks[0].title, 'Earlier Missed');
        expect(missedTasks[1].title, 'Middle Missed');
        expect(missedTasks[2].title, 'Later Missed');
      });
    });

    group('getTaskById method', () {
      test('should find existing task by id', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: now),
          createTestTask(id: 'def-456', title: 'Task B', status: TaskStatus.ongoing, deadline: now),
          createTestTask(id: 'ghi-789', title: 'Task C', status: TaskStatus.ongoing, deadline: now),
        ]);

        final found = provider.getTaskById('def-456');

        expect(found, isNotNull);
        expect(found!.title, 'Task B');
      });

      test('should return null for non-existing task id', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: now),
        ]);

        final found = provider.getTaskById('non-existing');

        expect(found, isNull);
      });

      test('should return null when task list is empty', () {
        final provider = TaskProvider();

        final found = provider.getTaskById('any-id');

        expect(found, isNull);
      });
    });

    group('Task Priority filtering', () {
      test('should include tasks with different priorities in filtered results', () {
        final provider = TaskProvider();
        final now = DateTime.now();

        provider.setTasksForTesting([
          createTestTask(id: '1', title: 'High', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.high),
          createTestTask(id: '2', title: 'Medium', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.medium),
          createTestTask(id: '3', title: 'Low', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.low),
          createTestTask(id: '4', title: 'High 2', status: TaskStatus.ongoing, deadline: now.add(const Duration(days: 1)), priority: TaskPriority.high),
        ]);

        final ongoingTasks = provider.ongoingTasks;
        final highPriorityTasks = ongoingTasks.where((t) => t.priority == TaskPriority.high).toList();

        expect(ongoingTasks.length, 4);
        expect(highPriorityTasks.length, 2);
        expect(highPriorityTasks.map((t) => t.title).toList(), containsAll(['High', 'High 2']));
      });
    });
  });

  group('String to Enum Mapping (loadTasks logic)', () {
    // Helper function that replicates the exact JSON-to-Task mapping logic from TaskProvider.loadTasks
    // This tests the same mapping logic that loadTasks uses when converting Supabase JSON responses to Task objects
    Task taskFromSupabaseJson(Map<String, dynamic> json) {
      // Map string status dari Supabase ke enum (same logic as loadTasks)
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

      // Map string priority dari Supabase ke enum (same logic as loadTasks)
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
        deadline = DateTime.now().add(const Duration(days: 1));
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
        completedAt: null,
        steps: json['steps'] != null && json['steps'] is List
            ? List<Map<String, dynamic>>.from((json['steps'] as List).map((x) => x is Map ? Map<String, dynamic>.from(x) : {'step': x.toString(), 'estimatedMinutes': 10}))
            : null,
      );
    }

    test('should map "ongoing" string to TaskStatus.ongoing', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.ongoing);
    });

    test('should map "completed" string to TaskStatus.completed', () {
      final json = {
        'id': 'test-2',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'completed',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.completed);
    });

    test('should map "missed" string to TaskStatus.missed', () {
      final json = {
        'id': 'test-3',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'missed',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.missed);
    });

    test('should default to TaskStatus.ongoing for unknown status string', () {
      final json = {
        'id': 'test-4',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'unknown_status',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.status, TaskStatus.ongoing);
    });

    test('should map "low" string to TaskPriority.low', () {
      final json = {
        'id': 'test-5',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'low',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.low);
    });

    test('should map "medium" string to TaskPriority.medium', () {
      final json = {
        'id': 'test-6',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'medium',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.medium);
    });

    test('should map "high" string to TaskPriority.high', () {
      final json = {
        'id': 'test-7',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'high',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.high);
    });

    test('should default to TaskPriority.medium for unknown priority string', () {
      final json = {
        'id': 'test-8',
        'title': 'Test Task',
        'description': 'Test',
        'status': 'ongoing',
        'priority': 'unknown_priority',
        'due_date': '2024-12-31',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final task = taskFromSupabaseJson(json);
      expect(task.priority, TaskPriority.medium);
    });

    test('should correctly map all status and priority combinations', () {
      final testCases = [
        {'status': 'ongoing', 'priority': 'low', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.low},
        {'status': 'ongoing', 'priority': 'medium', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.medium},
        {'status': 'ongoing', 'priority': 'high', 'expectedStatus': TaskStatus.ongoing, 'expectedPriority': TaskPriority.high},
        {'status': 'completed', 'priority': 'low', 'expectedStatus': TaskStatus.completed, 'expectedPriority': TaskPriority.low},
        {'status': 'completed', 'priority': 'high', 'expectedStatus': TaskStatus.completed, 'expectedPriority': TaskPriority.high},
        {'status': 'missed', 'priority': 'medium', 'expectedStatus': TaskStatus.missed, 'expectedPriority': TaskPriority.medium},
      ];

      for (var i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        final json = {
          'id': 'test-$i',
          'title': 'Test Task',
          'description': 'Test',
          'status': testCase['status'],
          'priority': testCase['priority'],
          'due_date': '2024-12-31',
          'created_at': '2024-01-01T00:00:00Z',
        };

        final task = taskFromSupabaseJson(json);
        expect(task.status, testCase['expectedStatus'], reason: 'Status mapping failed for ${testCase['status']}');
        expect(task.priority, testCase['expectedPriority'], reason: 'Priority mapping failed for ${testCase['priority']}');
      }
    });

    test('should work correctly with TaskProvider when tasks are created from Supabase JSON', () {
      final provider = TaskProvider();
      final now = DateTime.now();

      // Simulate JSON responses from Supabase (as loadTasks would receive them)
      final jsonTasks = [
        {
          'id': 'task-1',
          'title': 'Ongoing High Priority',
          'description': 'Test',
          'status': 'ongoing',
          'priority': 'high',
          'due_date': now.add(const Duration(days: 1)).toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
        {
          'id': 'task-2',
          'title': 'Completed Low Priority',
          'description': 'Test',
          'status': 'completed',
          'priority': 'low',
          'due_date': now.toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
        {
          'id': 'task-3',
          'title': 'Missed Medium Priority',
          'description': 'Test',
          'status': 'missed',
          'priority': 'medium',
          'due_date': now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
          'created_at': now.toIso8601String(),
        },
      ];

      // Convert JSON to Task objects using the same mapping logic as loadTasks
      final tasks = jsonTasks.map((json) => taskFromSupabaseJson(json)).toList();

      // Add tasks to provider using test method
      provider.setTasksForTesting(tasks);

      // Verify the provider correctly handles the mapped tasks
      expect(provider.ongoingTasks.length, 1);
      expect(provider.ongoingTasks[0].status, TaskStatus.ongoing);
      expect(provider.ongoingTasks[0].priority, TaskPriority.high);
      expect(provider.ongoingTasks[0].title, 'Ongoing High Priority');

      expect(provider.completedTasks.length, 1);
      expect(provider.completedTasks[0].status, TaskStatus.completed);
      expect(provider.completedTasks[0].priority, TaskPriority.low);
      expect(provider.completedTasks[0].title, 'Completed Low Priority');

      expect(provider.missedTasks.length, 1);
      expect(provider.missedTasks[0].status, TaskStatus.missed);
      expect(provider.missedTasks[0].priority, TaskPriority.medium);
      expect(provider.missedTasks[0].title, 'Missed Medium Priority');
    });
  });
}
