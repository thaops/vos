import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';

class TimeOff {
  final int vRegId;
  final int? hrId;
  final String? hrNo;
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
  final List<FileAttachment>? attachFiles;

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
  final String? nameJobTitle;
  final String? nameLevelTitle;
  final double? phepTon; // Tồn phép
  final double? overtimeTon; // Tồn OT

  const TimeOff({
    required this.vRegId,
    this.hrId,
    this.hrNo,
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
    this.attachFiles,
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
    this.nameJobTitle
  });

  double get totalTimeOff {
    final detailList = details;
    if (detailList == null || detailList.isEmpty) {
      return (vacationNo ?? 0).toDouble();
    }
    return detailList.fold<double>(0, (sum, item) => sum + item.soLuong);
  }

  bool get canCancel {
    return approveStatus != 'OK' &&
        appoveProcessName != null &&
        !appoveProcessName!.contains('Đã phê duyệt');
  }

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

  String get approvalProgressText {
    if (processes == null || processes!.isEmpty) {
      return appoveProcessName ?? 'Chưa có thông tin';
    }

    String _normalize(String value) =>
        value.replaceAll(RegExp(r'\s+'), '').trim().toLowerCase();


    String canonicalStatus(String raw) {
      final s = _normalize(raw);
      switch (s) {
        case 'yes':
        case 'true':
        case '1':
          return 'fn'; // đã duyệt
        case 'no':
        case 'false':
        case '0':
          return 'ok'; // chưa duyệt / chờ phê duyệt
        default:
          return s;
      }
    }

    final sortedProcesses = [...processes!]
      ..sort((a, b) => a.approveNo.compareTo(b.approveNo));

    final statuses = sortedProcesses
        .map((p) => canonicalStatus(p.status))
        .toList();
    final totalCount = sortedProcesses.length;

    final approvedCount = sortedProcesses
        .where((p) => canonicalStatus(p.status) == 'fn')
        .length;

    assert(() {
      if (_approvalProgressLoggedVRegIds.add(vRegId)) {
        final raw = sortedProcesses
            .map((p) => '${p.approveNo}:${p.status}')
            .join(' | ');
        final normalized = statuses.join(',');
        debugPrint(
          '[TimeOff][approvalProgressText] vRegId=$vRegId '
          'approved=$approvedCount/$totalCount '
          'raw=[$raw] canonical=[$normalized] approveStatus=$approveStatus',
        );
      }
      return true;
    }());

    // Nếu bị từ chối/thu hồi thì vẫn giữ số bước đã duyệt để progress không bị sai (vd: 1/2)
    if (statuses.contains('rj')) {
      return '$approvedCount/$totalCount: Từ chối';
    }

    if (statuses.contains('bk')) {
      return '$approvedCount/$totalCount: Thu hồi';
    }

    if (approvedCount < totalCount) {
      final currentApprover = sortedProcesses.firstWhere((p) {
        final s = canonicalStatus(p.status);
        return s != 'fn' && s != 'rj' && s != 'bk';
      }, orElse: () => sortedProcesses.first);
      final currentStatus = canonicalStatus(currentApprover.status);
      final fullName = currentApprover.fullName.trim();

      // Mapping theo TimeOffDetailController.buildStatusTag:
      // --: chưa chuyển phê duyệt, ok: chờ phê duyệt, in: đang trong quá trình phê duyệt
      final suffix = switch (currentStatus) {
        '--' => 'chưa chuyển phê duyệt',
        'ok' => 'chờ phê duyệt',
        'in' => 'đang duyệt',
        _ => 'đang duyệt',
      };

      final prefix = fullName.isEmpty ? '' : '$fullName ';
      return '$approvedCount/$totalCount: $prefix$suffix';
    }

    return '$approvedCount/$totalCount: Đã phê duyệt';
  }

  static final Set<int> _approvalProgressLoggedVRegIds = <int>{};
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

class TimeOffProcess {
  final int approveNo;
  final String fullName;
  final String email;
  final DateTime? recdate;
  final String status;
  final String title;
  final String dutyType;
  final String nameJobTitle;

  TimeOffProcess({
    required this.approveNo,
    required this.fullName,
    required this.email,
    this.recdate,
    required this.status,
    required this.title,
    required this.dutyType,
    required this.nameJobTitle,
  });

  factory TimeOffProcess.fromJson(Map<String, dynamic> json) {
    int readInt(List<String> keys, {int fallback = 0}) {
      for (final key in keys) {
        final v = json[key];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? fallback;
      }
      return fallback;
    }

    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final v = json[key];
        if (v == null) continue;
        if (v is String) return v;
        return v.toString();
      }
      return fallback;
    }

    return TimeOffProcess(
      approveNo: readInt(['ApproveNo', 'approveNo', 'approve_no']),
      fullName: readString(['FullName', 'fullName', 'full_name']),
      email: readString(['Email', 'email']),
      recdate: json['Recdate'] != null
          ? DateTime.tryParse(json['Recdate'])
          : null,
      status: readString([
        'Status',
        'status',
        'ApproveStatus',
        'approveStatus',
        'approve_status',
      ], fallback: '--'),
      title: readString(['Title', 'title']),
      dutyType: readString(['DutyType', 'dutyType']),
      nameJobTitle: readString(['Name_Job_Title', 'nameJobTitle']),
    );
  }
}
