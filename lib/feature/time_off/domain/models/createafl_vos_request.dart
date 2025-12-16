import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class CreateAflVosRequest {
  final List<List<String>> leaveDateRange;
  final String totalLeaveDay;
  final String leavePlace;
  final String reason;
  final bool isOverseas;
  final List<AttachmentItem> attachments;
  final int vRegId;
  final int hrId;
  final List<ApprovalStep> approvals;

  CreateAflVosRequest({
    required this.leaveDateRange,
    required this.totalLeaveDay,
    required this.leavePlace,
    required this.reason,
    required this.isOverseas,
    required this.attachments,
    required this.vRegId,
    required this.hrId,
    required this.approvals,
  });

  Map<String, dynamic> toJson() {
    return {
      'LeaveDateRange': leaveDateRange,
      'TotalLeaveDay': totalLeaveDay.toString(), // Đảm bảo luôn là string
      'LeavePlace': leavePlace,
      'Reason': reason,
      'IsOverseas': isOverseas,
      'Attachments': attachments.map((a) => a.toJson()).toList(),
      'VRegID': vRegId,
      'HR_ID': hrId,
      'Approvals': approvals.map((a) => a.toJson()).toList(),
    };
  }

  /// Factory method để map từ TimeOff sang CreateAflVosRequest
  factory CreateAflVosRequest.fromTimeOff({
    required TimeOff timeOff,
    required List<TimeOffProcess> processes,

    /// approvalsOverride: danh sách ApprovalItem lấy từ API phê duyệt
    /// (SendApproveResult.approvals). Hàm sẽ tự wrap thành List<ApprovalStep>
    /// đúng format JSON:
    /// "Approvals": [{ "Step": 0, "Ls_Approval": [ { ...ApprovalItem } ] }, ...]
    List<ApprovalItem>? approvalsOverride,
    DateTime? overrideFromDate,
    DateTime? overrideToDate,
    int? hrId,
  }) {
    // 1. LeaveDateRange: dùng fromDate + LeaveTimes để suy ra endDate, kèm giờ
    final leaveDateRange = <List<String>>[];
    final totalDays =
        timeOff.details?.fold<double>(
          0.0,
          (sum, detail) => sum + detail.soLuong,
        ) ??
        0.0;
    final double totalLeaveDayNum;
    if (totalDays > 0) {
      totalLeaveDayNum = totalDays;
    } else if (timeOff.fromDate != null) {
      final endDate = timeOff.toDate ?? timeOff.fromDate!;
      totalLeaveDayNum = (endDate.difference(timeOff.fromDate!).inDays + 1)
          .toDouble();
    } else {
      totalLeaveDayNum = 0;
    }

    // Đảm bảo luôn trả về string (0.5 -> "0.5", 1.0 -> "1")
    final totalLeaveDay = totalLeaveDayNum.toString().replaceAll(
      RegExp(r'\.0$'),
      '',
    );

    final DateTime? baseFromDate = overrideFromDate ?? timeOff.fromDate;

    if (baseFromDate != null) {
      final startDate = baseFromDate;
      final daysToAdd = totalLeaveDayNum <= 1 ? 0 : totalLeaveDayNum.ceil() - 1;
      final computedEndDate = startDate.add(Duration(days: daysToAdd));
      final endDate = overrideToDate ?? timeOff.toDate ?? computedEndDate;

      // Format có kèm giây: yyyy-MM-dd HH:mm:ss
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final startStr = formatter.format(startDate);
      final endStr = formatter.format(endDate);
      leaveDateRange.add([startStr, endStr]);
    }

    final leavePlace = timeOff.domIntName ?? '';

    final reason = timeOff.description ?? '';

    final isOverseas = timeOff.domInt?.toUpperCase() == 'INT';

    final attachments = (timeOff.attachFiles ?? []).map((file) {
      return AttachmentItem(
        name: file.fileName,
        type: _getFileType(file.fileName),
        url: file.fileUrl,
        size: _parseFileSize(file.fileSize),
        uid: file.fileName,
      );
    }).toList();

    // Build danh sách Approvals theo priority:
    // 1. Nếu có approvalsOverride từ API → dùng, mỗi item = 1 step.
    // 2. Nếu không có → build từ processes.
    final List<ApprovalStep> approvals;
    if (approvalsOverride != null && approvalsOverride.isNotEmpty) {
      approvals = approvalsOverride.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return ApprovalStep(step: index, lsApproval: [item]);
      }).toList();
    } else {
      approvals = processes.asMap().entries.map((entry) {
        final index = entry.key;
        final process = entry.value;
        final approvalItem = ApprovalItem(
          dutyType: 'MAIN',
          name: process.fullName,
          email: process.email,
          position: '', // Có thể cập nhật nếu backend trả thêm
          vAppId: 0, // Mặc định 0, backend sẽ cập nhật nếu cần
        );
        return ApprovalStep(step: index, lsApproval: [approvalItem]);
      }).toList();
    }

    return CreateAflVosRequest(
      leaveDateRange: leaveDateRange,
      totalLeaveDay: totalLeaveDay,
      leavePlace: leavePlace,
      reason: reason,
      isOverseas: isOverseas,
      attachments: attachments,
      vRegId: timeOff.vRegId,
      hrId: timeOff.hrId ?? 1752,
      approvals: approvals,
    );
  }

  static String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  static int _parseFileSize(String sizeStr) {
    try {
      return int.parse(sizeStr);
    } catch (e) {
      return 0;
    }
  }
}

class AttachmentItem {
  final String name;
  final String type;
  final String url;
  final int size;
  final String uid;

  AttachmentItem({
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uid,
  });

  Map<String, dynamic> toJson() {
    return {'Name': name, 'Type': type, 'Url': url, 'Size': size, 'Uid': uid};
  }
}

class ApprovalStep {
  final int step;
  final List<ApprovalItem> lsApproval;

  ApprovalStep({required this.step, required this.lsApproval});

  Map<String, dynamic> toJson() {
    return {
      'Step': step,
      'Ls_Approval': lsApproval.map((e) => e.toJson()).toList(),
    };
  }
}

class ApprovalItem {
  final String dutyType;
  final String name;
  final String email;
  final String position;
  final int? vAppId;

  ApprovalItem({
    required this.dutyType,
    required this.name,
    required this.email,
    required this.position,
    this.vAppId,
  });

  Map<String, dynamic> toJson() {
    return {
      'DutyType': dutyType,
      'Name': name,
      'Email': email,
      'Position': position,
      'VAppId': vAppId ?? 0, // Luôn include VAppId, mặc định là 0
    };
  }
}
