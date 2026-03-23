import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/level_progress.dart' as domain;

@HiveType(typeId: 6)
class LevelProgressDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String childId;

  @HiveField(2)
  String levelId;

  @HiveField(3)
  int bestStars;

  @HiveField(4)
  int lastStars;

  @HiveField(5)
  int lastCorrectCount;

  @HiveField(6)
  int lastTotal;

  @HiveField(7)
  DateTime? updatedAt;

  LevelProgressDto({required this.id, required this.childId, required this.levelId, required this.bestStars, required this.lastStars, required this.lastCorrectCount, required this.lastTotal, this.updatedAt});

  domain.LevelProgress toDomain() => domain.LevelProgress(id: id, childId: childId, levelId: levelId, bestStars: bestStars, lastStars: lastStars, lastCorrectCount: lastCorrectCount, lastTotal: lastTotal, updatedAt: updatedAt);
  static LevelProgressDto fromDomain(domain.LevelProgress d) => LevelProgressDto(id: d.id, childId: d.childId, levelId: d.levelId, bestStars: d.bestStars, lastStars: d.lastStars, lastCorrectCount: d.lastCorrectCount, lastTotal: d.lastTotal, updatedAt: d.updatedAt);
}
