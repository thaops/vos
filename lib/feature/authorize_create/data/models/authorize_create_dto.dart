import 'package:vos_flutter/feature/authorize_create/domain/models/authorize_create.dart';

class AuthorizeCreateDto {
  final String id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AuthorizeCreateDto({
    required this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory AuthorizeCreateDto.fromJson(Map<String, dynamic> json) {
    return AuthorizeCreateDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  factory AuthorizeCreateDto.fromDomain(AuthorizeCreate entity) {
    return AuthorizeCreateDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      thumbnailUrl: entity.thumbnailUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  AuthorizeCreate toDomain() {
    return AuthorizeCreate(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

