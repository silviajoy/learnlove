import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/01_profile/data/models/child_profile_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/image_asset_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/level_progress_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/progress_record_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/session_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/word_dto.dart';

import 'package:impariamo_reading_app/core/models/child_profile.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/image_asset.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/word.dart';
import 'package:impariamo_reading_app/core/repositories/profiles_repository.dart';
import 'package:impariamo_reading_app/core/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/core/repositories/progress_repository.dart';
import 'package:impariamo_reading_app/core/repositories/sessions_repository.dart';

/// Minimal Hive-backed repository implementation. This file provides example
/// methods; extend as needed. The repository abstracts Hive boxes used by the
/// app.
class HiveLocalRepository implements ProfilesRepository, LevelsRepository, ProgressRepository, SessionsRepository {
  final Box<ChildProfileDto> profilesBox;
  final Box<WordDto> wordsBox;
  final Box<ImageAssetDto> imagesBox;
  final Box<ProgressRecordDto> progressBox;
  final Box<LevelProgressDto> levelProgressBox;
  final Box<SessionDto> sessionsBox;

  HiveLocalRepository({required this.profilesBox, required this.wordsBox, required this.imagesBox, required this.progressBox, required this.levelProgressBox, required this.sessionsBox});

  // ProfilesRepository
  @override
  Future<void> addProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, ChildProfileDto.fromDomain(profile));
  }

  @override
  Future<void> deleteProfile(String id) async {
    await profilesBox.delete(id);
  }

  @override
  Future<List<ChildProfile>> getProfiles() async {
    return profilesBox.values.map((d) => d.toDomain()).toList();
  }

  @override
  Future<void> updateProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, ChildProfileDto.fromDomain(profile));
  }

  // LevelsRepository (partial)
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

  // Progress helpers
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

  @override
  Future<void> saveSession(Session session) async {
    await sessionsBox.put(session.id, SessionDto.fromDomain(session));
  }

  @override
  Future<List<Session>> getSessionsForChild(String childId) async {
    return sessionsBox.values.where((s) => s.childId == childId).map((d) => d.toDomain()).toList();
  }
}
