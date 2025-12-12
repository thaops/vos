import 'package:flutter/material.dart';

class Vacation {
  final int vRegId;
  final int? hrId;
  final String? hrNo;
  final String? fullName;
  final String? jobTitleName;
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
  final int? depId;
  final String? depCode;
  final String? level1Code;
  final String? level1Name;
  final String? level2Code;
  final String? level2Name;
  final String? level3Code;
  final String? level3Name;
  final double? phepTon;
  final double? overtimeTon;
  final String? appoveProcess;
  final String? approveStatus;
  final String? appoveProcessName;
  final String? approveNote;
  final List<VacationDetail>? details;
  final List<VacationProcess>? processes;

  const Vacation({
    required this.vRegId,
    this.hrId,
    this.hrNo,
    this.fullName,
    this.jobTitleName,
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
    this.depId,
    this.depCode,
    this.level1Code,
    this.level1Name,
    this.level2Code,
    this.level2Name,
    this.level3Code,
    this.level3Name,
    this.phepTon,
    this.overtimeTon,
    this.appoveProcess,
    this.approveStatus,
    this.appoveProcessName,
    this.approveNote,
    this.details,
    this.processes,
  });

  // Helper để check có thể hủy không
  bool get canCancel {
    return approveStatus != 'OK' &&
        appoveProcessName != null &&
        !appoveProcessName!.contains('Đang sử dụng');
  }

  // Helper để lấy status color
  Color get statusColor {
    if (approveStatus == 'OK' || statusName?.contains('Đang sử dụng') == true) {
      return Colors.green.shade300;
    }
    if (appoveProcessName?.contains('đang duyệt') == true ||
        appoveProcessName?.contains('đang xử lý') == true) {
      return Colors.orange.shade300;
    }
    if (approveStatus == 'XX' || statusName?.contains('Từ chối') == true) {
      return Colors.red.shade300;
    }
    return Colors.grey.shade300;
  }

  // Helper để format approval progress
  String get approvalProgressText {
    if (processes == null || processes!.isEmpty) {
      return appoveProcessName ?? 'Chưa có thông tin';
    }

    final approvedCount = processes!.where((p) => p.status == 'YES').length;
    final totalCount = processes!.length;

    if (approvedCount < totalCount) {
      final currentApprover = processes!.firstWhere(
        (p) => p.status != 'YES' && p.status != 'XX',
        orElse: () => processes!.first,
      );
      return '$approvedCount/$totalCount: ${currentApprover.fullName} đang duyệt';
    }

    return '$approvedCount/$totalCount: Đã phê duyệt';
  }
}

// Model cho chi tiết loại nghỉ
class VacationDetail {
  final String jobCode;
  final String jobName;
  final double soLuong;

  VacationDetail({
    required this.jobCode,
    required this.jobName,
    required this.soLuong,
  });

  factory VacationDetail.fromJson(Map<String, dynamic> json) {
    return VacationDetail(
      jobCode: json['JobCode'] ?? '',
      jobName: json['JobName'] ?? '',
      soLuong: (json['SoLuong'] ?? 0).toDouble(),
    );
  }
}

// Model cho quy trình phê duyệt
class VacationProcess {
  final int approveNo;
  final String fullName;
  final String email;
  final DateTime? recdate;
  final String status;
  final String title;

  VacationProcess({
    required this.approveNo,
    required this.fullName,
    required this.email,
    this.recdate,
    required this.status,
    required this.title,
  });

  factory VacationProcess.fromJson(Map<String, dynamic> json) {
    return VacationProcess(
      approveNo: json['ApproveNo'] ?? 0,
      fullName: json['FullName'] ?? '',
      email: json['Email'] ?? '',
      recdate: json['Recdate'] != null
          ? DateTime.tryParse(json['Recdate'])
          : null,
      status: json['Status'] ?? '--',
      title: json['Title'] ?? '',
    );
  }
}

