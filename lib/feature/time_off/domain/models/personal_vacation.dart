class PersonalVacation {
  final int hrId;
  final String hrNo;
  final String fullName;
  final String jobTitleNameVN;
  final String departmentName;
  final int paidLeaveRemain;
  final int overTimeRemain;
  final int paidLeaveUsedTotal;
  final double? paidLeaveYear; // Tiêu chuẩn phép
  final double? paidLeaveRemainEarly; // Tồn phép sớm

  PersonalVacation({
    required this.hrId,
    required this.hrNo,
    required this.fullName,
    required this.jobTitleNameVN,
    required this.departmentName,
    required this.paidLeaveRemain,
    required this.overTimeRemain,
    required this.paidLeaveUsedTotal,
    this.paidLeaveYear,
    this.paidLeaveRemainEarly,
  });
}

