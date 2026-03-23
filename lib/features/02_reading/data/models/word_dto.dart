import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart' as domain;

@HiveType(typeId: 1)
class WordDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  String levelId;

  @HiveField(3)
  String imageId;

  WordDto({required this.id, required this.text, required this.levelId, required this.imageId});

  domain.Word toDomain() => domain.Word(id: id, text: text, levelId: levelId, imageId: imageId);
  static WordDto fromDomain(domain.Word d) => WordDto(id: d.id, text: d.text, levelId: d.levelId, imageId: d.imageId);
}
