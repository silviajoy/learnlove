import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class LevelProgress {
  final String id;
  final String childId;
  final String levelId;
  int bestStars;
  int lastStars;
  int lastCorrectCount;
  int lastTotal;
  DateTime? updatedAt;

  LevelProgress({String? id, required this.childId, required this.levelId, this.bestStars = 0, this.lastStars = 0, this.lastCorrectCount = 0, this.lastTotal = 0, this.updatedAt}) : id = id ?? generateUuid();
}
