import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive/hive.dart';
import 'data/local/hive_init.dart';
import 'data/local/hive_repository.dart';
import 'core/repositories/levels_repository.dart';
import 'core/models/child_profile.dart';
import 'core/models/word.dart';
import 'core/models/image_asset.dart';
import 'core/models/progress_record.dart';
import 'core/models/level_progress.dart';
import 'core/models/session.dart';
import 'data/local/seed.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/session/session_bloc.dart';
import 'ui/screens/profile_select.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  final profilesBox = Hive.box<ChildProfile>(profilesBoxName);
  final wordsBox = Hive.box<Word>(wordsBoxName);
  final imagesBox = Hive.box<ImageAsset>(imagesBoxName);
  final progressBox = Hive.box<ProgressRecord>(progressBoxName);
  final levelProgressBox = Hive.box<LevelProgress>(levelProgressBoxName);
  final sessionsBox = Hive.box<Session>(sessionsBoxName);

  final repo = HiveLocalRepository(
    profilesBox: profilesBox,
    wordsBox: wordsBox,
    imagesBox: imagesBox,
    progressBox: progressBox,
    levelProgressBox: levelProgressBox,
    sessionsBox: sessionsBox,
  );

  // Seed sample data (safe to call repeatedly)
  final seeder = Seeder(repo);
  await seeder.seedAllLevels();

  final profileBloc = ProfileBloc(repository: repo, verificationService: VerificationService());
  final sessionBloc = SessionBloc(repository: repo);

  runApp(RepositoryProvider<LevelsRepository>.value(
    value: repo,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<SessionBloc>.value(value: sessionBloc),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impariamo',
      theme: ThemeData.light(),
      home: const ProfileSelectScreen(),
    );
  }
}
