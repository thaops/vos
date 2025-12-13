import 'dart:convert';

import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/core/network/share_Json_helper.dart';

class SendApproveResultDto {
  final int vRegId;
  final List<ApprovalItem> approvals;

  SendApproveResultDto({
    required this.vRegId,
    required this.approvals,
  });

  factory SendApproveResultDto.fromMap(Map<String, dynamic> map) {
    final vRegId = ShareJsonHelper.getInt(map, 'VReg_ID');
    final approvals = _parseApprovals(map);

    return SendApproveResultDto(
      vRegId: vRegId,
      approvals: approvals,
    );
  }

  SendApproveResult toDomain() {
    return SendApproveResult(vRegId: vRegId, approvals: approvals);
  }

  static List<ApprovalItem> _parseApprovals(Map<String, dynamic> map) {
    final rawDataValue = map['Data'];
    if (rawDataValue == null) return [];

    List<dynamic>? listData;

    // Nếu đã là List (parser Share API đã decode) thì dùng trực tiếp
    if (rawDataValue is List) {
      listData = rawDataValue;
    } else if (rawDataValue is String) {
      final rawData = rawDataValue.trim();
      if (rawData.isEmpty) return [];
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is List) {
          listData = decoded;
        }
      } catch (_) {
        // Không parse được -> trả về rỗng
        return [];
      }
    }

    if (listData == null) return [];

    return listData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      if (item is! Map<String, dynamic>) {
        return null;
      }

      final approveNo = _tryParseInt(item['ApproveNo']);
      // Step bắt đầu từ 0 (theo format mới)
      final step = index;

      return ApprovalItem(
        step: step,
        name: item['FullName']?.toString() ?? '',
        email: item['Email']?.toString() ?? '',
        position: item['Name_Job_Title']?.toString() ?? '',
        vAppId: _tryParseInt(item['VApp_ID']) ?? 0, // Mặc định là 0 nếu không có
        approveNo: approveNo,
      );
    }).whereType<ApprovalItem>().toList();
  }

  static int? _tryParseInt(dynamic value) {
    if (value == null) return null;
    try {
      if (value is int) return value;
      return int.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
