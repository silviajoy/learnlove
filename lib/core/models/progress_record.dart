import 'package:hive/hive.dart';
import 'uuid_helper.dart';

@HiveType(typeId: 3)
class ProgressRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final String wordId;

  @HiveField(3)
  bool completed;

  @HiveField(4)
  int attempts;

  @HiveField(5)
  DateTime? lastSeen;

  ProgressRecord({String? id, required this.childId, required this.wordId, this.completed = false, this.attempts = 0, this.lastSeen}) : id = id ?? generateUuid();
}
