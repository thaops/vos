import 'package:vos_flutter/feature/time_off/domain/models/time_off_status.dart';

class TimeOffStatusDto {
  final String code;
  final String nameVn;

  TimeOffStatusDto({required this.code, required this.nameVn});

  factory TimeOffStatusDto.fromJson(Map<String, dynamic> json) {
    return TimeOffStatusDto(
      code: (json['Code'] as String?)?.trim() ?? '',
      nameVn: (json['Name_VN'] as String?)?.trim() ?? '',
    );
  }

  factory TimeOffStatusDto.fromDomain(TimeOffStatus status) {
    return TimeOffStatusDto(code: status.code, nameVn: status.name);
  }

  Map<String, dynamic> toJson() {
    return {'Code': code, 'Name_VN': nameVn};
  }

  TimeOffStatus toDomain() {
    return TimeOffStatus(code: code, name: nameVn);
  }
}
