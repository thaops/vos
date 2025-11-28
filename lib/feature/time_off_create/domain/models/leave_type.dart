class LeaveType {
  final int jobId;
  final String jobCode;
  final String jobName;

  const LeaveType({
    required this.jobId,
    required this.jobCode,
    required this.jobName,
  });

  LeaveType copyWith({
    int? jobId,
    String? jobCode,
    String? jobName,
  }) {
    return LeaveType(
      jobId: jobId ?? this.jobId,
      jobCode: jobCode ?? this.jobCode,
      jobName: jobName ?? this.jobName,
    );
  }
}

