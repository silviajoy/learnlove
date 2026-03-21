import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../core/models/session.dart';
import '../../core/models/attempt.dart';
import '../../core/models/word.dart';
import '../../core/models/progress_record.dart';
import '../../core/models/level_progress.dart';
import '../../data/local/hive_repository.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final HiveLocalRepository repository;
  static const int sessionSize = 10;

  late Session _session;
  late List<Word> _playlist;

  SessionBloc({required this.repository}) : super(SessionInitial()) {
    on<StartSession>(_onStartSession);
    on<NextWordRequested>(_onNextWord);
    on<RevealImageRequested>(_onRevealImage);
    on<SubmitAnswer>(_onSubmitAnswer);
  }

  Future<void> _onStartSession(StartSession event, Emitter<SessionState> emit) async {
    emit(SessionLoading());
    try {
      final words = await repository.getWordsForLevel(event.levelId);
      // select playlist
      _playlist = await _selectWordsForSession(event.childId, event.levelId, words);
      _session = Session(childId: event.childId, levelId: event.levelId, total: _playlist.length);
      await repository.saveSession(_session);
      if (_playlist.isEmpty) {
        emit(SessionFailure('No words available'));
        return;
      }
      final first = _playlist[0];
      emit(SessionInProgress(session: _session, currentIndex: 0, currentWord: first, imageRevealed: false, correctCount: 0, total: _playlist.length));
    } catch (e) {
      emit(SessionFailure(e.toString()));
    }
  }

  Future<List<Word>> _selectWordsForSession(String childId, String levelId, List<Word> allWords) async {
    final rng = Random();
    if (allWords.isEmpty) return [];
    final progressList = await repository.getProgressForChild(childId);
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
      // fill with least recently seen solved words
      solved.sort((a, b) {
        final pa = map[a.id]!.lastSeen?.millisecondsSinceEpoch ?? 0;
        final pb = map[b.id]!.lastSeen?.millisecondsSinceEpoch ?? 0;
        return pa.compareTo(pb);
      });
      final need = sessionSize - selected.length;
      selected.addAll(solved.take(min(need, solved.length)));
    }
    // final shuffle to mix
    selected.shuffle(rng);
    return selected;
  }

  Future<void> _onNextWord(NextWordRequested event, Emitter<SessionState> emit) async {
    final state = this.state;
    if (state is SessionInProgress) {
      final nextIndex = state.currentIndex + 1;
      if (nextIndex >= _playlist.length) {
        // finish
        _session.end = DateTime.now();
        await repository.saveSession(_session);
        final stars = _computeStars(state.correctCount, state.total);
        // update LevelProgress
        final lp = await repository.getLevelProgress(_session.childId, _session.levelId) ?? LevelProgress(childId: _session.childId, levelId: _session.levelId);
        lp.lastStars = stars;
        lp.lastCorrectCount = state.correctCount;
        lp.lastTotal = state.total;
        lp.updatedAt = DateTime.now();
        lp.bestStars = max(lp.bestStars, stars);
        await repository.saveLevelProgress(lp);
        emit(SessionCompleted(session: _session, stars: stars, correctCount: state.correctCount, total: state.total));
      } else {
        final w = _playlist[nextIndex];
        emit(SessionInProgress(session: _session, currentIndex: nextIndex, currentWord: w, imageRevealed: false, correctCount: state.correctCount, total: state.total));
      }
    }
  }

  Future<void> _onRevealImage(RevealImageRequested event, Emitter<SessionState> emit) async {
    final state = this.state;
    if (state is SessionInProgress) {
      emit(SessionInProgress(session: state.session, currentIndex: state.currentIndex, currentWord: state.currentWord, imageRevealed: true, correctCount: state.correctCount, total: state.total));
    }
  }

  Future<void> _onSubmitAnswer(SubmitAnswer event, Emitter<SessionState> emit) async {
    final state = this.state;
    if (state is SessionInProgress) {
      final wasCorrect = event.correct;
      // record attempt
      final attempt = Attempt(wordId: state.currentWord.id, wasCorrect: wasCorrect, attemptNumber: 1);
      state.session.attempts.add(attempt);
      if (wasCorrect) state.session.correctCount += 1;
      // update progress record
      final pr = await repository.getProgressForChildWord(state.session.childId, state.currentWord.id);
      if (pr == null) {
        final newPr = ProgressRecord(childId: state.session.childId, wordId: state.currentWord.id, completed: wasCorrect, attempts: wasCorrect ? 1 : 1, lastSeen: DateTime.now());
        await repository.saveProgressRecord(newPr);
      } else {
        pr.attempts = pr.attempts + 1;
        pr.completed = pr.completed || wasCorrect;
        pr.lastSeen = DateTime.now();
        await repository.saveProgressRecord(pr);
      }
      // save session progress
      await repository.saveSession(state.session);
      // move to next word or finish
      final correctCount = state.correctCount + (wasCorrect ? 1 : 0);
      final currentIndex = state.currentIndex;
      if (currentIndex + 1 >= _playlist.length) {
        // finish immediately
        _session.end = DateTime.now();
        final stars = _computeStars(correctCount, state.total);
        final lp = await repository.getLevelProgress(_session.childId, _session.levelId) ?? LevelProgress(childId: _session.childId, levelId: _session.levelId);
        lp.lastStars = stars;
        lp.lastCorrectCount = correctCount;
        lp.lastTotal = state.total;
        lp.updatedAt = DateTime.now();
        lp.bestStars = max(lp.bestStars, stars);
        await repository.saveLevelProgress(lp);
        await repository.saveSession(_session);
        emit(SessionCompleted(session: _session, stars: stars, correctCount: correctCount, total: state.total));
      } else {
        final nextWord = _playlist[currentIndex + 1];
        emit(SessionInProgress(session: _session, currentIndex: currentIndex + 1, currentWord: nextWord, imageRevealed: false, correctCount: correctCount, total: state.total));
      }
    }
  }

  int _computeStars(int correct, int total) {
    if (total == 0) return 0;
    if (correct == total) return 3;
    if (correct >= 8) return 2;
    if (correct >= 7) return 1;
    return 0;
  }
}
