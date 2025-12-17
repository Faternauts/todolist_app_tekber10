import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_app_tekber10/services/ai_service.dart';

void main() {
  group('AIService', () {
    group('generateTaskSteps - Mock AI Breakdown', () {
      // Note: These tests use the mock/fallback AI since no API key is loaded in tests
      
      test('should generate steps for design-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Design homepage wireframe');

        expect(result['steps'], isA<List>());
        expect(result['totalEstimatedMinutes'], isA<int>());
        
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        expect(steps.length, lessThanOrEqualTo(10));
        
        // Check step structure
        for (var step in steps) {
          expect(step['step'], isA<String>());
          expect(step['estimatedMinutes'], isA<int>());
        }
      });

      test('should generate steps for meeting-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Schedule team meeting');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        
        // Meeting tasks should have specific steps
        expect(steps.any((s) => s['step'].toString().toLowerCase().contains('agenda')), true);
      });

      test('should generate steps for study-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Study for math exam');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for report-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Write quarterly report');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for code-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Implement user authentication feature');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate steps for review-related tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Review pull request');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should generate generic steps for unrecognized tasks', () async {
        final result = await AIService.generateTaskSteps(title: 'Random task xyz');

        expect(result['steps'], isA<List>());
        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
        expect(result['totalEstimatedMinutes'], isA<int>());
      });
    });

    group('totalEstimatedMinutes calculation', () {
      test('should calculate correct total from steps', () async {
        final result = await AIService.generateTaskSteps(title: 'Design mockup');

        final steps = result['steps'] as List;
        final expectedTotal = steps.fold<int>(
          0,
          (sum, step) => sum + (step['estimatedMinutes'] as int),
        );

        expect(result['totalEstimatedMinutes'], expectedTotal);
      });

      test('should return positive total estimated minutes', () async {
        final result = await AIService.generateTaskSteps(title: 'Any task');

        expect(result['totalEstimatedMinutes'], greaterThan(0));
      });
    });

    group('step structure validation', () {
      test('each step should have required fields', () async {
        final result = await AIService.generateTaskSteps(title: 'Test task');

        final steps = result['steps'] as List;
        for (var step in steps) {
          expect(step.containsKey('step'), true);
          expect(step.containsKey('estimatedMinutes'), true);
          expect(step['step'], isNotEmpty);
          expect(step['estimatedMinutes'], greaterThan(0));
        }
      });

      test('step descriptions should be meaningful strings', () async {
        final result = await AIService.generateTaskSteps(title: 'Code feature');

        final steps = result['steps'] as List;
        for (var step in steps) {
          final description = step['step'] as String;
          expect(description.length, greaterThan(5)); // Meaningful description
        }
      });
    });

    group('keyword detection', () {
      test('should detect "wireframe" as design task', () async {
        final result = await AIService.generateTaskSteps(title: 'Create wireframe');
        final steps = result['steps'] as List;
        
        // Design tasks typically have "inspiration" or "sketch" steps
        final hasDesignStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('inspiration') ||
          s['step'].toString().toLowerCase().contains('sketch') ||
          s['step'].toString().toLowerCase().contains('wireframe')
        );
        expect(hasDesignStep, true);
      });

      test('should detect "call" as meeting task', () async {
        final result = await AIService.generateTaskSteps(title: 'Client call tomorrow');
        final steps = result['steps'] as List;
        
        // Meeting tasks typically have "agenda" steps
        final hasMeetingStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('agenda') ||
          s['step'].toString().toLowerCase().contains('meeting')
        );
        expect(hasMeetingStep, true);
      });

      test('should detect "document" as report task', () async {
        final result = await AIService.generateTaskSteps(title: 'Document the API');
        final steps = result['steps'] as List;
        
        // Report tasks typically have "gather" or "outline" steps
        final hasReportStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('gather') ||
          s['step'].toString().toLowerCase().contains('outline') ||
          s['step'].toString().toLowerCase().contains('draft')
        );
        expect(hasReportStep, true);
      });

      test('should detect "build" as code task', () async {
        final result = await AIService.generateTaskSteps(title: 'Build login page');
        final steps = result['steps'] as List;
        
        // Code tasks typically have "requirements" or "implement" steps
        final hasCodeStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('requirements') ||
          s['step'].toString().toLowerCase().contains('implement') ||
          s['step'].toString().toLowerCase().contains('test')
        );
        expect(hasCodeStep, true);
      });

      test('should detect "feedback" as review task', () async {
        final result = await AIService.generateTaskSteps(title: 'Give feedback on design');
        final steps = result['steps'] as List;
        
        // Review tasks typically have "collect" or "observations" steps
        final hasReviewStep = steps.any((s) => 
          s['step'].toString().toLowerCase().contains('collect') ||
          s['step'].toString().toLowerCase().contains('observations') ||
          s['step'].toString().toLowerCase().contains('review')
        );
        expect(hasReviewStep, true);
      });
    });

    group('case insensitivity', () {
      test('should handle uppercase keywords', () async {
        final result = await AIService.generateTaskSteps(title: 'DESIGN NEW FEATURE');

        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });

      test('should handle mixed case keywords', () async {
        final result = await AIService.generateTaskSteps(title: 'DeVeLoP New Feature');

        final steps = result['steps'] as List;
        expect(steps.length, greaterThanOrEqualTo(3));
      });
    });
  });
}

