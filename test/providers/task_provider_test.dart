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

  group('Task Filtering Logic', () {
    // Helper function to create test tasks
    Task createTestTask({
      required String id,
      required String title,
      required TaskStatus status,
      required DateTime deadline,
      TaskPriority priority = TaskPriority.medium,
      DateTime? completedAt,
    }) {
      return Task(
        id: id,
        title: title,
        description: '',
        deadline: deadline,
        status: status,
        priority: priority,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: completedAt,
      );
    }

    group('Task Status', () {
      test('ongoing task should have ongoing status', () {
        final task = createTestTask(
          id: '1',
          title: 'Ongoing Task',
          status: TaskStatus.ongoing,
          deadline: DateTime.now().add(const Duration(days: 7)),
        );

        expect(task.status, TaskStatus.ongoing);
      });

      test('completed task should have completed status', () {
        final task = createTestTask(
          id: '2',
          title: 'Completed Task',
          status: TaskStatus.completed,
          deadline: DateTime.now().add(const Duration(days: 7)),
          completedAt: DateTime.now(),
        );

        expect(task.status, TaskStatus.completed);
      });

      test('missed task should have missed status', () {
        final task = createTestTask(
          id: '3',
          title: 'Missed Task',
          status: TaskStatus.missed,
          deadline: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(task.status, TaskStatus.missed);
      });
    });

    group('Task Sorting', () {
      test('ongoing tasks should be sortable by deadline', () {
        final tasks = [
          createTestTask(
            id: '1',
            title: 'Later Task',
            status: TaskStatus.ongoing,
            deadline: DateTime.now().add(const Duration(days: 7)),
          ),
          createTestTask(
            id: '2',
            title: 'Sooner Task',
            status: TaskStatus.ongoing,
            deadline: DateTime.now().add(const Duration(days: 1)),
          ),
          createTestTask(
            id: '3',
            title: 'Middle Task',
            status: TaskStatus.ongoing,
            deadline: DateTime.now().add(const Duration(days: 3)),
          ),
        ];

        // Sort by deadline ascending (soonest first)
        tasks.sort((a, b) => a.deadline.compareTo(b.deadline));

        expect(tasks[0].title, 'Sooner Task');
        expect(tasks[1].title, 'Middle Task');
        expect(tasks[2].title, 'Later Task');
      });

      test('completed tasks should be sortable by completedAt', () {
        final now = DateTime.now();
        final tasks = [
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
        ];

        // Sort by completedAt descending (most recent first)
        tasks.sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));

        expect(tasks[0].title, 'Completed Last');
        expect(tasks[1].title, 'Completed Middle');
        expect(tasks[2].title, 'Completed First');
      });
    });

    group('Task Filtering', () {
      test('should filter ongoing tasks correctly', () {
        final tasks = [
          createTestTask(id: '1', title: 'Ongoing 1', status: TaskStatus.ongoing, deadline: DateTime.now().add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: DateTime.now()),
          createTestTask(id: '3', title: 'Ongoing 2', status: TaskStatus.ongoing, deadline: DateTime.now().add(const Duration(days: 2))),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: DateTime.now().subtract(const Duration(days: 1))),
        ];

        final ongoingTasks = tasks.where((t) => t.status == TaskStatus.ongoing).toList();

        expect(ongoingTasks.length, 2);
        expect(ongoingTasks.every((t) => t.status == TaskStatus.ongoing), true);
      });

      test('should filter completed tasks correctly', () {
        final tasks = [
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: DateTime.now().add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed 1', status: TaskStatus.completed, deadline: DateTime.now()),
          createTestTask(id: '3', title: 'Completed 2', status: TaskStatus.completed, deadline: DateTime.now()),
          createTestTask(id: '4', title: 'Missed', status: TaskStatus.missed, deadline: DateTime.now().subtract(const Duration(days: 1))),
        ];

        final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

        expect(completedTasks.length, 2);
        expect(completedTasks.every((t) => t.status == TaskStatus.completed), true);
      });

      test('should filter missed tasks correctly', () {
        final tasks = [
          createTestTask(id: '1', title: 'Ongoing', status: TaskStatus.ongoing, deadline: DateTime.now().add(const Duration(days: 1))),
          createTestTask(id: '2', title: 'Completed', status: TaskStatus.completed, deadline: DateTime.now()),
          createTestTask(id: '3', title: 'Missed 1', status: TaskStatus.missed, deadline: DateTime.now().subtract(const Duration(days: 1))),
          createTestTask(id: '4', title: 'Missed 2', status: TaskStatus.missed, deadline: DateTime.now().subtract(const Duration(days: 2))),
        ];

        final missedTasks = tasks.where((t) => t.status == TaskStatus.missed).toList();

        expect(missedTasks.length, 2);
        expect(missedTasks.every((t) => t.status == TaskStatus.missed), true);
      });
    });

    group('Task Priority', () {
      test('should correctly identify high priority tasks', () {
        final task = createTestTask(
          id: '1',
          title: 'High Priority',
          status: TaskStatus.ongoing,
          deadline: DateTime.now().add(const Duration(days: 1)),
          priority: TaskPriority.high,
        );

        expect(task.priority, TaskPriority.high);
      });

      test('should correctly identify medium priority tasks', () {
        final task = createTestTask(
          id: '2',
          title: 'Medium Priority',
          status: TaskStatus.ongoing,
          deadline: DateTime.now().add(const Duration(days: 1)),
          priority: TaskPriority.medium,
        );

        expect(task.priority, TaskPriority.medium);
      });

      test('should correctly identify low priority tasks', () {
        final task = createTestTask(
          id: '3',
          title: 'Low Priority',
          status: TaskStatus.ongoing,
          deadline: DateTime.now().add(const Duration(days: 1)),
          priority: TaskPriority.low,
        );

        expect(task.priority, TaskPriority.low);
      });

      test('should filter tasks by priority', () {
        final tasks = [
          createTestTask(id: '1', title: 'High', status: TaskStatus.ongoing, deadline: DateTime.now(), priority: TaskPriority.high),
          createTestTask(id: '2', title: 'Medium', status: TaskStatus.ongoing, deadline: DateTime.now(), priority: TaskPriority.medium),
          createTestTask(id: '3', title: 'Low', status: TaskStatus.ongoing, deadline: DateTime.now(), priority: TaskPriority.low),
          createTestTask(id: '4', title: 'High 2', status: TaskStatus.ongoing, deadline: DateTime.now(), priority: TaskPriority.high),
        ];

        final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.high).toList();

        expect(highPriorityTasks.length, 2);
      });
    });

    group('Find Task by ID', () {
      test('should find existing task by id', () {
        final tasks = [
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: DateTime.now()),
          createTestTask(id: 'def-456', title: 'Task B', status: TaskStatus.ongoing, deadline: DateTime.now()),
          createTestTask(id: 'ghi-789', title: 'Task C', status: TaskStatus.ongoing, deadline: DateTime.now()),
        ];

        final found = tasks.firstWhere(
          (t) => t.id == 'def-456',
          orElse: () => throw Exception('Not found'),
        );

        expect(found.title, 'Task B');
      });

      test('should return null for non-existing task id', () {
        final tasks = [
          createTestTask(id: 'abc-123', title: 'Task A', status: TaskStatus.ongoing, deadline: DateTime.now()),
        ];

        Task? found;
        try {
          found = tasks.firstWhere((t) => t.id == 'non-existing');
        } catch (e) {
          found = null;
        }

        expect(found, isNull);
      });
    });
  });

  group('Status String Mapping', () {
    test('should map ongoing status to string correctly', () {
      String statusToString(TaskStatus status) {
        switch (status) {
          case TaskStatus.ongoing:
            return 'ongoing';
          case TaskStatus.completed:
            return 'completed';
          case TaskStatus.missed:
            return 'missed';
        }
      }

      expect(statusToString(TaskStatus.ongoing), 'ongoing');
      expect(statusToString(TaskStatus.completed), 'completed');
      expect(statusToString(TaskStatus.missed), 'missed');
    });

    test('should map string to status correctly', () {
      TaskStatus stringToStatus(String status) {
        switch (status) {
          case 'ongoing':
            return TaskStatus.ongoing;
          case 'completed':
            return TaskStatus.completed;
          case 'missed':
            return TaskStatus.missed;
          default:
            return TaskStatus.ongoing;
        }
      }

      expect(stringToStatus('ongoing'), TaskStatus.ongoing);
      expect(stringToStatus('completed'), TaskStatus.completed);
      expect(stringToStatus('missed'), TaskStatus.missed);
      expect(stringToStatus('unknown'), TaskStatus.ongoing); // Default
    });
  });

  group('Priority String Mapping', () {
    test('should map priority to string correctly', () {
      String priorityToString(TaskPriority priority) {
        switch (priority) {
          case TaskPriority.low:
            return 'low';
          case TaskPriority.medium:
            return 'medium';
          case TaskPriority.high:
            return 'high';
        }
      }

      expect(priorityToString(TaskPriority.low), 'low');
      expect(priorityToString(TaskPriority.medium), 'medium');
      expect(priorityToString(TaskPriority.high), 'high');
    });

    test('should map string to priority correctly', () {
      TaskPriority stringToPriority(String priority) {
        switch (priority) {
          case 'low':
            return TaskPriority.low;
          case 'medium':
            return TaskPriority.medium;
          case 'high':
            return TaskPriority.high;
          default:
            return TaskPriority.medium;
        }
      }

      expect(stringToPriority('low'), TaskPriority.low);
      expect(stringToPriority('medium'), TaskPriority.medium);
      expect(stringToPriority('high'), TaskPriority.high);
      expect(stringToPriority('unknown'), TaskPriority.medium); // Default
    });
  });
}

