import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

abstract class ProfilesRepository {
  Future<List<ChildProfile>> getProfiles();
  Future<void> addProfile(ChildProfile profile);
  Future<void> updateProfile(ChildProfile profile);
  Future<void> deleteProfile(String id);
}
