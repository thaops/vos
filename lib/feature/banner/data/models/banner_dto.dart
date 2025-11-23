import 'package:vos_flutter/feature/banner/domain/models/banner.dart';

class BannerDto {
  final int id;
  final String type;
  final String imageUrl;
  final String actionUrl;
  final String updatedDate;

  BannerDto({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.actionUrl,
    required this.updatedDate,
  });

  factory BannerDto.fromJson(Map<String, dynamic> json) {
    return BannerDto(
      id: json['Id'] as int? ?? 0,
      type: json['Type'] as String? ?? '',
      imageUrl: json['ImageUrl'] as String? ?? '',
      actionUrl: json['ActionUrl'] as String? ?? '',
      updatedDate: json['UpdatedDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Type': type,
      'ImageUrl': imageUrl,
      'ActionUrl': actionUrl,
      'UpdatedDate': updatedDate,
    };
  }

  Banner toDomain() {
    return Banner(
      id: id,
      type: type,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      updatedDate: updatedDate,
    );
  }
}

