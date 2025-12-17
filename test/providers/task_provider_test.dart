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
