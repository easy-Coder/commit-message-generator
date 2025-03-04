import 'dart:io';

import 'package:git_commit_message_generator/src/model/git_summary.dart';

Future<GitSummary> getCurrentDirectoryGitSummary({int logCount = 5}) async {
  // Check if current directory is a git repository
  final gitDirCheck = await Process.run('git', [
    'rev-parse',
    '--is-inside-work-tree',
  ], runInShell: true);

  if (gitDirCheck.exitCode != 0) {
    throw Exception('Current directory is not a git repository');
  }

  // Get git diff stats for working directory changes
  final diffResult = await Process.run('git', [
    'diff',
    '--cached',
  ], runInShell: true);

  if (diffResult.exitCode != 0) {
    throw Exception('Failed to get git diff: ${diffResult.stderr}');
  }

  // Parse diff stats
  final diffStats = diffResult.stdout.toString();

  // Get git log
  final logResult = await Process.run('git', [
    'log',
    '-n',
    logCount.toString(),
    '--pretty=format:%H|%an|%ad|%s',
    '--date=iso',
  ], runInShell: true);

  if (logResult.exitCode != 0) {
    throw Exception('Failed to get git log: ${logResult.stderr}');
  }

  // Parse log entries
  final logEntries = _parseLogEntries(logResult.stdout.toString());

  return GitSummary(diffStats: diffStats, logEntries: logEntries);
}

/// Helper method to parse git log output
List<Map<String, dynamic>> _parseLogEntries(String logOutput) {
  final entries = <Map<String, dynamic>>[];

  if (logOutput.trim().isEmpty) {
    return entries;
  }

  for (var line in logOutput.split('\n')) {
    if (line.trim().isEmpty) continue;

    final parts = line.split('|');
    if (parts.length >= 4) {
      entries.add({
        'hash': parts[0],
        'author': parts[1],
        'date': parts[2],
        'message': parts[3],
      });
    }
  }

  return entries;
}

void runCommit(String commitMessage) async {
  final runCommit = await Process.run('git', ['commit', '-m', commitMessage]);
  print(runCommit.stdout);
  if (runCommit.exitCode != 0) {
    throw Exception('Failed to commit: ${runCommit.stderr}');
  }
}
