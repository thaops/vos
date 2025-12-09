import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class CreateAflVosRequest {
  final List<List<String>> leaveDateRange;
  final String leaveTimes;
  final String leavePlace;
  final String reason;
  final bool isOverseas;
  final List<AttachmentItem> attachments;
  final List<ApprovalItem> approvals;

  CreateAflVosRequest({
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
      'LeaveTimes': leaveTimes,
      'LeavePlace': leavePlace,
      'Reason': reason,
      'IsOverseas': isOverseas,
      'Attachments': attachments.map((a) => a.toJson()).toList(),
      'Approvals': approvals.map((a) => a.toJson()).toList(),
    };
  }

  /// Factory method để map từ TimeOff sang CreateAflVosRequest
  factory CreateAflVosRequest.fromTimeOff({
    required TimeOff timeOff,
    required List<TimeOffProcess> processes,
  }) {
    // 1. LeaveDateRange: Map từ details hoặc fromDate/toDate
    final leaveDateRange = <List<String>>[];
    
    if (timeOff.details != null && timeOff.details!.isNotEmpty) {
      // Nếu có details, tạo date range từ fromDate và số lượng ngày
      if (timeOff.fromDate != null) {
        var currentDate = timeOff.fromDate!;
        for (final detail in timeOff.details!) {
          // Tạo date range cho mỗi detail
          for (int i = 0; i < detail.soLuong.toInt(); i++) {
            final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
            leaveDateRange.add([dateStr]);
            currentDate = currentDate.add(const Duration(days: 1));
          }
        }
      }
    } else if (timeOff.fromDate != null) {
      // Fallback: dùng fromDate và toDate hoặc chỉ fromDate
      if (timeOff.toDate != null) {
        var currentDate = timeOff.fromDate!;
        while (currentDate.isBefore(timeOff.toDate!) ||
            currentDate.isAtSameMomentAs(timeOff.toDate!)) {
          final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
          leaveDateRange.add([dateStr]);
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } else {
        // Chỉ có fromDate
        final dateStr = DateFormat('yyyy-MM-dd').format(timeOff.fromDate!);
        leaveDateRange.add([dateStr]);
      }
    }

    // 2. LeaveTimes: Tổng số ngày
    final totalDays = timeOff.details?.fold<double>(
          0.0,
          (sum, detail) => sum + detail.soLuong,
        ) ??
        0.0;
    final leaveTimes = totalDays.toString();

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

    // 7. Approvals: Map từ processes
    final approvals = processes.asMap().entries.map((entry) {
      final index = entry.key;
      final process = entry.value;
      return ApprovalItem(
        step: index + 1, // Step bắt đầu từ 1
        name: process.fullName,
        email: process.email,
        position: '', // Cần lấy từ đâu đó, có thể để trống
      );
    }).toList();

    return CreateAflVosRequest(
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
    return {
      'Name': name,
      'Type': type,
      'Url': url,
      'Size': size,
      'Uid': uid,
    };
  }
}

class ApprovalItem {
  final int step;
  final String name;
  final String email;
  final String position;

  ApprovalItem({
    required this.step,
    required this.name,
    required this.email,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'Step': step,
      'Name': name,
      'Email': email,
      'Position': position,
    };
  }
}

