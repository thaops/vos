import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';

class TimeOffCreateRequest {
  final int vRegId;
  final DateTime fromDate;
  final DateTime? toDate;
  final String domInt;
  final String description;
  final String vacationReason;
  final String contactPerson;
  final String contactInfor;
  final String status;
  final int recUserID;
  final List<WorkCodeDetail> lsDetail;
  final List<FileAttachment> jsonAttachFiles;
  final String? approveStatus;

  const TimeOffCreateRequest({
    required this.vRegId,
    required this.fromDate,
    this.toDate,
    required this.domInt,
    required this.description,
    required this.vacationReason,
    required this.contactPerson,
    required this.contactInfor,
    required this.status,
    required this.recUserID,
    required this.lsDetail,
    this.jsonAttachFiles = const [],
    this.approveStatus,
  });

  TimeOffCreateRequest copyWith({
    int? vRegId,
    DateTime? fromDate,
    DateTime? toDate,
    String? domInt,
    String? description,
    String? vacationReason,
    String? contactPerson,
    String? contactInfor,
    String? status,
    int? recUserID,
    List<WorkCodeDetail>? lsDetail,
    List<FileAttachment>? jsonAttachFiles,
    String? approveStatus,
  }) {
    return TimeOffCreateRequest(
      vRegId: vRegId ?? this.vRegId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      domInt: domInt ?? this.domInt,
      description: description ?? this.description,
      vacationReason: vacationReason ?? this.vacationReason,
      contactPerson: contactPerson ?? this.contactPerson,
      contactInfor: contactInfor ?? this.contactInfor,
      status: status ?? this.status,
      recUserID: recUserID ?? this.recUserID,
      lsDetail: lsDetail ?? this.lsDetail,
      jsonAttachFiles: jsonAttachFiles ?? this.jsonAttachFiles,
      approveStatus: approveStatus ?? this.approveStatus,
    );
  }
}
