class WorkCode {
  final int jobId;
  final String jobCode;
  final String jobName;

  const WorkCode({
    required this.jobId,
    required this.jobCode,
    required this.jobName,
  });

  WorkCode copyWith({int? jobId, String? jobCode, String? jobName}) {
    return WorkCode(
      jobId: jobId ?? this.jobId,
      jobCode: jobCode ?? this.jobCode,
      jobName: jobName ?? this.jobName,
    );
  }
}
