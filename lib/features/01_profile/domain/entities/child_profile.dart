import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

@HiveType(typeId: 0)
class ChildProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String avatarAssetPath;

  @HiveField(3)
  final int age;

  ChildProfile({String? id, required this.name, required this.avatarAssetPath, required this.age}) : id = id ?? generateUuid();
}
