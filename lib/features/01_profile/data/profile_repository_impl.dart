import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/models/child_profile.dart';
import 'package:impariamo_reading_app/features/01_profile/domain/repositories/profiles_repository.dart';
import 'models/child_profile_dto.dart';

class ProfileHiveRepository implements ProfilesRepository {
  final Box<ChildProfileDto> profilesBox;

  ProfileHiveRepository({required this.profilesBox});

  @override
  Future<void> addProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, ChildProfileDto.fromDomain(profile));
  }

  @override
  Future<void> deleteProfile(String id) async {
    await profilesBox.delete(id);
  }

  @override
  Future<List<ChildProfile>> getProfiles() async {
    return profilesBox.values.map((d) => d.toDomain()).toList();
  }

  @override
  Future<void> updateProfile(ChildProfile profile) async {
    await profilesBox.put(profile.id, ChildProfileDto.fromDomain(profile));
  }
}
