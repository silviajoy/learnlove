import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';
import 'attempt.dart';

class Session {
  final String id;
  final String childId;
  final String levelId;
  final DateTime start;
  DateTime? end;
  List<Attempt> attempts;
  int correctCount;
  int total;

  Session({String? id, required this.childId, required this.levelId, DateTime? start, List<Attempt>? attempts, this.correctCount = 0, this.total = 0})
      : id = id ?? generateUuid(),
        start = start ?? DateTime.now(),
        attempts = attempts ?? [];
}
