import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/file_attachment_dto.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';

class TimeOffCreateRequestDto {
  final int vRegId;
  final String fromDate;
  final String domInt;
  final String description;
  final String vacationReason;
  final String contactPerson;
  final String contactInfor;
  final String status;
  final int recUserID;
  final List<Map<String, dynamic>> lsDetail;
  final String jsonAttachFiles;
  final String? approveStatus;

  TimeOffCreateRequestDto({
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
    this.jsonAttachFiles = '',
    this.approveStatus,
  });

  factory TimeOffCreateRequestDto.fromDomain(TimeOffCreateRequest request) {
    final attachFilesJson = request.jsonAttachFiles.isEmpty
        ? ''
        : json.encode(
            request.jsonAttachFiles
                .map((file) => FileAttachmentDto.fromDomain(file).toJson())
                .toList(),
          );
    return TimeOffCreateRequestDto(
      vRegId: request.vRegId,
      fromDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(request.fromDate),
      domInt: request.domInt,
      description: request.description,
      vacationReason: request.vacationReason,
      contactPerson: request.contactPerson,
      contactInfor: request.contactInfor,
      status: request.status,
      recUserID: request.recUserID,
      lsDetail: request.lsDetail
          .map((detail) => {
                'JobCode': detail.jobCode,
                'SoLuong': detail.soLuong,
              })
          .toList(),
      jsonAttachFiles: attachFilesJson,
      approveStatus: request.approveStatus,
    );
  }

  Map<String, dynamic> toJson() {
    final jsonData = <String, dynamic>{
      'VReg_ID': vRegId,
      'FromDate': fromDate,
      'Dom_Int': domInt,
      'Description': description,
      'Vacation_Reason': vacationReason,
      'ContactPerson': contactPerson,
      'ContactInfor': contactInfor,
      'JsonAttachFiles': jsonAttachFiles,
      'Status': status,
      'RecUserID': recUserID,
      'ls_Detail': lsDetail,
    };
    
    if (approveStatus != null) {
      jsonData['ApproveStatus'] = approveStatus!;
    }
    
    print('📤 [TimeOffCreateDTO] toJson() - Final JSON:');
    print('   - JsonAttachFiles: ${jsonAttachFiles.isEmpty ? "RỖNG" : "${jsonAttachFiles.length} chars"}');
    if (jsonAttachFiles.isNotEmpty) {
      print('   - JsonAttachFiles value: $jsonAttachFiles');
    }
    if (approveStatus != null) {
      print('   - ApproveStatus: $approveStatus');
    }
    
    return jsonData;
  }
}

