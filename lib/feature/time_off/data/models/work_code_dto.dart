import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';

class WorkCodeDto {
  final int jobId;
  final String jobCode;
  final String jobName;

  WorkCodeDto({
    required this.jobId,
    required this.jobCode,
    required this.jobName,
  });

  factory WorkCodeDto.fromJson(Map<String, dynamic> json) {
    return WorkCodeDto(
      jobId: json['Job_ID'] as int? ?? 0,
      jobCode: json['JobCode'] as String? ?? '',
      jobName: json['JobName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Job_ID': jobId,
      'JobCode': jobCode,
      'JobName': jobName,
    };
  }

  WorkCode toDomain() {
    return WorkCode(
      jobId: jobId,
      jobCode: jobCode,
      jobName: jobName,
    );
  }

  factory WorkCodeDto.fromDomain(WorkCode domain) {
    return WorkCodeDto(
      jobId: domain.jobId,
      jobCode: domain.jobCode,
      jobName: domain.jobName,
    );
  }
}

