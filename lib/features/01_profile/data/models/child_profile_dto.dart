import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart' as domain_model;

@HiveType(typeId: 0)
class ChildProfileDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String avatarAssetPath;

  @HiveField(3)
  int age;

  ChildProfileDto({required this.id, required this.name, required this.avatarAssetPath, required this.age});

  domain_model.ChildProfile toDomain() => domain_model.ChildProfile(id: id, name: name, avatarAssetPath: avatarAssetPath, age: age);

  static ChildProfileDto fromDomain(domain_model.ChildProfile d) => ChildProfileDto(id: d.id, name: d.name, avatarAssetPath: d.avatarAssetPath, age: d.age);
}
