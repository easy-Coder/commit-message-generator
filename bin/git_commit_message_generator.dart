import 'dart:io';

import 'package:git_commit_message_generator/git_commit_message_generator.dart';

/// Function to let user choose a commit message from suggestions
Future<String> chooseCommitMessage(GitSummary gitSummary) async {
  while (true) {
    final suggestions = await generateCommitSuggestions(gitSummary);

    // Display suggestions to user
    print('\nCommit message suggestions:');
    for (var i = 0; i < suggestions.length; i++) {
      print('${i + 1}. ${suggestions[i]}');
    }
    print('${suggestions.length + 1}. Write my own message');
    print('${suggestions.length + 2}. Regenerate a new message');

    // Get user choice
    stdout.write(
      '\nChoose a commit message (1-${suggestions.length + 2}) or Press enter to exit: ',
    );
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '') ?? 0;

    if (choice > 0 && choice <= suggestions.length) {
      return suggestions[choice - 1];
    } else if (choice == suggestions.length + 1) {
      stdout.write('Enter your commit message: ');
      final customMessage = stdin.readLineSync() ?? '';
      return customMessage;
    } else if (choice == suggestions.length + 2) {
      continue;
    } else {
      print('Exiting program...');
      return '';
    }
  }
}

// Example of using the function with the GitSummary from the previous code
void main() async {
  try {
    // Get summary for current directory
    final summary = await getCurrentDirectoryGitSummary();

    // Get and choose commit message
    final commitMessage = await chooseCommitMessage(summary)
      ..replaceAll(RegExp(r'\*'), '');

    if (commitMessage.isEmpty) {
      exit(0);
    }

    print('\nSelected commit message: "$commitMessage"');
    print('\nRunning command:');
    print('git commit -m "$commitMessage"');
    runCommit(commitMessage);
  } catch (e) {
    print('Error: $e');
  }
}
