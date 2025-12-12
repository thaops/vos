import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class CreateAflVosRequest {
  final List<List<String>> leaveDateRange;
  final String leaveTimes;
  final String leavePlace;
  final String reason;
  final bool isOverseas;
  final List<AttachmentItem> attachments;
  final int vRegId;
  final List<ApprovalItem> approvals;

  CreateAflVosRequest({
    required this.leaveDateRange,
    required this.leaveTimes,
    required this.leavePlace,
    required this.reason,
    required this.isOverseas,
    required this.attachments,
    required this.vRegId,
    required this.approvals,
  });

  Map<String, dynamic> toJson() {
    return {
      'LeaveDateRange': leaveDateRange,
      'LeaveTimes': leaveTimes.toString(), // Đảm bảo luôn là string
      'LeavePlace': leavePlace,
      'Reason': reason,
      'IsOverseas': isOverseas,
      'Attachments': attachments.map((a) => a.toJson()).toList(),
      'VRegID': vRegId,
      'Approvals': approvals.map((a) => a.toJson()).toList(),
    };
  }

  /// Factory method để map từ TimeOff sang CreateAflVosRequest
  factory CreateAflVosRequest.fromTimeOff({
    required TimeOff timeOff,
    required List<TimeOffProcess> processes,
    List<ApprovalItem>? approvalsOverride,
  }) {
    // 1. LeaveDateRange: luôn ưu tiên from/to date, rơi back sang details nếu cần
    final leaveDateRange = <List<String>>[];
    final totalDays =
        timeOff.details?.fold<double>(
          0.0,
          (sum, detail) => sum + detail.soLuong,
        ) ??
        0.0;
    if (timeOff.fromDate != null) {
      final startDate = timeOff.fromDate!;


      // Chỉ gửi ngày (yyyy-MM-dd), bỏ phần giờ
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      leaveDateRange.add([startStr]);
    }

    // 2. LeaveTimes: ưu tiên tổng detail, fallback theo khoảng ngày
    // Đảm bảo luôn trả về string (0.5 -> "0.5")
    final String leaveTimes;
    if (totalDays > 0) {
      // Format số thập phân, loại bỏ trailing zeros không cần thiết
      // Ví dụ: 0.5 -> "0.5", 1.0 -> "1", 2.5 -> "2.5"
      final formatted = totalDays.toString();
      // Loại bỏ ".0" ở cuối nếu là số nguyên
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
      return AttachmentItem(
        name: file.fileName,
        type: _getFileType(file.fileName),
        url: file.fileUrl,
        size: _parseFileSize(file.fileSize),
        uid: file.fileName, // Dùng fileName làm uid nếu không có fileId
      );
    }).toList();

    // 7. Approvals: chỉ dùng override khi có dữ liệu, không thì fallback processes
    // Step bắt đầu từ 0 (theo format mới)
    final approvals =
        (approvalsOverride != null && approvalsOverride.isNotEmpty)
        ? approvalsOverride
        : processes.asMap().entries.map((entry) {
            final index = entry.key;
            final process = entry.value;
            return ApprovalItem(
              step: index, // Step bắt đầu từ 0
              name: process.fullName,
              email: process.email,
              position: '', // Cần lấy từ đâu đó, có thể để trống
              vAppId: 0, // Mặc định là 0, sẽ được set từ API response nếu có
            );
          }).toList();

    return CreateAflVosRequest(
      leaveDateRange: leaveDateRange,
      leaveTimes: leaveTimes,
      leavePlace: leavePlace,
      reason: reason,
      isOverseas: isOverseas,
      attachments: attachments,
      vRegId: timeOff.vRegId,
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

class ApprovalItem {
  final int step;
  final String name;
  final String email;
  final String position;
  final int? vAppId;
  final int? approveNo;

  ApprovalItem({
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
      'VAppId': vAppId ?? 0, // Luôn include VAppId, mặc định là 0
    };
  }
}
