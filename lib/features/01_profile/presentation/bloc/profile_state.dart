import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

abstract class ProfileState {}

class ProfilesLoading extends ProfileState {}

class ProfilesLoaded extends ProfileState {
  final List<ChildProfile> profiles;
  ProfilesLoaded(this.profiles);
}


class ProfileActionSuccess extends ProfileState {
  final ChildProfile profile;
  ProfileActionSuccess(this.profile);
}

class ProfileActionFailure extends ProfileState {
  final String error;
  ProfileActionFailure(this.error);
}
