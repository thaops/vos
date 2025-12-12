import 'dart:convert';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';

class VacationDto {
  final int vRegId;
  final int? hrId;
  final String? hrNo;
  final String? fullName;
  final String? jobTitleName;
  final String? dateReg;
  final String? fromDate;
  final String? toDate;
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
  final int? depId;
  final String? depCode;
  final String? level1Code;
  final String? level1Name;
  final String? level2Code;
  final String? level2Name;
  final String? level3Code;
  final String? level3Name;
  final double? phepTon;
  final double? overtimeTon;
  final String? appoveProcess;
  final String? approveStatus;
  final String? appoveProcessName;
  final String? approveNote;
  final String? lsDetail; // JSON string
  final String? lsProcess; // JSON string

  VacationDto({
    required this.vRegId,
    this.hrId,
    this.hrNo,
    this.fullName,
    this.jobTitleName,
    this.dateReg,
    this.fromDate,
    this.toDate,
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
    this.depId,
    this.depCode,
    this.level1Code,
    this.level1Name,
    this.level2Code,
    this.level2Name,
    this.level3Code,
    this.level3Name,
    this.phepTon,
    this.overtimeTon,
    this.appoveProcess,
    this.approveStatus,
    this.appoveProcessName,
    this.approveNote,
    this.lsDetail,
    this.lsProcess,
  });

  factory VacationDto.fromJson(Map<String, dynamic> json) {
    return VacationDto(
      vRegId: json['VReg_ID'] as int? ?? 0,
      hrId: json['HR_ID'] as int?,
      hrNo: json['HR_No'] as String?,
      fullName: json['FullName'] as String?,
      jobTitleName: json['Job_Title_Name'] as String?,
      dateReg: json['DateReg'] as String?,
      fromDate: json['FromDate'] as String?,
      toDate: json['ToDate'] as String?,
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
      depId: json['Dep_ID'] as int?,
      depCode: json['Dep_Code'] as String?,
      level1Code: json['Level_1_Code'] as String?,
      level1Name: json['Level_1_Name'] as String?,
      level2Code: json['Level_2_Code'] as String?,
      level2Name: json['Level_2_Name'] as String?,
      level3Code: json['Level_3_Code'] as String?,
      level3Name: json['Level_3_Name'] as String?,
      phepTon: json['PhepTon'] != null
          ? (json['PhepTon'] as num).toDouble()
          : null,
      overtimeTon: json['OvertimeTon'] != null
          ? (json['OvertimeTon'] as num).toDouble()
          : null,
      appoveProcess: json['AppoveProcess'] as String?,
      approveStatus: json['ApproveStatus'] as String?,
      appoveProcessName: json['AppoveProcess_Name'] as String?,
      approveNote: json['ApproveNote'] as String?,
      lsDetail: json['ls_detail'] as String?,
      lsProcess: json['ls_process'] as String?,
    );
  }

  Vacation toDomain() {
    // Parse ls_detail JSON string
    List<VacationDetail>? details;
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
                (item) => VacationDetail.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        print('Error parsing ls_detail: $e');
      }
    }

    // Parse ls_process JSON string
    List<VacationProcess>? processes;
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
                (item) => VacationProcess.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        print('Error parsing ls_process: $e');
      }
    }

    return Vacation(
      vRegId: vRegId,
      hrId: hrId,
      hrNo: hrNo,
      fullName: fullName,
      jobTitleName: jobTitleName,
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
      depId: depId,
      depCode: depCode,
      level1Code: level1Code,
      level1Name: level1Name,
      level2Code: level2Code,
      level2Name: level2Name,
      level3Code: level3Code,
      level3Name: level3Name,
      phepTon: phepTon,
      overtimeTon: overtimeTon,
      appoveProcess: appoveProcess,
      approveStatus: approveStatus,
      appoveProcessName: appoveProcessName,
      approveNote: approveNote,
      details: details,
      processes: processes,
    );
  }
}

