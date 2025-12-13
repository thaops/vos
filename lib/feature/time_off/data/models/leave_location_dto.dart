import 'package:vos_flutter/feature/time_off/domain/models/leave_location.dart';

class LeaveLocationDto {
  final String code;
  final String nameVn;

  LeaveLocationDto({
    required this.code,
    required this.nameVn,
  });

  factory LeaveLocationDto.fromJson(Map<String, dynamic> json) {
    return LeaveLocationDto(
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

  LeaveLocation toDomain() {
    return LeaveLocation(
      code: code,
      nameVn: nameVn,
    );
  }

  factory LeaveLocationDto.fromDomain(LeaveLocation domain) {
    return LeaveLocationDto(
      code: domain.code,
      nameVn: domain.nameVn,
    );
  }
}

