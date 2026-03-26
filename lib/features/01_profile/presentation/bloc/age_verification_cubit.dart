import 'package:bloc/bloc.dart';

class AgeVerificationState {
  final String question;
  final int answer;
  final bool? isVerified;
  final String? error;

  AgeVerificationState({
    required this.question,
    required this.answer,
    this.isVerified,
    this.error,
  });

  AgeVerificationState copyWith({
    String? question,
    int? answer,
    bool? isVerified,
    String? error,
  }) {
    return AgeVerificationState(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isVerified: isVerified,
      error: error,
    );
  }
}

class AgeVerificationCubit extends Cubit<AgeVerificationState> {
  AgeVerificationCubit()
      : super(AgeVerificationState(question: '', answer: 0));

  void generateQuestion() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final a = 3 + (now % 7);
    final b = 2 + (now % 5);
    final question = 'Quanto fa $a × $b ?';
    final answer = a * b;
    emit(AgeVerificationState(question: question, answer: answer));
  }

  void verify(int userAnswer) {
    if (userAnswer == state.answer) {
      emit(state.copyWith(isVerified: true, error: null));
    } else {
      emit(state.copyWith(isVerified: false, error: 'Risposta errata'));
    }
  }

  void reset() {
    emit(state.copyWith(isVerified: null, error: null));
  }
}
