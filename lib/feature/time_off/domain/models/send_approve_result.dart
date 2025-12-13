import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';

class SendApproveResult {
  final int vRegId;
  final List<ApprovalItem> approvals;

  SendApproveResult({
    required this.vRegId,
    required this.approvals,
  });
}
