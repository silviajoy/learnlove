import 'package:get_it/get_it.dart';
import '../../features/02_reading/presentation/bloc/session_bloc.dart';
import '../../features/01_profile/presentation/bloc/profiles_list_bloc.dart';
import '../../features/01_profile/presentation/bloc/profile_creation_bloc.dart';
import '../../features/02_reading/domain/usecases/select_words_usecase.dart';
import '../../features/02_reading/domain/usecases/save_session_usecase.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart' as profiles_repo;
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/levels_repository.dart' as levels_repo;
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/progress_repository.dart' as progress_repo;
import 'package:impariamo_reading_app/features/02_reading/domain/repositories/sessions_repository.dart' as sessions_repo;

final GetIt getIt = GetIt.instance;

void configureDependencies({required profiles_repo.ProfilesRepository profilesRepo, required levels_repo.LevelsRepository levelsRepo, required progress_repo.ProgressRepository progressRepo, required sessions_repo.SessionsRepository sessionsRepo}) {
  // register concrete repo instances under interfaces
  getIt.registerSingleton<profiles_repo.ProfilesRepository>(profilesRepo);
  getIt.registerSingleton<levels_repo.LevelsRepository>(levelsRepo);
  getIt.registerSingleton<progress_repo.ProgressRepository>(progressRepo);
  getIt.registerSingleton<sessions_repo.SessionsRepository>(sessionsRepo);

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
  getIt.registerFactory<ProfilesListBloc>(() => ProfilesListBloc(repository: getIt<profiles_repo.ProfilesRepository>()));
  getIt.registerFactory<ProfileCreationBloc>(() => ProfileCreationBloc(repository: getIt<profiles_repo.ProfilesRepository>(), verificationService: VerificationService()));
}
