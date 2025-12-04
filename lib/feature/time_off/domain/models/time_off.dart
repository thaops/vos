import 'package:flutter/material.dart';

class TimeOff {
  final int vRegId;
  final int? hrId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DateTime? dateReg;
  final String? domInt;
  final String? domIntName;
  final String? vacationReason;
  final String? vacationReasonName;
  final String? description;
  final String? contactPerson;
  final String? contactInfor;
  final String? status;
  final String? statusName;
  final DateTime? recdate;
  final int? vacationNo;
  final String? appoveProcess;
  final String? appoveProcessName;
  final String? approveStatus;
  final List<TimeOffDetail>? details;
  final List<TimeOffProcess>? processes;

  // Thông tin bổ sung từ API
  final int? depId;
  final String? depCode;
  final String? level2Code;
  final String? level2Name;
  final String? level3Code;
  final String? level3Name;
  final int? idJobTitle;
  final String? codeJobTitle;
  final int? idLevelTitle;
  final String? nameLevelTitle;
  final double? phepTon; // Tồn phép
  final double? overtimeTon; // Tồn OT

  const TimeOff({
    required this.vRegId,
    this.hrId,
    this.fromDate,
    this.toDate,
    this.dateReg,
    this.domInt,
    this.domIntName,
    this.vacationReason,
    this.vacationReasonName,
    this.description,
    this.contactPerson,
    this.contactInfor,
    this.status,
    this.statusName,
    this.recdate,
    this.vacationNo,
    this.appoveProcess,
    this.appoveProcessName,
    this.approveStatus,
    this.details,
    this.processes,
    this.depId,
    this.depCode,
    this.level2Code,
    this.level2Name,
    this.level3Code,
    this.level3Name,
    this.idJobTitle,
    this.codeJobTitle,
    this.idLevelTitle,
    this.nameLevelTitle,
    this.phepTon,
    this.overtimeTon,
  });

  // Helper để check có thể hủy không
  bool get canCancel {
    return approveStatus != 'OK' &&
        appoveProcessName != null &&
        !appoveProcessName!.contains('Đã phê duyệt');
  }

  // Helper để lấy status color
  Color get statusColor {
    if (approveStatus == 'OK' || statusName?.contains('Đã phê duyệt') == true) {
      return Colors.green.shade300; // Xanh nhạt - Đã phê duyệt
    }
    if (appoveProcessName?.contains('đang duyệt') == true ||
        appoveProcessName?.contains('đang xử lý') == true) {
      return Colors.orange.shade300; // Vàng - Đang xử lý
    }
    if (approveStatus == 'XX' || statusName?.contains('Từ chối') == true) {
      return Colors.red.shade300; // Đỏ - Từ chối
    }
    return Colors.grey.shade300; // Mặc định
  }

  // Helper để format approval progress
  String get approvalProgressText {
    if (processes == null || processes!.isEmpty) {
      return appoveProcessName ?? 'Chưa có thông tin';
    }

    final approvedCount = processes!.where((p) => p.status == 'OK').length;
    final totalCount = processes!.length;

    if (approvedCount < totalCount) {
      final currentApprover = processes!.firstWhere(
        (p) => p.status != 'OK' && p.status != 'XX',
        orElse: () => processes!.first,
      );
      return '$approvedCount/$totalCount: ${currentApprover.fullName} đang duyệt';
    }

    return '$approvedCount/$totalCount: Đã phê duyệt';
  }
}

// Model cho chi tiết loại nghỉ
class TimeOffDetail {
  final String jobCode;
  final String jobName;
  final double soLuong;

  TimeOffDetail({
    required this.jobCode,
    required this.jobName,
    required this.soLuong,
  });

  factory TimeOffDetail.fromJson(Map<String, dynamic> json) {
    return TimeOffDetail(
      jobCode: json['JobCode'] ?? '',
      jobName: json['JobName'] ?? '',
      soLuong: (json['SoLuong'] ?? 0).toDouble(),
    );
  }
}

// Model cho quy trình phê duyệt
class TimeOffProcess {
  final int approveNo;
  final String fullName;
  final String email;
  final DateTime? recdate;
  final String status;

  TimeOffProcess({
    required this.approveNo,
    required this.fullName,
    required this.email,
    this.recdate,
    required this.status,
  });

  factory TimeOffProcess.fromJson(Map<String, dynamic> json) {
    return TimeOffProcess(
      approveNo: json['ApproveNo'] ?? 0,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      recdate: json['Recdate'] != null
          ? DateTime.tryParse(json['Recdate'])
          : null,
      status: json['Status'] ?? '--',
    );
  }
}
