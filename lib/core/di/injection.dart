import 'package:get_it/get_it.dart';
import '../../data/local/hive_repository.dart';
import '../../blocs/session/session_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../features/learning/domain/select_words_usecase.dart';
import '../../features/learning/domain/save_session_usecase.dart';
import '../repositories/levels_repository.dart' as levels_repo;
import '../repositories/profiles_repository.dart' as profiles_repo;
import '../repositories/progress_repository.dart' as progress_repo;
import '../repositories/sessions_repository.dart' as sessions_repo;

final GetIt getIt = GetIt.instance;

void configureDependencies(HiveLocalRepository repo) {
  // register concrete repo instances
  getIt.registerSingleton<HiveLocalRepository>(repo);
  // register under repository interfaces
  getIt.registerSingleton<levels_repo.LevelsRepository>(repo);
  getIt.registerSingleton<profiles_repo.ProfilesRepository>(repo);
  getIt.registerSingleton<progress_repo.ProgressRepository>(repo);
  getIt.registerSingleton<sessions_repo.SessionsRepository>(repo);

  // use-cases
  getIt.registerLazySingleton<SelectWordsUseCase>(() => SelectWordsUseCase(sessionSize: SessionBloc.sessionSize));
  getIt.registerLazySingleton<SaveSessionUseCase>(() => SaveSessionUseCase());

  // blocs (factories so UI can obtain fresh instances)
  getIt.registerFactory<SessionBloc>(() => SessionBloc(
        levelsRepository: getIt<levels_repo.LevelsRepository>(),
        progressRepository: getIt<progress_repo.ProgressRepository>(),
        sessionsRepository: getIt<sessions_repo.SessionsRepository>(),
        selector: getIt<SelectWordsUseCase>(),
        saver: getIt<SaveSessionUseCase>(),
      ));
  getIt.registerFactory<ProfileBloc>(() => ProfileBloc(repository: getIt<profiles_repo.ProfilesRepository>(), verificationService: VerificationService()));
}
