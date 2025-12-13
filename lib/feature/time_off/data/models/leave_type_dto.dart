import 'package:vos_flutter/feature/time_off/domain/models/leave_type.dart';

class LeaveTypeDto {
  final int jobId;
  final String jobCode;
  final String jobName;

  LeaveTypeDto({
    required this.jobId,
    required this.jobCode,
    required this.jobName,
  });

  factory LeaveTypeDto.fromJson(Map<String, dynamic> json) {
    return LeaveTypeDto(
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

  LeaveType toDomain() {
    return LeaveType(
      jobId: jobId,
      jobCode: jobCode,
      jobName: jobName,
    );
  }

  factory LeaveTypeDto.fromDomain(LeaveType domain) {
    return LeaveTypeDto(
      jobId: domain.jobId,
      jobCode: domain.jobCode,
      jobName: domain.jobName,
    );
  }
}

