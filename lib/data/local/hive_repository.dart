import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/entities/child_profile.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/image_asset.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/word.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/progress_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/sessions_repository.dart';

/// Minimal Hive-backed repository implementation. This file provides example
/// methods; extend as needed. The repository abstracts Hive boxes used by the
/// app.
class HiveLocalRepository implements ProfilesRepository, LevelsRepository, ProgressRepository, SessionsRepository {
  final Box<ChildProfile> profilesBox;
  final Box<Word> wordsBox;
  final Box<ImageAsset> imagesBox;
  final Box<ProgressRecord> progressBox;
  final Box<LevelProgress> levelProgressBox;
  final Box<Session> sessionsBox;
  
  HiveLocalRepository({required this.profilesBox, required this.wordsBox, required this.imagesBox, required this.progressBox, required this.levelProgressBox, required this.sessionsBox});

  // ProfilesRepository
  @override
  Future<void> addProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, profile);
  }

  @override
  Future<void> deleteProfile(String id) async {
    await profilesBox.delete(id);
  }

  @override
  Future<List<ChildProfile>> getProfiles() async {
    return profilesBox.values.toList();
  }

  @override
  Future<void> updateProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, profile);
  }

  // LevelsRepository (partial)
  @override
  Future<List<Word>> getWordsForLevel(String levelId) async {
    return wordsBox.values.where((w) => w.levelId == levelId).toList();
  }

  @override
  Future<void> preloadLevelWords(String levelId, List<Word> words) async {
    for (final w in words) {
      await wordsBox.put(w.id, w);
    }
  }

  @override
  Future<LevelProgress?> getLevelProgress(String childId, String levelId) async {
    try {
      return levelProgressBox.values.firstWhere((p) => p.childId == childId && p.levelId == levelId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLevelProgress(LevelProgress progress) async {
    await levelProgressBox.put(progress.id, progress);
  }

  @override
  Future<ImageAsset?> getImageAsset(String imageId) async {
    try {
      return imagesBox.get(imageId);
    } catch (_) {
      return null;
    }
  }

  // Progress helpers
  @override
  Future<void> saveProgressRecord(ProgressRecord record) async {
    await progressBox.put(record.id, record);
  }

  @override
  Future<ProgressRecord?> getProgressForChildWord(String childId, String wordId) async {
    try {
      return progressBox.values.firstWhere((p) => p.childId == childId && p.wordId == wordId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ProgressRecord>> getProgressForChild(String childId) async {
    return progressBox.values.where((p) => p.childId == childId).toList();
  }

  @override
  Future<void> saveSession(Session session) async {
    await sessionsBox.put(session.id, session);
  }

  @override
  Future<List<Session>> getSessionsForChild(String childId) async {
    return sessionsBox.values.where((s) => s.childId == childId).toList();
  }
}
