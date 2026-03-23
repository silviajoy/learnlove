import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class ProgressRecord {
  final String id;
  final String childId;
  final String wordId;
  bool completed;
  int attempts;
  DateTime? lastSeen;

  ProgressRecord({String? id, required this.childId, required this.wordId, this.completed = false, this.attempts = 0, this.lastSeen}) : id = id ?? generateUuid();
}
