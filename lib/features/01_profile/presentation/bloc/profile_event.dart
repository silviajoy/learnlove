import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

abstract class ProfileEvent {}

class LoadProfiles extends ProfileEvent {}

class SelectProfile extends ProfileEvent {
  final String childId;
  SelectProfile(this.childId);
}

class CreateProfile extends ProfileEvent {
  final ChildProfile profile;
  CreateProfile(this.profile);
}
class UpdateProfile extends ProfileEvent {
  final ChildProfile profile;
  UpdateProfile(this.profile);
}

class DeleteProfile extends ProfileEvent {
  final String childId;
  DeleteProfile(this.childId);
}
