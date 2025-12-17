import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/models/task.dart';

void main() {
  group('Task Model', () {
    late Task sampleTask;
    late DateTime testDeadline;
    late DateTime testCreatedAt;

    setUp(() {
      testDeadline = DateTime(2025, 12, 25, 10, 0);
      testCreatedAt = DateTime(2025, 12, 17, 9, 0);

      sampleTask = Task(
        id: 'test-id-123',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime(2025, 12, 20),
        deadline: testDeadline,
        status: TaskStatus.ongoing,
        priority: TaskPriority.high,
        createdAt: testCreatedAt,
        completedAt: null,
        steps: [
          {'step': 'Step 1', 'estimatedMinutes': 10},
          {'step': 'Step 2', 'estimatedMinutes': 20},
        ],
        totalEstimatedMinutes: 30,
      );
    });

    group('toJson', () {
      test('should convert task to JSON correctly', () {
        final json = sampleTask.toJson();

        expect(json['id'], 'test-id-123');
        expect(json['title'], 'Test Task');
        expect(json['description'], 'Test Description');
        expect(json['status'], TaskStatus.ongoing.index);
        expect(json['priority'], TaskPriority.high.index);
        expect(json['steps'], isA<List>());
        expect(json['totalEstimatedMinutes'], 30);
      });

      test('should handle null optional fields', () {
        final taskWithNulls = Task(
          id: 'test-id',
          title: 'Simple Task',
          description: '',
          deadline: testDeadline,
          createdAt: testCreatedAt,
        );

        final json = taskWithNulls.toJson();

        expect(json['startDate'], isNull);
        expect(json['completedAt'], isNull);
        expect(json['steps'], isNull);
        expect(json['totalEstimatedMinutes'], isNull);
      });
    });

    group('fromJson', () {
      test('should create task from JSON correctly', () {
        final json = {
          'id': 'json-task-id',
          'title': 'JSON Task',
          'description': 'Created from JSON',
          'startDate': '2025-12-20T00:00:00.000',
          'deadline': '2025-12-25T10:00:00.000',
          'status': TaskStatus.ongoing.index,
          'priority': TaskPriority.medium.index,
          'createdAt': '2025-12-17T09:00:00.000',
          'completedAt': null,
          'steps': [
            {'step': 'First step', 'estimatedMinutes': 15}
          ],
          'totalEstimatedMinutes': 15,
        };

        final task = Task.fromJson(json);

        expect(task.id, 'json-task-id');
        expect(task.title, 'JSON Task');
        expect(task.description, 'Created from JSON');
        expect(task.status, TaskStatus.ongoing);
        expect(task.priority, TaskPriority.medium);
        expect(task.steps?.length, 1);
        expect(task.totalEstimatedMinutes, 15);
      });

      test('should handle all status values', () {
        final baseJson = {
          'id': 'test',
          'title': 'Test',
          'description': '',
          'deadline': '2025-12-25T10:00:00.000',
          'priority': 0,
          'createdAt': '2025-12-17T09:00:00.000',
        };

        // Test ongoing
        final ongoingTask = Task.fromJson({...baseJson, 'status': 0});
        expect(ongoingTask.status, TaskStatus.ongoing);

        // Test completed
        final completedTask = Task.fromJson({...baseJson, 'status': 1});
        expect(completedTask.status, TaskStatus.completed);

        // Test missed
        final missedTask = Task.fromJson({...baseJson, 'status': 2});
        expect(missedTask.status, TaskStatus.missed);
      });

      test('should handle all priority values', () {
        final baseJson = {
          'id': 'test',
          'title': 'Test',
          'description': '',
          'deadline': '2025-12-25T10:00:00.000',
          'status': 0,
          'createdAt': '2025-12-17T09:00:00.000',
        };

        // Test low
        final lowTask = Task.fromJson({...baseJson, 'priority': 0});
        expect(lowTask.priority, TaskPriority.low);

        // Test medium
        final mediumTask = Task.fromJson({...baseJson, 'priority': 1});
        expect(mediumTask.priority, TaskPriority.medium);

        // Test high
        final highTask = Task.fromJson({...baseJson, 'priority': 2});
        expect(highTask.priority, TaskPriority.high);
      });
    });

    group('copyWith', () {
      test('should create copy with updated title', () {
        final copy = sampleTask.copyWith(title: 'Updated Title');

        expect(copy.title, 'Updated Title');
        expect(copy.id, sampleTask.id); // ID should remain same
        expect(copy.description, sampleTask.description);
      });

      test('should create copy with updated status', () {
        final copy = sampleTask.copyWith(status: TaskStatus.completed);

        expect(copy.status, TaskStatus.completed);
        expect(copy.title, sampleTask.title);
      });

      test('should create copy with updated priority', () {
        final copy = sampleTask.copyWith(priority: TaskPriority.low);

        expect(copy.priority, TaskPriority.low);
      });

      test('should create copy with multiple updated fields', () {
        final newDeadline = DateTime(2025, 12, 30);
        final copy = sampleTask.copyWith(
          title: 'New Title',
          description: 'New Description',
          deadline: newDeadline,
          priority: TaskPriority.low,
        );

        expect(copy.title, 'New Title');
        expect(copy.description, 'New Description');
        expect(copy.deadline, newDeadline);
        expect(copy.priority, TaskPriority.low);
        expect(copy.id, sampleTask.id); // Unchanged
      });
    });

    group('isMissed', () {
      test('should return false for completed task even if past deadline', () {
        final completedTask = Task(
          id: 'test',
          title: 'Completed',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: testCreatedAt,
        );

        expect(completedTask.isMissed, false);
      });

      test('should return true for ongoing task past deadline', () {
        final missedTask = Task(
          id: 'test',
          title: 'Missed',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: testCreatedAt,
        );

        expect(missedTask.isMissed, true);
      });

      test('should return false for ongoing task before deadline', () {
        final futureTask = Task(
          id: 'test',
          title: 'Future',
          description: '',
          deadline: DateTime.now().add(const Duration(days: 7)),
          status: TaskStatus.ongoing,
          createdAt: testCreatedAt,
        );

        expect(futureTask.isMissed, false);
      });
    });

    group('updateStatus', () {
      test('should update status to missed if past deadline and ongoing', () {
        final task = Task(
          id: 'test',
          title: 'Test',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.ongoing,
          createdAt: testCreatedAt,
        );

        task.updateStatus();

        expect(task.status, TaskStatus.missed);
      });

      test('should not update status if already completed', () {
        final task = Task(
          id: 'test',
          title: 'Test',
          description: '',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          status: TaskStatus.completed,
          createdAt: testCreatedAt,
        );

        task.updateStatus();

        expect(task.status, TaskStatus.completed);
      });
    });

    group('formatted dates', () {
      test('formattedDeadline should return correct format', () {
        final task = Task(
          id: 'test',
          title: 'Test',
          description: '',
          deadline: DateTime(2025, 12, 25, 14, 30),
          createdAt: testCreatedAt,
        );

        expect(task.formattedDeadline, '25 Dec 2025, 14:30');
      });

      test('shortDeadline should return date only', () {
        final task = Task(
          id: 'test',
          title: 'Test',
          description: '',
          deadline: DateTime(2025, 12, 25, 14, 30),
          createdAt: testCreatedAt,
        );

        expect(task.shortDeadline, '25 Dec 2025');
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through toJson/fromJson cycle', () {
        final json = sampleTask.toJson();
        final recreatedTask = Task.fromJson(json);

        expect(recreatedTask.id, sampleTask.id);
        expect(recreatedTask.title, sampleTask.title);
        expect(recreatedTask.description, sampleTask.description);
        expect(recreatedTask.status, sampleTask.status);
        expect(recreatedTask.priority, sampleTask.priority);
        expect(recreatedTask.steps?.length, sampleTask.steps?.length);
        expect(recreatedTask.totalEstimatedMinutes, sampleTask.totalEstimatedMinutes);
      });
    });
  });
}
