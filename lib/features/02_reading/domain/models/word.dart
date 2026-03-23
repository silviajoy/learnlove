import 'package:impariamo_reading_app/core/utils/uuid_helper.dart';

class Word {
  final String id;
  final String text;
  final String levelId;
  final String imageId;

  Word({String? id, required this.text, required this.levelId, required this.imageId}) : id = id ?? generateUuid();
}
