import 'package:impariamo_reading_app/features/02_reading/domain/models/image_asset.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';

abstract class LevelsRepository {
  Future<List<Word>> getWordsForLevel(String levelId);
  Future<void> preloadLevelWords(String levelId, List<Word> words);
  Future<LevelProgress?> getLevelProgress(String childId, String levelId);
  Future<void> saveLevelProgress(LevelProgress progress);
  Future<ImageAsset?> getImageAsset(String imageId);
  Future<void> saveImageAsset(ImageAsset asset);
}
