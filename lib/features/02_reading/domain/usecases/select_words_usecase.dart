import 'dart:math';

import 'package:impariamo_reading_app/features/02_reading/domain/models/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';
import 'package:impariamo_reading_app/core/repositories/progress_repository.dart';

/// Pure Dart use-case to select words for a session.
class SelectWordsUseCase {
  final int sessionSize;
  SelectWordsUseCase({this.sessionSize = 10});

  Future<List<Word>> call({required ProgressRepository progressRepository, required String childId, required String levelId, required List<Word> allWords}) async {
    final rng = Random();
    if (allWords.isEmpty) return [];
    final progressList = await progressRepository.getProgressForChild(childId);
    final Map<String, ProgressRecord> map = {for (var p in progressList) p.wordId: p};

    final unsolved = <Word>[];
    final solved = <Word>[];
    for (final w in allWords) {
      final p = map[w.id];
      if (p == null || p.completed == false) {
        unsolved.add(w);
      } else {
        solved.add(w);
      }
    }

    final selected = <Word>[];
    unsolved.shuffle(rng);
    selected.addAll(unsolved.take(min(unsolved.length, sessionSize)));
    if (selected.length < sessionSize) {
      solved.sort((a, b) {
        final pa = map[a.id]!.lastSeen?.millisecondsSinceEpoch ?? 0;
        final pb = map[b.id]!.lastSeen?.millisecondsSinceEpoch ?? 0;
        return pa.compareTo(pb);
      });
      final need = sessionSize - selected.length;
      selected.addAll(solved.take(min(need, solved.length)));
    }
    selected.shuffle(rng);
    return selected;
  }
}
