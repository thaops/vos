import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class UpdateAflVosRequest {
  final String requestStatus;
  final int vRegId;
  final int vAppId;
  final String reason;
  final int step;

  UpdateAflVosRequest({
    required this.requestStatus,
    required this.vRegId,
    required this.vAppId,
    required this.reason,
    required this.step,
  });

  Map<String, dynamic> toJson() {
    return {
      'RequestStatus': requestStatus,
      'VRegID': vRegId,
      'VAppId': vAppId,
      'Reason': reason,
      'Step': step,
    };
  }

  /// Factory method để map từ TimeOff sang UpdateAflVosRequest
  factory UpdateAflVosRequest.fromTimeOff({
    required TimeOff timeOff,
    required List<TimeOffProcess> processes,
    int? vAppIdOverride,
  }) {
    // RequestStatus: cứng là "revoked"
    const requestStatus = 'revoked';

    // VReg_ID: từ timeOff
    final vRegId = timeOff.vRegId;

    // VAppId: ưu tiên override, nếu không có thì lấy từ process đầu tiên
    // Nếu process không có vAppId, có thể cần lấy từ SendApproveResult
    int vAppId;
    if (vAppIdOverride != null) {
      vAppId = vAppIdOverride;
    } else if (processes.isNotEmpty) {
      // Lấy từ process đầu tiên (step 1)
      // TimeOffProcess không có vAppId, nên cần lấy từ nơi khác hoặc truyền vào
      // Tạm thời dùng approveNo nếu không có vAppId
      vAppId = processes.first.approveNo;
    } else {
      // Fallback: nếu không có process, dùng 0
      vAppId = 0;
    }

    // Reason: cứng là "Tôi thu hồi đơn"
    const reason = 'Tôi thu hồi đơn';

    // Step: cứng là 1
    const step = 1;

    return UpdateAflVosRequest(
      requestStatus: requestStatus,
      vRegId: vRegId,
      vAppId: vAppId,
      reason: reason,
      step: step,
    );
  }
}
