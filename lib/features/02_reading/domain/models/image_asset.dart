import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class ImageAsset {
  final String id;
  final String assetPath;

  ImageAsset({String? id, required this.assetPath}) : id = id ?? generateUuid();
}
