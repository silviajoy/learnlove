import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';
import 'attempt.dart';

@HiveType(typeId: 5)
class Session extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final String levelId;

  @HiveField(3)
  final DateTime start;

  @HiveField(4)
  DateTime? end;

  @HiveField(5)
  List<Attempt> attempts;

  @HiveField(6)
  int correctCount;

  @HiveField(7)
  int total;

  Session({String? id, required this.childId, required this.levelId, DateTime? start, List<Attempt>? attempts, this.correctCount = 0, this.total = 0})
      : id = id ?? generateUuid(),
        start = start ?? DateTime.now(),
        attempts = attempts ?? [];
}
