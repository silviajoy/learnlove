
import 'package:bloc/bloc.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileCreationBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfilesRepository repository;

  ProfileCreationBloc({required this.repository}) : super(ProfilesLoading()) {
    on<CreateProfile>(_onCreateProfile);
  }

  Future<void> _onCreateProfile(CreateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfilesLoading());
    try {
      final newProfile = await repository.addProfile(event.profile);
      emit(ProfileActionSuccess(newProfile));
    } catch (e) {
      emit(ProfileActionFailure(e.toString()));
    }
  }
}
