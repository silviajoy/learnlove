import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:impariamo_reading_app/features/02_reading/domain/models/image_asset.dart';
import 'package:impariamo_reading_app/data/models/image_asset_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';
import 'hive_repository.dart';

/// Loads seed data from assets/configs and preloads them into Hive via the
/// provided repository.
class Seeder {
  final dynamic repo; // accepts a reading repo implementing saveImageAsset & preloadLevelWords
  Seeder(this.repo);
  /// Seeds all levels listed in `assets/configs/levels_index.json`.
  /// Each entry should be the level config filename (e.g. `level_1.json`).
  Future<void> seedAllLevels() async {
    final indexStr = await rootBundle.loadString('assets/configs/levels_index.json');
    final files = (json.decode(indexStr) as List<dynamic>).cast<String>();

    for (final cfgFile in files) {
      try {
        final cfgStr = await rootBundle.loadString('assets/configs/$cfgFile');
        final cfg = json.decode(cfgStr) as Map<String, dynamic>;
        final levelId = cfg['id'] as String;

        // determine words filename: prefer explicit `words` field in level config
        String wordsFile;
        if (cfg.containsKey('words') && cfg['words'] is String) {
          final raw = cfg['words'] as String;
          wordsFile = raw.startsWith('assets/') ? raw : 'assets/configs/$raw';
        } else {
          // fallback: derive from level id: level-1 -> level_1 -> words_level_1.json
          final levelKey = levelId.replaceAll('-', '_');
          wordsFile = 'assets/configs/words_${levelKey}.json';
        }

        // load words if present
        List<Word> words = [];
        try {
          final wordsStr = await rootBundle.loadString(wordsFile);
          final list = json.decode(wordsStr) as List<dynamic>;
          for (final item in list) {
            final text = item['text'] as String;
            final imgPath = item['image'] as String;
            final img = ImageAsset(assetPath: imgPath);
            await repo.saveImageAsset(img);
            final word = Word(text: text, levelId: levelId, imageId: img.id);
            words.add(word);
          }
          if (words.isNotEmpty) {
            await repo.preloadLevelWords(levelId, words);
          }
        } catch (_) {
          // no words file for this level - skip
        }

        // Optionally ensure a placeholder LevelProgress for demo child exists.
        final demoChild = 'demo-child';
        final existing = await repo.getLevelProgress(demoChild, levelId);
        if (existing == null) {
          final dummyProgress = LevelProgress(childId: demoChild, levelId: levelId);
          await repo.saveLevelProgress(dummyProgress);
        }
      } catch (_) {
        // ignore malformed or missing config entries
      }
    }
  }
}
