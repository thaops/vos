import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';

class StatusDto {
  final String code;
  final String nameVn;

  StatusDto({
    required this.code,
    required this.nameVn,
  });

  factory StatusDto.fromJson(Map<String, dynamic> json) {
    return StatusDto(
      code: json['Code'] as String? ?? '',
      nameVn: json['Name_VN'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Code': code,
      'Name_VN': nameVn,
    };
  }

  Status toDomain() {
    return Status(
      code: code,
      nameVn: nameVn,
    );
  }

  factory StatusDto.fromDomain(Status domain) {
    return StatusDto(
      code: domain.code,
      nameVn: domain.nameVn,
    );
  }
}

