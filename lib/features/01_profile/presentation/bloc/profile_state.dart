import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

abstract class ProfileState {}

class ProfilesLoading extends ProfileState {}

class ProfilesLoaded extends ProfileState {
  final List<ChildProfile> profiles;
  ProfilesLoaded(this.profiles);
}

class CreateProfileInProgress extends ProfileState {
  final ChildProfile tempProfile;
  final String verificationQuestion;
  CreateProfileInProgress(this.tempProfile, this.verificationQuestion);
}

class AgeVerificationFailed extends ProfileState {
  final String reason;
  AgeVerificationFailed(this.reason);
}

class ProfileCreationSuccess extends ProfileState {
  final ChildProfile profile;
  ProfileCreationSuccess(this.profile);
}

class ProfileActionFailure extends ProfileState {
  final String error;
  ProfileActionFailure(this.error);
}
