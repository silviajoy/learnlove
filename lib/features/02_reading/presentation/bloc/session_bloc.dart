import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:impariamo_reading_app/features/02_reading/domain/models/attempt.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';

import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/progress_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/sessions_repository.dart';
import '../../domain/usecases/select_words_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final LevelsRepository levelsRepository;
  final ProgressRepository progressRepository;
  final SessionsRepository sessionsRepository;
  final SelectWordsUseCase selector;
  final SaveSessionUseCase saver;
  static const int sessionSize = 10;

  late Session _session;
  late List<Word> _playlist;

  SessionBloc({required this.levelsRepository, required this.progressRepository, required this.sessionsRepository, required this.selector, required this.saver}) : super(SessionInitial()) {
    on<StartSession>(_onStartSession);
    on<NextWordRequested>(_onNextWord);
    on<RevealImageRequested>(_onRevealImage);
    on<SubmitAnswer>(_onSubmitAnswer);
  }

  Future<void> _onStartSession(StartSession event, Emitter<SessionState> emit) async {
    emit(SessionLoading());
    try {
      final words = await levelsRepository.getWordsForLevel(event.levelId);
      // select playlist using injected use-case (uses progressRepository)
      _playlist = await selector(progressRepository: progressRepository, childId: event.childId, levelId: event.levelId, allWords: words);
      _session = Session(childId: event.childId, levelId: event.levelId, total: _playlist.length);
      await sessionsRepository.saveSession(_session);
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

  // Selection logic moved to SelectWordsUseCase in domain layer.

  Future<void> _onNextWord(NextWordRequested event, Emitter<SessionState> emit) async {
    final state = this.state;
    if (state is SessionInProgress) {
      final nextIndex = state.currentIndex + 1;
      if (nextIndex >= _playlist.length) {
        // finish
        // delegate session finalization to use-case
        await saver(levelsRepository: levelsRepository, sessionsRepository: sessionsRepository, session: _session, correctCount: state.correctCount, total: state.total);
        final stars = _computeStars(state.correctCount, state.total);
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
      final pr = await progressRepository.getProgressForChildWord(state.session.childId, state.currentWord.id);
      if (pr == null) {
        final newPr = ProgressRecord(childId: state.session.childId, wordId: state.currentWord.id, completed: wasCorrect, attempts: wasCorrect ? 1 : 1, lastSeen: DateTime.now());
        await progressRepository.saveProgressRecord(newPr);
      } else {
        pr.attempts = pr.attempts + 1;
        pr.completed = pr.completed || wasCorrect;
        pr.lastSeen = DateTime.now();
        await progressRepository.saveProgressRecord(pr);
      }
      // save session progress
      await sessionsRepository.saveSession(state.session);
      // move to next word or finish
      final correctCount = state.correctCount + (wasCorrect ? 1 : 0);
      final currentIndex = state.currentIndex;
      if (currentIndex + 1 >= _playlist.length) {
        // finish immediately
        // delegate finalization
        await saver(levelsRepository: levelsRepository, sessionsRepository: sessionsRepository, session: _session, correctCount: correctCount, total: state.total);
        final stars = _computeStars(correctCount, state.total);
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
