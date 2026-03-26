import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';

abstract class ProfilesRepository {
  Future<List<ChildProfile>> getProfiles();
  Future<ChildProfile> addProfile(ChildProfile profile);
  Future<ChildProfile> updateProfile(ChildProfile profile);
  Future<void> deleteProfile(String id);
}
