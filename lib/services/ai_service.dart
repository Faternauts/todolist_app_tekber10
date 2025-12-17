import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String? getApiKey() {
    return dotenv.env['OPENAI_API_KEY'];
  }

  /// Generate task breakdown steps using OpenAI API
  static Future<Map<String, dynamic>> generateTaskSteps(
      {required String title, String? description}) async {
    try {
      final apiKey = getApiKey();

      // If no API key, use fallback simulation
      if (apiKey == null || apiKey.isEmpty) {
        return _simulateAIBreakdown(title);
      }

      // OpenAI API endpoint
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      // Create messages
      final messages = _createMessages(title, description);

      // Make API request
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey'
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini',
              'messages': messages,
              'response_format': {'type': 'json_object'},
              'temperature': 0.7,
              'max_tokens': 1000,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract text from OpenAI response
        final content = data['choices']?[0]?['message']?['content'];

        if (content != null) {
          // Parse the JSON response
          final result = jsonDecode(content);
          if (result['steps'] != null && result['steps'] is List) {
            return {
              'steps': List<Map<String, dynamic>>.from(result['steps']),
              'totalEstimatedMinutes': result['totalEstimatedMinutes'] ??
                  _calculateTotalMinutes(result['steps'])
            };
          }
        }
      } else {
        print(
            'Error: OpenAI API error: ${response.statusCode} - ${response.body}');
      }

      // Fallback if API fails
      return _simulateAIBreakdown(title);
    } catch (e) {
      print('Error generating AI steps: $e');
      // Fallback to simulation on error
      return _simulateAIBreakdown(title);
    }
  }

  /// Create messages for OpenAI API
  static List<Map<String, String>> _createMessages(
      String title, String? description) {
    final messages = <Map<String, String>>[];

    // System message
    messages.add({
      'role': 'system',
      'content':
          'You are a task breakdown assistant dedicated for ADHD person so they can get their todolist done. Your task is to breakdown a single todolist from user. Breakdown steps should be not too long, it\'s gonna be min 3 and max 10. The breakdown task should be actionable. You must also generate estimate time in minutes how long each step gonna take. You must respond in JSON format with structure: {"steps": [{"step": "description", "estimatedMinutes": number}], "totalEstimatedMinutes": number}',
    });

    // User message
    final descriptionText = description != null && description.isNotEmpty
        ? ', description: "$description"'
        : '';

    messages.add({'role': 'user', 'content': 'Title: $title$descriptionText'});

    return messages;
  }

  /// Calculate total minutes from steps
  static int _calculateTotalMinutes(List<dynamic> steps) {
    int total = 0;
    for (var step in steps) {
      if (step is Map && step['estimatedMinutes'] != null) {
        total += (step['estimatedMinutes'] as num).toInt();
      }
    }
    return total;
  }

  /// Simulate AI breakdown (fallback when API is unavailable)
  static Map<String, dynamic> _simulateAIBreakdown(String title) {
    final titleLower = title.toLowerCase();
    List<Map<String, dynamic>> steps;

    // Design/Wireframe tasks
    if (titleLower.contains('design') ||
        titleLower.contains('wireframe') ||
        titleLower.contains('mockup') ||
        titleLower.contains('prototype')) {
      steps = [
        {
          'step': 'Gather inspiration and reference images',
          'estimatedMinutes': 15
        },
        {
          'step': 'Sketch initial layout ideas on paper',
          'estimatedMinutes': 20
        },
        {'step': 'Create low-fidelity wireframes', 'estimatedMinutes': 30},
        {'step': 'Review with the product manager', 'estimatedMinutes': 15},
        {'step': 'Refine into high-fidelity mockups', 'estimatedMinutes': 40},
      ];
    }
    // Meeting/Call tasks
    else if (titleLower.contains('meeting') ||
        titleLower.contains('call') ||
        titleLower.contains('sync')) {
      steps = [
        {
          'step': 'Prepare the agenda and key talking points',
          'estimatedMinutes': 10
        },
        {'step': 'Review previous meeting minutes', 'estimatedMinutes': 5},
        {'step': 'Set up the video conferencing link', 'estimatedMinutes': 3},
        {'step': 'Send reminders to attendees', 'estimatedMinutes': 2},
      ];
    }
    // Study/Exam tasks
    else if (titleLower.contains('study') ||
        titleLower.contains('exam') ||
        titleLower.contains('learn') ||
        titleLower.contains('practice')) {
      steps = [
        {
          'step': 'Pick one specific topic from your notes',
          'estimatedMinutes': 5
        },
        {
          'step': 'Read your notes for that topic for 15 minutes',
          'estimatedMinutes': 15
        },
        {
          'step': 'Do one or two practice problems related to it',
          'estimatedMinutes': 20
        },
        {
          'step': 'Take a well-deserved break and celebrate your effort',
          'estimatedMinutes': 10
        },
      ];
    }
    // Report/Documentation tasks
    else if (titleLower.contains('report') ||
        titleLower.contains('document') ||
        titleLower.contains('write')) {
      steps = [
        {
          'step': 'Gather all necessary data and information',
          'estimatedMinutes': 20
        },
        {
          'step': 'Create an outline with main sections',
          'estimatedMinutes': 15
        },
        {
          'step': 'Write the first draft without editing',
          'estimatedMinutes': 45
        },
        {'step': 'Review and refine the content', 'estimatedMinutes': 25},
        {'step': 'Format and finalize the document', 'estimatedMinutes': 15},
      ];
    }
    // Code/Development tasks
    else if (titleLower.contains('code') ||
        titleLower.contains('develop') ||
        titleLower.contains('implement') ||
        titleLower.contains('build') ||
        titleLower.contains('feature')) {
      steps = [
        {
          'step': 'Review requirements and acceptance criteria',
          'estimatedMinutes': 15
        },
        {
          'step': 'Break down the feature into smaller components',
          'estimatedMinutes': 20
        },
        {'step': 'Set up the development environment', 'estimatedMinutes': 10},
        {'step': 'Implement the core functionality', 'estimatedMinutes': 60},
        {'step': 'Test thoroughly and fix any bugs', 'estimatedMinutes': 30},
      ];
    }
    // Review tasks
    else if (titleLower.contains('review') || titleLower.contains('feedback')) {
      steps = [
        {'step': 'Collect all materials to review', 'estimatedMinutes': 10},
        {'step': 'Go through each item systematically', 'estimatedMinutes': 30},
        {
          'step': 'Note down key observations and feedback',
          'estimatedMinutes': 20
        },
        {
          'step': 'Prepare summary with recommendations',
          'estimatedMinutes': 15
        },
      ];
    }
    // Generic fallback
    else {
      steps = [
        {
          'step': 'Analyze the requirements and gather information',
          'estimatedMinutes': 15
        },
        {
          'step': 'Break down the task into smaller components',
          'estimatedMinutes': 10
        },
        {'step': 'Execute the first phase with focus', 'estimatedMinutes': 30},
        {
          'step': 'Review progress and adjust as needed',
          'estimatedMinutes': 10
        },
      ];
    }

    return {
      'steps': steps,
      'totalEstimatedMinutes': _calculateTotalMinutes(steps)
    };
  }
}
