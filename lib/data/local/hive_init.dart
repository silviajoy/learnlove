import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/child_profile.dart';
import '../../core/models/word.dart';
import '../../core/models/image_asset.dart';
import '../../core/models/progress_record.dart';
import '../../core/models/attempt.dart';
import '../../core/models/session.dart';
import '../../core/models/level_progress.dart';

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

  await Hive.openBox<ChildProfile>(profilesBoxName);
  await Hive.openBox<Word>(wordsBoxName);
  await Hive.openBox<ImageAsset>(imagesBoxName);
  await Hive.openBox<ProgressRecord>(progressBoxName);
  await Hive.openBox<LevelProgress>(levelProgressBoxName);
  await Hive.openBox<Session>(sessionsBoxName);
}

class _ChildProfileAdapter extends TypeAdapter<ChildProfile> {
  @override
  final typeId = 0;

  @override
  ChildProfile read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final avatar = reader.readString();
    final age = reader.readInt();
    return ChildProfile(id: id, name: name, avatarAssetPath: avatar, age: age);
  }

  @override
  void write(BinaryWriter writer, ChildProfile obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.avatarAssetPath);
    writer.writeInt(obj.age);
  }
}

class _WordAdapter extends TypeAdapter<Word> {
  @override
  final typeId = 1;

  @override
  Word read(BinaryReader reader) {
    final id = reader.readString();
    final text = reader.readString();
    final levelId = reader.readString();
    final imageId = reader.readString();
    return Word(id: id, text: text, levelId: levelId, imageId: imageId);
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.writeString(obj.levelId);
    writer.writeString(obj.imageId);
  }
}

class _ImageAssetAdapter extends TypeAdapter<ImageAsset> {
  @override
  final typeId = 2;

  @override
  ImageAsset read(BinaryReader reader) {
    final id = reader.readString();
    final asset = reader.readString();
    return ImageAsset(id: id, assetPath: asset);
  }

  @override
  void write(BinaryWriter writer, ImageAsset obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.assetPath);
  }
}

class _ProgressRecordAdapter extends TypeAdapter<ProgressRecord> {
  @override
  final typeId = 3;

  @override
  ProgressRecord read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final wordId = reader.readString();
    final completed = reader.readBool();
    final attempts = reader.readInt();
    final hasDate = reader.readBool();
    final lastSeen = hasDate ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    return ProgressRecord(id: id, childId: childId, wordId: wordId, completed: completed, attempts: attempts, lastSeen: lastSeen);
  }

  @override
  void write(BinaryWriter writer, ProgressRecord obj) {
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

class _AttemptAdapter extends TypeAdapter<Attempt> {
  @override
  final typeId = 4;

  @override
  Attempt read(BinaryReader reader) {
    final id = reader.readString();
    final wordId = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final wasCorrect = reader.readBool();
    final attemptNumber = reader.readInt();
    return Attempt(id: id, wordId: wordId, timestamp: timestamp, wasCorrect: wasCorrect, attemptNumber: attemptNumber);
  }

  @override
  void write(BinaryWriter writer, Attempt obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.wordId);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.wasCorrect);
    writer.writeInt(obj.attemptNumber);
  }
}

class _SessionAdapter extends TypeAdapter<Session> {
  @override
  final typeId = 5;

  @override
  Session read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final levelId = reader.readString();
    final start = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasEnd = reader.readBool();
    final end = hasEnd ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final correctCount = reader.readInt();
    final total = reader.readInt();
    final attemptsLen = reader.readInt();
    final attempts = <Attempt>[];
    for (var i = 0; i < attemptsLen; i++) {
      attempts.add(_AttemptAdapter().read(reader));
    }
    return Session(id: id, childId: childId, levelId: levelId, start: start, attempts: attempts, correctCount: correctCount, total: total)
      ..end = end;
  }

  @override
  void write(BinaryWriter writer, Session obj) {
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

class _LevelProgressAdapter extends TypeAdapter<LevelProgress> {
  @override
  final typeId = 6;

  @override
  LevelProgress read(BinaryReader reader) {
    final id = reader.readString();
    final childId = reader.readString();
    final levelId = reader.readString();
    final bestStars = reader.readInt();
    final lastStars = reader.readInt();
    final lastCorrectCount = reader.readInt();
    final lastTotal = reader.readInt();
    final hasDate = reader.readBool();
    final updatedAt = hasDate ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    return LevelProgress(id: id, childId: childId, levelId: levelId, bestStars: bestStars, lastStars: lastStars, lastCorrectCount: lastCorrectCount, lastTotal: lastTotal, updatedAt: updatedAt);
  }

  @override
  void write(BinaryWriter writer, LevelProgress obj) {
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
