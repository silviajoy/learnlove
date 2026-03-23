import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class ChildProfile {
  final String id;
  final String name;
  final String avatarAssetPath;
  final int age;

  ChildProfile({String? id, required this.name, required this.avatarAssetPath, required this.age}) : id = id ?? generateUuid();
}
