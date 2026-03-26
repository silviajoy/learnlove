import 'package:bloc/bloc.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart';
import 'profile_state.dart';

class ProfilesListCubit extends Cubit<ProfileState> {
  final ProfilesRepository repository;

  ProfilesListCubit({required this.repository}) : super(ProfilesLoading());

  Future<void> loadProfiles() async {
    emit(ProfilesLoading());
    try {
      final profiles = await repository.getProfiles();
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileActionFailure(e.toString()));
    }
  }

  Future<void> updateProfile(ChildProfile profile) async {
    try {
      await repository.updateProfile(profile);
      final profiles = await repository.getProfiles();
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileActionFailure(e.toString()));
    }
  }

  Future<void> deleteProfile(String childId) async {
    try {
      await repository.deleteProfile(childId);
      final profiles = await repository.getProfiles();
      emit(ProfilesLoaded(profiles));
    } catch (e) {
      emit(ProfileActionFailure(e.toString()));
    }
  }
}
