import '../../core/models/word.dart';
import '../../core/models/session.dart';

abstract class SessionState {}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionInProgress extends SessionState {
  final Session session;
  final int currentIndex;
  final Word currentWord;
  final bool imageRevealed;
  final int correctCount;
  final int total;

  SessionInProgress({required this.session, required this.currentIndex, required this.currentWord, this.imageRevealed = false, required this.correctCount, required this.total});
}

class SessionCompleted extends SessionState {
  final Session session;
  final int stars;
  final int correctCount;
  final int total;
  SessionCompleted({required this.session, required this.stars, required this.correctCount, required this.total});
}

class SessionFailure extends SessionState {
  final String message;
  SessionFailure(this.message);
}
