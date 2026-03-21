import 'package:hive/hive.dart';
import 'uuid_helper.dart';

@HiveType(typeId: 4)
class Attempt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String wordId;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool wasCorrect;

  @HiveField(4)
  final int attemptNumber;

  Attempt({String? id, required this.wordId, DateTime? timestamp, required this.wasCorrect, this.attemptNumber = 1}) : id = id ?? generateUuid(), timestamp = timestamp ?? DateTime.now();
}
