import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive/hive.dart';
import 'data/local/hive_init.dart';
import 'data/local/hive_repository.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/entities/child_profile.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/image_asset.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/level_progress.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/progress_record.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/session.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/entities/word.dart';
import 'data/local/seed.dart';
import 'features/01_profile/presentation/bloc/profile_bloc.dart';
import 'features/02_reading/presentation/bloc/session_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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

  // configure DI for get_it
  configureDependencies(repo);
  final router = AppRouter.createRouter();

  runApp(RepositoryProvider<LevelsRepository>.value(
    value: repo,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.instance<ProfileBloc>()),
        BlocProvider(create: (context) => GetIt.instance<SessionBloc>()),
      ],
      child: MyApp(router: router),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Impariamo',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
