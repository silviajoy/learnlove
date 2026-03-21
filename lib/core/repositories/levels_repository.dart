import '../models/level_progress.dart';
import '../models/word.dart';
import '../models/image_asset.dart';

abstract class LevelsRepository {
  Future<List<Word>> getWordsForLevel(String levelId);
  Future<void> preloadLevelWords(String levelId, List<Word> words);
  Future<LevelProgress?> getLevelProgress(String childId, String levelId);
  Future<void> saveLevelProgress(LevelProgress progress);
  Future<ImageAsset?> getImageAsset(String imageId);
}
