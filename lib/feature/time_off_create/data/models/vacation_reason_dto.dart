import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';

class VacationReasonDto {
  final String code;
  final String nameVn;

  VacationReasonDto({
    required this.code,
    required this.nameVn,
  });

  factory VacationReasonDto.fromJson(Map<String, dynamic> json) {
    return VacationReasonDto(
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

  VacationReason toDomain() {
    return VacationReason(
      code: code,
      nameVn: nameVn,
    );
  }

  factory VacationReasonDto.fromDomain(VacationReason domain) {
    return VacationReasonDto(
      code: domain.code,
      nameVn: domain.nameVn,
    );
  }
}

