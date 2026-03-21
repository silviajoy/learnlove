import '../../core/models/child_profile.dart';

abstract class ProfileEvent {}

class LoadProfiles extends ProfileEvent {}

class SelectProfile extends ProfileEvent {
  final String childId;
  SelectProfile(this.childId);
}

class StartCreateProfile extends ProfileEvent {
  final ChildProfile tempProfile;
  StartCreateProfile(this.tempProfile);
}

class SubmitAgeVerification extends ProfileEvent {
  final int answer;
  SubmitAgeVerification(this.answer);
}

class ConfirmCreateProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ChildProfile profile;
  UpdateProfile(this.profile);
}
