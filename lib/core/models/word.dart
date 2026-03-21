import 'package:hive/hive.dart';
import 'uuid_helper.dart';

@HiveType(typeId: 1)
class Word extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String levelId;

  @HiveField(3)
  final String imageId;

  Word({String? id, required this.text, required this.levelId, required this.imageId}) : id = id ?? generateUuid();
}
