import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';

class AuthorizeDto {
  final int authorizeId;
  final int companyId;
  final int hrId;
  final int depId;
  final int idLevelTitle;
  final int idJobTitle;
  final int forHrId;
  final int forDepId;
  final int forIdLevelTitle;
  final int forIdJobTitle;
  final String fromDate;
  final String toDate;
  final String description;
  final String lsAuthorize;
  final String status;
  final String recdate;
  final int recUserID;
  final String hrNo;
  final String fullName;
  final String nameJobTitle;
  final String nameLevelTitle;
  final String depCode;
  final String depName;
  final String depLevel2Code;
  final String depLevel3Code;
  final String forHrNo;
  final String forFullName;
  final String forNameJobTitle;
  final String forNameLevelTitle;
  final String forDepCode;
  final String forDepName;
  final String forDepLevel2Code;
  final String forDepLevel3Code;

  AuthorizeDto({
    required this.authorizeId,
    required this.companyId,
    required this.hrId,
    required this.depId,
    required this.idLevelTitle,
    required this.idJobTitle,
    required this.forHrId,
    required this.forDepId,
    required this.forIdLevelTitle,
    required this.forIdJobTitle,
    required this.fromDate,
    required this.toDate,
    required this.description,
    required this.lsAuthorize,
    required this.status,
    required this.recdate,
    required this.recUserID,
    required this.hrNo,
    required this.fullName,
    required this.nameJobTitle,
    required this.nameLevelTitle,
    required this.depCode,
    required this.depName,
    required this.depLevel2Code,
    required this.depLevel3Code,
    required this.forHrNo,
    required this.forFullName,
    required this.forNameJobTitle,
    required this.forNameLevelTitle,
    required this.forDepCode,
    required this.forDepName,
    required this.forDepLevel2Code,
    required this.forDepLevel3Code,
  });

  factory AuthorizeDto.fromJson(Map<String, dynamic> json) {
    return AuthorizeDto(
      authorizeId: json['Authorize_ID'] as int? ?? 0,
      companyId: json['Company_ID'] as int? ?? 0,
      hrId: json['HR_ID'] as int? ?? 0,
      depId: json['Dep_ID'] as int? ?? 0,
      idLevelTitle: json['ID_Level_Title'] as int? ?? 0,
      idJobTitle: json['ID_Job_Title'] as int? ?? 0,
      forHrId: json['forHR_ID'] as int? ?? 0,
      forDepId: json['forDep_ID'] as int? ?? 0,
      forIdLevelTitle: json['forID_Level_Title'] as int? ?? 0,
      forIdJobTitle: json['forID_Job_Title'] as int? ?? 0,
      fromDate: json['FromDate'] as String? ?? '',
      toDate: json['ToDate'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      lsAuthorize: json['ls_Authorize'] as String? ?? '',
      status: json['Status'] as String? ?? '',
      recdate: json['Recdate'] as String? ?? '',
      recUserID: json['RecUserID'] as int? ?? 0,
      hrNo: json['HR_No'] as String? ?? '',
      fullName: json['FullName'] as String? ?? '',
      nameJobTitle: json['Name_Job_Title'] as String? ?? '',
      nameLevelTitle: json['Name_Level_Title'] as String? ?? '',
      depCode: json['Dep_Code'] as String? ?? '',
      depName: json['Dep_Name'] as String? ?? '',
      depLevel2Code: json['Dep_Level_2_Code'] as String? ?? '',
      depLevel3Code: json['Dep_Level_3_Code'] as String? ?? '',
      forHrNo: json['forHR_No'] as String? ?? '',
      forFullName: json['forFullName'] as String? ?? '',
      forNameJobTitle: json['forName_Job_Title'] as String? ?? '',
      forNameLevelTitle: json['forName_Level_Title'] as String? ?? '',
      forDepCode: json['forDep_Code'] as String? ?? '',
      forDepName: json['forDep_Name'] as String? ?? '',
      forDepLevel2Code: json['forDep_Level_2_Code'] as String? ?? '',
      forDepLevel3Code: json['forDep_Level_3_Code'] as String? ?? '',
    );
  }

  Authorize toDomain() {
    return Authorize(
      authorizeId: authorizeId,
      companyId: companyId,
      hrId: hrId,
      depId: depId,
      idLevelTitle: idLevelTitle,
      idJobTitle: idJobTitle,
      forHrId: forHrId,
      forDepId: forDepId,
      forIdLevelTitle: forIdLevelTitle,
      forIdJobTitle: forIdJobTitle,
      fromDate: fromDate,
      toDate: toDate,
      description: description,
      lsAuthorize: lsAuthorize,
      status: status,
      recdate: recdate,
      recUserID: recUserID,
      hrNo: hrNo,
      fullName: fullName,
      nameJobTitle: nameJobTitle,
      nameLevelTitle: nameLevelTitle,
      depCode: depCode,
      depName: depName,
      depLevel2Code: depLevel2Code,
      depLevel3Code: depLevel3Code,
      forHrNo: forHrNo,
      forFullName: forFullName,
      forNameJobTitle: forNameJobTitle,
      forNameLevelTitle: forNameLevelTitle,
      forDepCode: forDepCode,
      forDepName: forDepName,
      forDepLevel2Code: forDepLevel2Code,
      forDepLevel3Code: forDepLevel3Code,
    );
  }
}

