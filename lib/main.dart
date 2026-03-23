import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hive/hive.dart';
import 'data/local/hive_init.dart';
import 'features/01_profile/data/repositories/profile_repository_impl.dart';
import 'features/02_reading/data/reading_repository_impl.dart';
import 'package:impariamo_reading_app/features/01_profile/data/models/child_profile_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/image_asset_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/level_progress_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/progress_record_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/session_dto.dart';
import 'package:impariamo_reading_app/features/02_reading/data/models/word_dto.dart';
import 'data/local/seed.dart';
import 'features/01_profile/presentation/bloc/profiles_list_bloc.dart';
import 'features/01_profile/presentation/bloc/profile_creation_bloc.dart';
import 'features/02_reading/presentation/bloc/session_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  final profilesBox = Hive.box<ChildProfileDto>(profilesBoxName);
  final wordsBox = Hive.box<WordDto>(wordsBoxName);
  final imagesBox = Hive.box<ImageAssetDto>(imagesBoxName);
  final progressBox = Hive.box<ProgressRecordDto>(progressBoxName);
  final levelProgressBox = Hive.box<LevelProgressDto>(levelProgressBoxName);
  final sessionsBox = Hive.box<SessionDto>(sessionsBoxName);

  final profileRepo = ProfileHiveRepository(profilesBox: profilesBox);
  final readingRepo = ReadingHiveRepository(
    wordsBox: wordsBox,
    imagesBox: imagesBox,
    progressBox: progressBox,
    levelProgressBox: levelProgressBox,
    sessionsBox: sessionsBox,
  );

  // Seed sample data (safe to call repeatedly)
  final seeder = Seeder(readingRepo);
  await seeder.seedAllLevels();

  // configure DI for get_it with feature repos
  configureDependencies(profilesRepo: profileRepo, levelsRepo: readingRepo, progressRepo: readingRepo, sessionsRepo: readingRepo);
  final router = AppRouter.createRouter();

  runApp(RepositoryProvider.value(
    value: readingRepo,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.instance<ProfilesListBloc>()),
        BlocProvider(create: (context) => GetIt.instance<ProfileCreationBloc>()),
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
