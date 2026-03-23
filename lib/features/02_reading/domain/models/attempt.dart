import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class Attempt {
  final String id;
  final String wordId;
  final DateTime timestamp;
  final bool wasCorrect;
  final int attemptNumber;

  Attempt({String? id, required this.wordId, DateTime? timestamp, required this.wasCorrect, this.attemptNumber = 1}) : id = id ?? generateUuid(), timestamp = timestamp ?? DateTime.now();
}
