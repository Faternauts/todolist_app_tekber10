import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static const String _apiKeyKey = 'GEMINI_API_KEY';
  
  /// Get API key from SharedPreferences
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }
  
  /// Save API key to SharedPreferences
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }
  
  /// Generate task breakdown steps using Gemini API
  static Future<List<String>> generateTaskSteps({
    required String title,
    String? description,
  }) async {
    try {
      final apiKey = await getApiKey();
      
      // If no API key, use fallback simulation
      if (apiKey == null || apiKey.isEmpty) {
        return _simulateAIBreakdown(title);
      }
      
      // Gemini API endpoint
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
      );
      
      // Create prompt
      final prompt = _createPrompt(title, description);
      
      // Make API request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract text from Gemini response
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        
        if (text != null) {
          // Parse the steps from the response
          final steps = _parseStepsFromResponse(text);
          if (steps.isNotEmpty) {
            return steps;
          }
        }
      }
      
      // Fallback if API fails
      return _simulateAIBreakdown(title);
    } catch (e) {
      print('Error generating AI steps: $e');
      // Fallback to simulation on error
      return _simulateAIBreakdown(title);
    }
  }
  
  /// Create prompt for Gemini API
  static String _createPrompt(String title, String? description) {
    final descriptionText = description != null && description.isNotEmpty
        ? ' Description: $description'
        : '';
    
    return '''
Break down the following task into 3-5 clear, actionable steps. Each step should be specific and easy to complete.

Task: $title$descriptionText

Please provide the steps as a numbered list (1., 2., 3., etc.). Make the steps practical and motivating.
''';
  }
  
  /// Parse steps from Gemini API response
  static List<String> _parseStepsFromResponse(String text) {
    final lines = text.split('\n');
    final steps = <String>[];
    
    for (var line in lines) {
      line = line.trim();
      
      // Match numbered lists: "1.", "1)", "1 -", etc.
      final match = RegExp(r'^\d+[\.\)\-\:]\s*(.+)$').firstMatch(line);
      if (match != null) {
        final step = match.group(1)?.trim();
        if (step != null && step.isNotEmpty) {
          steps.add(step);
        }
      } else if (line.startsWith('- ') || line.startsWith('• ')) {
        // Also handle bullet points
        final step = line.substring(2).trim();
        if (step.isNotEmpty) {
          steps.add(step);
        }
      }
    }
    
    return steps;
  }
  
  /// Simulate AI breakdown (fallback when API is unavailable)
  static List<String> _simulateAIBreakdown(String title) {
    final titleLower = title.toLowerCase();
    
    // Design/Wireframe tasks
    if (titleLower.contains('design') || 
        titleLower.contains('wireframe') ||
        titleLower.contains('mockup') ||
        titleLower.contains('prototype')) {
      return [
        'Gather inspiration and reference images.',
        'Sketch initial layout ideas on paper.',
        'Create low-fidelity wireframes.',
        'Review with the product manager.',
        'Refine into high-fidelity mockups.',
      ];
    }
    
    // Meeting/Call tasks
    if (titleLower.contains('meeting') || 
        titleLower.contains('call') ||
        titleLower.contains('sync')) {
      return [
        'Prepare the agenda and key talking points.',
        'Review previous meeting minutes.',
        'Set up the video conferencing link.',
        'Send reminders to attendees.',
      ];
    }
    
    // Study/Exam tasks
    if (titleLower.contains('study') || 
        titleLower.contains('exam') ||
        titleLower.contains('learn') ||
        titleLower.contains('practice')) {
      return [
        'Pick one specific topic from your notes.',
        'Read your notes for that topic for 15 minutes.',
        'Do one or two practice problems related to it.',
        'Take a well-deserved break and celebrate your effort!',
      ];
    }
    
    // Report/Documentation tasks
    if (titleLower.contains('report') || 
        titleLower.contains('document') ||
        titleLower.contains('write')) {
      return [
        'Gather all necessary data and information.',
        'Create an outline with main sections.',
        'Write the first draft without editing.',
        'Review and refine the content.',
        'Format and finalize the document.',
      ];
    }
    
    // Code/Development tasks
    if (titleLower.contains('code') || 
        titleLower.contains('develop') ||
        titleLower.contains('implement') ||
        titleLower.contains('build') ||
        titleLower.contains('feature')) {
      return [
        'Review requirements and acceptance criteria.',
        'Break down the feature into smaller components.',
        'Set up the development environment.',
        'Implement the core functionality.',
        'Test thoroughly and fix any bugs.',
      ];
    }
    
    // Review tasks
    if (titleLower.contains('review') || titleLower.contains('feedback')) {
      return [
        'Collect all materials to review.',
        'Go through each item systematically.',
        'Note down key observations and feedback.',
        'Prepare summary with recommendations.',
      ];
    }
    
    // Generic fallback
    return [
      'Analyze the requirements and gather information.',
      'Break down the task into smaller components.',
      'Execute the first phase with focus.',
      'Review progress and adjust as needed.',
    ];
  }
}



