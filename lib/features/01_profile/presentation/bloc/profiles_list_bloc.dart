import 'package:bloc/bloc.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfilesListBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfilesRepository repository;

  ProfilesListBloc({required this.repository}) : super(ProfilesLoading()) {
    on<LoadProfiles>((event, emit) async {
      emit(ProfilesLoading());
      try {
        final profiles = await repository.getProfiles();
        emit(ProfilesLoaded(profiles));
      } catch (e) {
        emit(ProfileActionFailure(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      try {
        await repository.updateProfile(event.profile);
        final profiles = await repository.getProfiles();
        emit(ProfilesLoaded(profiles));
      } catch (e) {
        emit(ProfileActionFailure(e.toString()));
      }
    });
  }
}
