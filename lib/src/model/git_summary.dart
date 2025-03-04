/// A class that holds the summary data for git diff and git log
class GitSummary {
  final String diffStats;
  final List<Map<String, dynamic>> logEntries;

  GitSummary({required this.diffStats, required this.logEntries});

  @override
  String toString() {
    final diffSummary = diffStats;

    final logSummary = logEntries
        .map(
          (entry) =>
              'Commit: ${entry['hash']}\n'
              'Author: ${entry['author']}\n'
              'Date: ${entry['date']}\n'
              'Message: ${entry['message']}\n',
        )
        .join('\n');

    return 'GIT DIFF SUMMARY:\n$diffSummary\n\nGIT LOG SUMMARY:\n$logSummary';
  }
}
