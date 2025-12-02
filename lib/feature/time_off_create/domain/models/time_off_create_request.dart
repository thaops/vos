import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';

class TimeOffCreateRequest {
  final int vRegId;
  final DateTime fromDate;
  final String domInt;
  final String description;
  final String vacationReason;
  final String contactPerson;
  final String contactInfor;
  final String status;
  final int recUserID;
  final List<WorkCodeDetail> lsDetail;

  const TimeOffCreateRequest({
    required this.vRegId,
    required this.fromDate,
    required this.domInt,
    required this.description,
    required this.vacationReason,
    required this.contactPerson,
    required this.contactInfor,
    required this.status,
    required this.recUserID,
    required this.lsDetail,
  });

  TimeOffCreateRequest copyWith({
    int? vRegId,
    DateTime? fromDate,
    String? domInt,
    String? description,
    String? vacationReason,
    String? contactPerson,
    String? contactInfor,
    String? status,
    int? recUserID,
    List<WorkCodeDetail>? lsDetail,
  }) {
    return TimeOffCreateRequest(
      vRegId: vRegId ?? this.vRegId,
      fromDate: fromDate ?? this.fromDate,
      domInt: domInt ?? this.domInt,
      description: description ?? this.description,
      vacationReason: vacationReason ?? this.vacationReason,
      contactPerson: contactPerson ?? this.contactPerson,
      contactInfor: contactInfor ?? this.contactInfor,
      status: status ?? this.status,
      recUserID: recUserID ?? this.recUserID,
      lsDetail: lsDetail ?? this.lsDetail,
    );
  }
}

