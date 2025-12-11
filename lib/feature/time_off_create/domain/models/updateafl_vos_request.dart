import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class UpdateAflVosRequest {
  final List<List<String>> leaveDateRange;
  final String leaveTimes;
  final String leavePlace;
  final String reason;
  final bool isOverseas;
  final List<UpdateAttachmentItem> attachments;
  final List<UpdateApprovalItem> approvals;

  UpdateAflVosRequest({
    required this.leaveDateRange,
    required this.leaveTimes,
    required this.leavePlace,
    required this.reason,
    required this.isOverseas,
    required this.attachments,
    required this.approvals,
  });

  Map<String, dynamic> toJson() {
    return {
      'LeaveDateRange': leaveDateRange,
      'LeaveTimes': leaveTimes.toString(),
      'LeavePlace': leavePlace,
      'Reason': reason,
      'IsOverseas': isOverseas,
      'Attachments': attachments.map((a) => a.toJson()).toList(),
      'Approvals': approvals.map((a) => a.toJson()).toList(),
    };
  }

  /// Factory method để map từ TimeOff sang UpdateAflVosRequest
  factory UpdateAflVosRequest.fromTimeOff({
    required TimeOff timeOff,
    required List<TimeOffProcess> processes,
    List<UpdateApprovalItem>? approvalsOverride,
  }) {
    // 1. LeaveDateRange: luôn ưu tiên from/to date
    final leaveDateRange = <List<String>>[];
    final totalDays = timeOff.details?.fold<double>(
          0.0,
          (sum, detail) => sum + detail.soLuong,
        ) ??
        0.0;
    if (timeOff.fromDate != null) {
      final startDate = timeOff.fromDate!;
      final inferredDays = totalDays > 0 ? totalDays.ceil() : 1;
      final endDate = timeOff.toDate ??
          startDate.add(Duration(
            days: inferredDays - 1,
          ));

      // Format date: "yyyy-MM-dd" (không có time)
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      leaveDateRange.add([startStr, endStr]);
    }

    // 2. LeaveTimes: ưu tiên tổng detail, fallback theo khoảng ngày
    final String leaveTimes;
    if (totalDays > 0) {
      final formatted = totalDays.toString();
      leaveTimes = formatted.replaceAll(RegExp(r'\.0$'), '');
    } else if (timeOff.fromDate != null) {
      final endDate = timeOff.toDate ?? timeOff.fromDate!;
      final dayCount = endDate.difference(timeOff.fromDate!).inDays + 1;
      leaveTimes = dayCount.toString();
    } else {
      leaveTimes = '0';
    }

    // 3. LeavePlace: Từ domIntName
    final leavePlace = timeOff.domIntName ?? '';

    // 4. Reason: Từ description
    final reason = timeOff.description ?? '';

    // 5. IsOverseas: Check từ domInt (có thể là 'INT' = nước ngoài)
    final isOverseas = timeOff.domInt?.toUpperCase() == 'INT';

    // 6. Attachments: Map từ attachFiles
    final attachments = (timeOff.attachFiles ?? []).map((file) {
      return UpdateAttachmentItem(
        name: file.fileName,
        type: _getFileType(file.fileName),
        url: file.fileUrl,
        size: _parseFileSize(file.fileSize),
        uid: file.fileName,
      );
    }).toList();

    // 7. Approvals: chỉ dùng override khi có dữ liệu, không thì fallback processes
    final approvals = (approvalsOverride != null && approvalsOverride.isNotEmpty)
        ? approvalsOverride
        : processes.asMap().entries.map((entry) {
            final index = entry.key;
            final process = entry.value;
            return UpdateApprovalItem(
              step: index + 1,
              name: process.fullName,
              email: process.email,
              position: '',
              vAppId: null, // TimeOffProcess không có vAppId, có thể thêm sau nếu cần
            );
          }).toList();

    return UpdateAflVosRequest(
      leaveDateRange: leaveDateRange,
      leaveTimes: leaveTimes,
      leavePlace: leavePlace,
      reason: reason,
      isOverseas: isOverseas,
      attachments: attachments,
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

class UpdateAttachmentItem {
  final String name;
  final String type;
  final String url;
  final int size;
  final String uid;

  UpdateAttachmentItem({
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uid,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Type': type,
      'Url': url,
      'Size': size,
      'Uid': uid,
    };
  }
}

class UpdateApprovalItem {
  final int step;
  final String name;
  final String email;
  final String position;
  final int? vAppId;
  final int? approveNo;

  UpdateApprovalItem({
    required this.step,
    required this.name,
    required this.email,
    required this.position,
    this.vAppId,
    this.approveNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'Step': step,
      'Name': name,
      'Email': email,
      'Position': position,
      if (vAppId != null) 'VAppId': vAppId,
    };
  }
}
