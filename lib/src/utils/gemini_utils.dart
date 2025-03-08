import 'dart:convert';
import 'dart:io';

import 'package:git_commit_message_generator/src/model/git_summary.dart';
import 'package:http/http.dart' as http;

Future<List<String>> generateCommitSuggestions(GitSummary gitSummary) async {
  // Get API key from environment variable
  final apiKey = Platform.environment['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('GEMINI_API_KEY environment variable is not set');
  }

  // Create a prompt for Gemini based on the git summary
  final prompt = _createGeminiPrompt(gitSummary);

  // Call Gemini API
  final suggestions = await _callGeminiApi(prompt, apiKey);

  return suggestions;
}

/// Creates a structured prompt for Gemini based on git diff and log data
String _createGeminiPrompt(GitSummary gitSummary) {
  // Extract stats and log entries for the prompt
  final diffStats = gitSummary.diffStats;
  final recentCommits = gitSummary.logEntries
      .take(3)
      .map(
        (entry) => "- ${entry['message']} (${entry['hash'].substring(0, 7)})",
      )
      .join('\n');

  // Build prompt for Gemini
  return '''
Generate 3 concise, descriptive commit messages based on the following git diff and recent commit history.
Format each suggestion as a numbered list.

Git Diff Stats:
- $diffStats

Recent commits:
$recentCommits

The commit messages should follow best practices:
- Start with a verb in imperative form (e.g., "Add", "Fix", "Update")
- Adhere to 'Conventional Commits' best practices
- Be concise (50-72 characters for the first line)
- Describe WHAT changed and WHY, not HOW
- Be specific rather than vague
- Only put what should be the message of the commit and nothing else
- Don't add asteriks(*) to messages

Please generate 3 different commit message suggestions.
''';
}

/// Calls Gemini API to generate commit message suggestions
Future<List<String>> _callGeminiApi(String prompt, String apiKey) async {
  final url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=$apiKey';

  final requestBody = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": prompt},
        ],
      },
    ],
    "generationConfig": {
      "temperature": 0.7,
      "topK": 40,
      "topP": 0.95,
      "maxOutputTokens": 1024,
    },
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Extract the generated text from Gemini response
      final candidates = jsonResponse['candidates'] as List;
      if (candidates.isNotEmpty) {
        final generatedText =
            candidates[0]['content']['parts'][0]['text'] as String;

        // Parse the numbered list from the response
        return _parseCommitSuggestions(generatedText);
      }
    }

    throw Exception(
      'Failed to get suggestions: ${response.statusCode} - ${response.body}',
    );
  } catch (e) {
    print('Error calling Gemini API: $e');
    return ['Failed to generate commit suggestions. Error: $e'];
  }
}

List<String> _parseCommitSuggestions(String responseText) {
  final suggestions = <String>[];

  // Look for numbered items (1., 2., 3., etc.)
  final regex = RegExp(r'\d+\.\s+(.+)');

  for (final match in regex.allMatches(responseText)) {
    if (match.group(1) != null) {
      suggestions.add(match.group(1)!.trim());
    }
  }

  // If parsing fails, return the whole text
  if (suggestions.isEmpty) {
    return [responseText];
  }

  return suggestions
      .map((suggestion) => suggestion.replaceAll(RegExp(r'\*'), ''))
      .toList();
}
