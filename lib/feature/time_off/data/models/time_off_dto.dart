import 'dart:convert';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';

class TimeOffDto {
  final int vRegId;
  final int? hrId;
  final String? fromDate;
  final String? toDate;
  final String? dateReg;
  final String? domInt;
  final String? domIntName;
  final String? vacationReason;
  final String? vacationReasonName;
  final String? description;
  final String? contactPerson;
  final String? contactInfor;
  final String? status;
  final String? statusName;
  final String? recdate;
  final int? vacationNo;
  final String? appoveProcess;
  final String? appoveProcessName;
  final String? approveStatus;
  final String? lsDetail; // JSON string
  final String? lsProcess; // JSON string

  TimeOffDto({
    required this.vRegId,
    this.hrId,
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
    this.lsDetail,
    this.lsProcess,
  });

  factory TimeOffDto.fromJson(Map<String, dynamic> json) {
    return TimeOffDto(
      vRegId: json['VReg_ID'] as int? ?? 0,
      hrId: json['HR_ID'] as int?,
      fromDate: json['FromDate'] as String?,
      toDate: json['ToDate'] as String?,
      dateReg: json['DateReg'] as String?,
      domInt: json['Dom_Int'] as String?,
      domIntName: json['Dom_Int_Name'] as String?,
      vacationReason: json['Vacation_Reason'] as String?,
      vacationReasonName: json['Vacation_Reason_Name'] as String?,
      description: json['Description'] as String?,
      contactPerson: json['ContactPerson'] as String?,
      contactInfor: json['ContactInfor'] as String?,
      status: json['Status'] as String?,
      statusName: json['Status_Name'] as String?,
      recdate: json['Recdate'] as String?,
      vacationNo: json['VacationNo'] as int?,
      appoveProcess: json['AppoveProcess'] as String?,
      appoveProcessName: json['AppoveProcess_Name'] as String?,
      approveStatus: json['ApproveStatus'] as String?,
      lsDetail: json['ls_detail'] as String?,
      lsProcess: json['ls_process'] as String?,
    );
  }

  TimeOff toDomain() {
    // Parse ls_detail JSON string
    List<TimeOffDetail>? details;
    if (lsDetail != null && lsDetail!.isNotEmpty) {
      try {
        final cleanedString = lsDetail!
            .replaceAll('\r\n', '')
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .trim();
        if (cleanedString.startsWith('[')) {
          final jsonList = jsonDecode(cleanedString) as List;
          details = jsonList
              .map(
                (item) => TimeOffDetail.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        print('Error parsing ls_detail: $e');
      }
    }

    // Parse ls_process JSON string
    List<TimeOffProcess>? processes;
    if (lsProcess != null && lsProcess!.isNotEmpty) {
      try {
        final cleanedString = lsProcess!
            .replaceAll('\r\n', '')
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .trim();
        if (cleanedString.startsWith('[')) {
          final jsonList = jsonDecode(cleanedString) as List;
          processes = jsonList
              .map(
                (item) => TimeOffProcess.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        print('Error parsing ls_process: $e');
      }
    }

    return TimeOff(
      vRegId: vRegId,
      hrId: hrId,
      fromDate: (fromDate?.isNotEmpty == true)
          ? DateTime.tryParse(fromDate!)
          : null,
      toDate: (toDate?.isNotEmpty == true) ? DateTime.tryParse(toDate!) : null,
      dateReg: (dateReg?.isNotEmpty == true)
          ? DateTime.tryParse(dateReg!)
          : null,
      domInt: domInt,
      domIntName: domIntName,
      vacationReason: vacationReason,
      vacationReasonName: vacationReasonName,
      description: description,
      contactPerson: contactPerson,
      contactInfor: contactInfor,
      status: status,
      statusName: statusName,
      recdate: (recdate?.isNotEmpty == true)
          ? DateTime.tryParse(recdate!)
          : null,
      vacationNo: vacationNo,
      appoveProcess: appoveProcess,
      appoveProcessName: appoveProcessName,
      approveStatus: approveStatus,
      details: details,
      processes: processes,
    );
  }
}
