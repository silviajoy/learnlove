import 'package:hive/hive.dart';
import 'uuid_helper.dart';

@HiveType(typeId: 6)
class LevelProgress extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final String levelId;

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

  LevelProgress({String? id, required this.childId, required this.levelId, this.bestStars = 0, this.lastStars = 0, this.lastCorrectCount = 0, this.lastTotal = 0, this.updatedAt}) : id = id ?? generateUuid();
}
