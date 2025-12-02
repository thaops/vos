class WorkCodeDetail {
  final String jobCode;
  final double soLuong;

  const WorkCodeDetail({
    required this.jobCode,
    required this.soLuong,
  });

  WorkCodeDetail copyWith({
    String? jobCode,
    double? soLuong,
  }) {
    return WorkCodeDetail(
      jobCode: jobCode ?? this.jobCode,
      soLuong: soLuong ?? this.soLuong,
    );
  }
}

