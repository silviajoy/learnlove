abstract class SessionEvent {}

class StartSession extends SessionEvent {
  final String childId;
  final String levelId;
  StartSession(this.childId, this.levelId);
}

class NextWordRequested extends SessionEvent {}

class RevealImageRequested extends SessionEvent {}

class SubmitAnswer extends SessionEvent {
  final bool correct;
  SubmitAnswer(this.correct);
}
