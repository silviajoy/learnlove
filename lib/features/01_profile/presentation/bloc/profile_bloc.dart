import 'package:bloc/bloc.dart';
import '../../../../core/models/child_profile.dart';
import '../../../../core/repositories/profiles_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Small verification service to generate simple math questions for age verification.
class VerificationService {
  late int a;
  late int b;

  Map<String, dynamic> generateQuestion() {
    a = 3 + (DateTime.now().millisecondsSinceEpoch % 7); // simple pseudo-random
    b = 2 + (DateTime.now().millisecondsSinceEpoch % 5);
    return {'question': 'Quanto fa $a × $b ?', 'answer': a * b};
  }
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfilesRepository repository;
  final VerificationService verificationService;

  ChildProfile? _pendingProfile;
  int? _expectedAnswer;

  ProfileBloc({required this.repository, required this.verificationService}) : super(ProfilesLoading()) {
    on<LoadProfiles>((event, emit) async {
      emit(ProfilesLoading());
      try {
        final profiles = await repository.getProfiles();
        emit(ProfilesLoaded(profiles));
      } catch (e) {
        emit(ProfileActionFailure(e.toString()));
      }
    });

    on<StartCreateProfile>((event, emit) async {
      _pendingProfile = event.tempProfile;
      final q = verificationService.generateQuestion();
      _expectedAnswer = q['answer'] as int;
      emit(CreateProfileInProgress(_pendingProfile!, q['question'] as String));
    });

    on<SubmitAgeVerification>((event, emit) async {
      if (_expectedAnswer == null || _pendingProfile == null) {
        emit(AgeVerificationFailed('Nessuna creazione in corso'));
        return;
      }
      if (event.answer == _expectedAnswer) {
        try {
          await repository.addProfile(_pendingProfile!);
          emit(ProfileCreationSuccess(_pendingProfile!));
          _pendingProfile = null;
          _expectedAnswer = null;
        } catch (e) {
          emit(ProfileActionFailure(e.toString()));
        }
      } else {
        emit(AgeVerificationFailed('Risposta errata. Riprova.'));
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
