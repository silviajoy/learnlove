import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/attempt.dart' as domain;

@HiveType(typeId: 4)
class AttemptDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String wordId;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  bool wasCorrect;

  @HiveField(4)
  int attemptNumber;

  AttemptDto({required this.id, required this.wordId, required this.timestamp, required this.wasCorrect, required this.attemptNumber});

  domain.Attempt toDomain() => domain.Attempt(id: id, wordId: wordId, timestamp: timestamp, wasCorrect: wasCorrect, attemptNumber: attemptNumber);
  static AttemptDto fromDomain(domain.Attempt d) => AttemptDto(id: d.id, wordId: d.wordId, timestamp: d.timestamp, wasCorrect: d.wasCorrect, attemptNumber: d.attemptNumber);
}
