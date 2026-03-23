import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/session.dart' as domain;
import 'attempt_dto.dart';

@HiveType(typeId: 5)
class SessionDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String childId;

  @HiveField(2)
  String levelId;

  @HiveField(3)
  DateTime start;

  @HiveField(4)
  DateTime? end;

  @HiveField(5)
  List<AttemptDto> attempts;

  @HiveField(6)
  int correctCount;

  @HiveField(7)
  int total;

  SessionDto({required this.id, required this.childId, required this.levelId, required this.start, this.end, required this.attempts, required this.correctCount, required this.total});

  domain.Session toDomain() => domain.Session(id: id, childId: childId, levelId: levelId, start: start, attempts: attempts.map((a) => a.toDomain()).toList(), correctCount: correctCount, total: total)..end = end;

  static SessionDto fromDomain(domain.Session d) => SessionDto(id: d.id, childId: d.childId, levelId: d.levelId, start: d.start, end: d.end, attempts: d.attempts.map((a) => AttemptDto.fromDomain(a)).toList(), correctCount: d.correctCount, total: d.total);
}
