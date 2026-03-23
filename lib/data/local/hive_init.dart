import 'package:hive_flutter/hive_flutter.dart';
import 'package:impariamo_reading_app/features/01_profile/data/models/child_profile_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/attempt_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/image_asset_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/level_progress_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/progress_record_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/session_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/word_dto.dart';

const String profilesBoxName = 'profilesBox';
const String wordsBoxName = 'wordsBox';
const String imagesBoxName = 'imagesBox';
const String progressBoxName = 'progressBox';
const String levelProgressBoxName = 'levelProgressBox';
const String sessionsBoxName = 'sessionsBox';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register adapters manually. TypeIds must match those used in models.
  Hive.registerAdapter(_ChildProfileAdapter());
  Hive.registerAdapter(_WordAdapter());
  Hive.registerAdapter(_ImageAssetAdapter());
  Hive.registerAdapter(_ProgressRecordAdapter());
  Hive.registerAdapter(_AttemptAdapter());
  Hive.registerAdapter(_SessionAdapter());
  Hive.registerAdapter(_LevelProgressAdapter());

  await Hive.openBox<ChildProfileDto>(profilesBoxName);
  await Hive.openBox<WordDto>(wordsBoxName);
  await Hive.openBox<ImageAssetDto>(imagesBoxName);
  await Hive.openBox<ProgressRecordDto>(progressBoxName);
  await Hive.openBox<LevelProgressDto>(levelProgressBoxName);
  await Hive.openBox<SessionDto>(sessionsBoxName);
}

class _ChildProfileAdapter extends TypeAdapter<ChildProfileDto> {
  @override
  final typeId = 0;
  @override
  ChildProfileDto read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final avatar = reader.readString();
    final age = reader.readInt();
    return ChildProfileDto(id: id, name: name, avatarAssetPath: avatar, age: age);
  }

  @override
  void write(BinaryWriter writer, ChildProfileDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.avatarAssetPath);
    writer.writeInt(obj.age);
  }
}

class _WordAdapter extends TypeAdapter<WordDto> {
  @override
  final typeId = 1;

  @override
  WordDto read(BinaryReader reader) {
    final id = reader.readString();
    final text = reader.readString();
    final levelId = reader.readString();
    final imageId = reader.readString();
    return WordDto(id: id, text: text, levelId: levelId, imageId: imageId);
  }

  @override
  void write(BinaryWriter writer, WordDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.writeString(obj.levelId);
    writer.writeString(obj.imageId);
  }
}

class _ImageAssetAdapter extends TypeAdapter<ImageAssetDto> {
  @override
  final typeId = 2;

  @override
  ImageAssetDto read(BinaryReader reader) {
    final id = reader.readString();
    final asset = reader.readString();
    return ImageAssetDto(id: id, assetPath: asset);
  }

  @override
  void write(BinaryWriter writer, ImageAssetDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.assetPath);
  }
}

class _ProgressRecordAdapter extends TypeAdapter<ProgressRecordDto> {
  @override
  final typeId = 3;

  @override
  ProgressRecordDto read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final wordId = reader.readString();
    final completed = reader.readBool();
    final attempts = reader.readInt();
    final hasDate = reader.readBool();
    final lastSeen = hasDate ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    return ProgressRecordDto(id: id, childId: childId, wordId: wordId, completed: completed, attempts: attempts, lastSeen: lastSeen);
  }

  @override
  void write(BinaryWriter writer, ProgressRecordDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.childId);
    writer.writeString(obj.wordId);
    writer.writeBool(obj.completed);
    writer.writeInt(obj.attempts);
    if (obj.lastSeen != null) {
      writer.writeBool(true);
      writer.writeInt(obj.lastSeen!.millisecondsSinceEpoch);
    } else {
      writer.writeBool(false);
    }
  }
}

class _AttemptAdapter extends TypeAdapter<AttemptDto> {
  @override
  final typeId = 4;

  @override
  AttemptDto read(BinaryReader reader) {
    final id = reader.readString();
    final wordId = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final wasCorrect = reader.readBool();
    final attemptNumber = reader.readInt();
    return AttemptDto(id: id, wordId: wordId, timestamp: timestamp, wasCorrect: wasCorrect, attemptNumber: attemptNumber);
  }

  @override
  void write(BinaryWriter writer, AttemptDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.wordId);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.wasCorrect);
    writer.writeInt(obj.attemptNumber);
  }
}

class _SessionAdapter extends TypeAdapter<SessionDto> {
  @override
  final typeId = 5;

  @override
  SessionDto read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final levelId = reader.readString();
    final start = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasEnd = reader.readBool();
    final end = hasEnd ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final correctCount = reader.readInt();
    final total = reader.readInt();
    final attemptsLen = reader.readInt();
    final attempts = <AttemptDto>[];
    for (var i = 0; i < attemptsLen; i++) {
      attempts.add(_AttemptAdapter().read(reader));
    }
    final dto = SessionDto(id: id, childId: childId, levelId: levelId, start: start, attempts: attempts, correctCount: correctCount, total: total);
    dto.end = end;
    return dto;
  }

  @override
  void write(BinaryWriter writer, SessionDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.childId);
    writer.writeString(obj.levelId);
    writer.writeInt(obj.start.millisecondsSinceEpoch);
    if (obj.end != null) {
      writer.writeBool(true);
      writer.writeInt(obj.end!.millisecondsSinceEpoch);
    } else {
      writer.writeBool(false);
    }
    writer.writeInt(obj.correctCount);
    writer.writeInt(obj.total);
    writer.writeInt(obj.attempts.length);
    for (final a in obj.attempts) {
      _AttemptAdapter().write(writer, a);
    }
  }
}

class _LevelProgressAdapter extends TypeAdapter<LevelProgressDto> {
  @override
  final typeId = 6;

  @override
  LevelProgressDto read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final levelId = reader.readString();
    final bestStars = reader.readInt();
    final lastStars = reader.readInt();
    final lastCorrectCount = reader.readInt();
    final lastTotal = reader.readInt();
    final hasDate = reader.readBool();
    final updatedAt = hasDate ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    return LevelProgressDto(id: id, childId: childId, levelId: levelId, bestStars: bestStars, lastStars: lastStars, lastCorrectCount: lastCorrectCount, lastTotal: lastTotal, updatedAt: updatedAt);
  }

  @override
  void write(BinaryWriter writer, LevelProgressDto obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.childId);
    writer.writeString(obj.levelId);
    writer.writeInt(obj.bestStars);
    writer.writeInt(obj.lastStars);
    writer.writeInt(obj.lastCorrectCount);
    writer.writeInt(obj.lastTotal);
    if (obj.updatedAt != null) {
      writer.writeBool(true);
      writer.writeInt(obj.updatedAt!.millisecondsSinceEpoch);
    } else {
      writer.writeBool(false);
    }
  }
}
