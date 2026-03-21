import 'package:hive/hive.dart';
import 'uuid_helper.dart';

@HiveType(typeId: 2)
class ImageAsset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String assetPath;

  ImageAsset({String? id, required this.assetPath}) : id = id ?? generateUuid();
}
