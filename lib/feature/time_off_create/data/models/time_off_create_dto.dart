import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create.dart';

class TimeOffCreateDto {
  final String id;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TimeOffCreateDto({
    required this.id,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeOffCreateDto.fromJson(Map<String, dynamic> json) {
    return TimeOffCreateDto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  factory TimeOffCreateDto.fromDomain(TimeOffCreate entity) {
    return TimeOffCreateDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  TimeOffCreate toDomain() {
    return TimeOffCreate(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

