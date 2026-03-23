import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/image_asset.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/progress_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/sessions_repository.dart';
import 'models/word_dto.dart';
import 'models/image_asset_dto.dart';
import 'models/progress_record_dto.dart';
import 'models/level_progress_dto.dart';
import 'models/session_dto.dart';

class ReadingHiveRepository implements LevelsRepository, ProgressRepository, SessionsRepository {
  final Box<WordDto> wordsBox;
  final Box<ImageAssetDto> imagesBox;
  final Box<ProgressRecordDto> progressBox;
  final Box<LevelProgressDto> levelProgressBox;
  final Box<SessionDto> sessionsBox;

  ReadingHiveRepository({required this.wordsBox, required this.imagesBox, required this.progressBox, required this.levelProgressBox, required this.sessionsBox});

  // LevelsRepository
  @override
  Future<List<Word>> getWordsForLevel(String levelId) async {
    return wordsBox.values.where((w) => w.levelId == levelId).map((d) => d.toDomain()).toList();
  }

  @override
  Future<void> preloadLevelWords(String levelId, List<Word> words) async {
    for (final w in words) {
      await wordsBox.put(w.id, WordDto.fromDomain(w));
    }
  }

  @override
  Future<LevelProgress?> getLevelProgress(String childId, String levelId) async {
    try {
      final dto = levelProgressBox.values.firstWhere((p) => p.childId == childId && p.levelId == levelId);
      return dto.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    await levelProgressBox.put(progress.id, LevelProgressDto.fromDomain(progress));
  }

  @override
  Future<ImageAsset?> getImageAsset(String imageId) async {
    try {
      final dto = imagesBox.get(imageId);
      return dto?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveImageAsset(ImageAsset asset) async {
    await imagesBox.put(asset.id, ImageAssetDto.fromDomain(asset));
  }

  // ProgressRepository
  @override
  Future<void> saveProgressRecord(ProgressRecord record) async {
    await progressBox.put(record.id, ProgressRecordDto.fromDomain(record));
  }

  @override
  Future<ProgressRecord?> getProgressForChildWord(String childId, String wordId) async {
    try {
      final dto = progressBox.values.firstWhere((p) => p.childId == childId && p.wordId == wordId);
      return dto.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProgressRecord>> getProgressForChild(String childId) async {
    return progressBox.values.where((p) => p.childId == childId).map((d) => d.toDomain()).toList();
  }

  // SessionsRepository
  @override
  Future<void> saveSession(Session session) async {
    await sessionsBox.put(session.id, SessionDto.fromDomain(session));
  }

  @override
  Future<List<Session>> getSessionsForChild(String childId) async {
    return sessionsBox.values.where((s) => s.childId == childId).map((d) => d.toDomain()).toList();
  }
}
