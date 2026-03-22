import 'package:flutter_test/flutter_test.dart';
import 'package:impariamo_reading_app/features/learning/domain/select_words_usecase.dart';

void main() {
  test('SelectWordsUseCase constructs with default sessionSize', () {
    final usecase = SelectWordsUseCase();
    expect(usecase.sessionSize, 10);
  });
}
