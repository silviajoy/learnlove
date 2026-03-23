import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/progress_record.dart' as domain;

@HiveType(typeId: 3)
class ProgressRecordDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String childId;

  @HiveField(2)
  String wordId;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  int attempts;

  @HiveField(5)
  DateTime? lastSeen;

  ProgressRecordDto({required this.id, required this.childId, required this.wordId, required this.completed, required this.attempts, this.lastSeen});

  domain.ProgressRecord toDomain() => domain.ProgressRecord(id: id, childId: childId, wordId: wordId, completed: completed, attempts: attempts, lastSeen: lastSeen);
  static ProgressRecordDto fromDomain(domain.ProgressRecord d) => ProgressRecordDto(id: d.id, childId: d.childId, wordId: d.wordId, completed: d.completed, attempts: d.attempts, lastSeen: d.lastSeen);
}
