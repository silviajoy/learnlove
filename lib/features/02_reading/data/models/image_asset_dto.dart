import 'package:hive/hive.dart';
import 'package:impariamo_reading_app/features/02_reading/domain/models/image_asset.dart' as domain;

@HiveType(typeId: 2)
class ImageAssetDto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String assetPath;

  ImageAssetDto({required this.id, required this.assetPath});

  domain.ImageAsset toDomain() => domain.ImageAsset(id: id, assetPath: assetPath);
  static ImageAssetDto fromDomain(domain.ImageAsset d) => ImageAssetDto(id: d.id, assetPath: d.assetPath);
}
