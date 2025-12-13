import 'dart:convert';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';

class PersonalVacationDto {
  final int hrId;
  final String hrNo;
  final String fullName;
  final String? birthDay;
  final String? majorDate;
  final String? companyDate;
  final String? codeSex;
  final String? mobile1;
  final String? mobile2;
  final String? email;
  final String? address;
  final String? permanent;
  final String? departments;
  final String? codeJobTitle;
  final String? jobTitleNameVN;
  final double? paidLeaveYear;
  final double? paidLeaveUsedTotal;
  final double? paidLeaveRemain;
  final double? paidLeaveRemainEarly;
  final double? overTimeRemain;

  PersonalVacationDto({
    required this.hrId,
    required this.hrNo,
    required this.fullName,
    this.birthDay,
    this.majorDate,
    this.companyDate,
    this.codeSex,
    this.mobile1,
    this.mobile2,
    this.email,
    this.address,
    this.permanent,
    this.departments,
    this.codeJobTitle,
    this.jobTitleNameVN,
    this.paidLeaveYear,
    this.paidLeaveUsedTotal,
    this.paidLeaveRemain,
    this.paidLeaveRemainEarly,
    this.overTimeRemain,
  });

  factory PersonalVacationDto.fromJson(Map<String, dynamic> json) {
    return PersonalVacationDto(
      hrId: json['HR_ID'] as int? ?? 0,
      hrNo: json['HR_No'] as String? ?? '',
      fullName: json['FullName'] as String? ?? '',
      birthDay: json['BirthDay'] as String?,
      majorDate: json['MajorDate'] as String?,
      companyDate: json['CompanyDate'] as String?,
      codeSex: json['Code_Sex'] as String?,
      mobile1: json['Mobile_1'] as String?,
      mobile2: json['Mobile_2'] as String?,
      email: json['Email'] as String?,
      address: json['Address'] as String?,
      permanent: json['Permanent'] as String?,
      departments: json['Departments'] as String?,
      codeJobTitle: json['Code_Job_Title'] as String?,
      jobTitleNameVN: json['JobTitle_NameVN'] as String?,
      paidLeaveYear: (json['PaidLeave_Year'] as num?)?.toDouble(),
      paidLeaveUsedTotal: (json['PaidLeave_Used_Total'] as num?)?.toDouble(),
      paidLeaveRemain: (json['PaidLeave_Remain'] as num?)?.toDouble(),
      paidLeaveRemainEarly: (json['PaidLeave_Remain_Early'] as num?)?.toDouble(),
      overTimeRemain: (json['OverTime_Remain'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HR_ID': hrId,
      'HR_No': hrNo,
      'FullName': fullName,
      'BirthDay': birthDay,
      'MajorDate': majorDate,
      'CompanyDate': companyDate,
      'Code_Sex': codeSex,
      'Mobile_1': mobile1,
      'Mobile_2': mobile2,
      'Email': email,
      'Address': address,
      'Permanent': permanent,
      'Departments': departments,
      'Code_Job_Title': codeJobTitle,
      'JobTitle_NameVN': jobTitleNameVN,
      'PaidLeave_Year': paidLeaveYear,
      'PaidLeave_Used_Total': paidLeaveUsedTotal,
      'PaidLeave_Remain': paidLeaveRemain,
      'PaidLeave_Remain_Early': paidLeaveRemainEarly,
      'OverTime_Remain': overTimeRemain,
    };
  }

  PersonalVacation toDomain() {
    // Parse Departments JSON string nếu có
    String? departmentName;
    if (departments != null && departments!.isNotEmpty) {
      try {
        final deptList = jsonDecode(departments!) as List;
        if (deptList.isNotEmpty) {
          // Lấy department cuối cùng (department nhỏ nhất)
          final lastDept = deptList.last as Map<String, dynamic>;
          departmentName = lastDept['Name_VN'] as String?;
        }
      } catch (e) {
        print('Error parsing departments: $e');
      }
    }

    return PersonalVacation(
      hrId: hrId,
      hrNo: hrNo,
      fullName: fullName,
      jobTitleNameVN: jobTitleNameVN ?? '',
      departmentName: departmentName ?? '',
      paidLeaveRemain: paidLeaveRemain?.toInt() ?? 0,
      overTimeRemain: overTimeRemain?.toInt() ?? 0,
      paidLeaveUsedTotal: paidLeaveUsedTotal?.toInt() ?? 0,
    );
  }

  factory PersonalVacationDto.fromDomain(PersonalVacation domain) {
    return PersonalVacationDto(
      hrId: domain.hrId,
      hrNo: domain.hrNo,
      fullName: domain.fullName,
      jobTitleNameVN: domain.jobTitleNameVN,
      departments: domain.departmentName,
      paidLeaveRemain: domain.paidLeaveRemain.toDouble(),
      overTimeRemain: domain.overTimeRemain.toDouble(),
      paidLeaveUsedTotal: domain.paidLeaveUsedTotal.toDouble(),
    );
  }
}

