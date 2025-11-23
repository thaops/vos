import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';

class UserProfileDto {
  final int userId;
  final int companyId;
  final String userCode;
  final String userName;
  final String userType;
  final String brieftName;
  final String token;
  final String tokenExpired;
  final String language;
  final String devices;
  final String description;
  final String attribute;
  final String email;
  final String phone;
  final String status;
  final String pwdLevel;
  final int recUserID;
  final String newPassword;
  final String companyCode;
  final String companyNameVN;
  final String companyNameEN;
  final int masterCompanyId;
  final String masterCompanyCode;
  final String masterCompanyNameVN;
  final String masterCompanyNameEN;
  final int branchId;
  final String branchCode;
  final String branchNameVN;
  final String branchNameEN;
  final int hrId;
  final String hrNo;
  final String loginType;

  UserProfileDto({
    required this.userId,
    required this.companyId,
    required this.userCode,
    required this.userName,
    required this.userType,
    required this.brieftName,
    required this.token,
    required this.tokenExpired,
    required this.language,
    required this.devices,
    required this.description,
    required this.attribute,
    required this.email,
    required this.phone,
    required this.status,
    required this.pwdLevel,
    required this.recUserID,
    required this.newPassword,
    required this.companyCode,
    required this.companyNameVN,
    required this.companyNameEN,
    required this.masterCompanyId,
    required this.masterCompanyCode,
    required this.masterCompanyNameVN,
    required this.masterCompanyNameEN,
    required this.branchId,
    required this.branchCode,
    required this.branchNameVN,
    required this.branchNameEN,
    required this.hrId,
    required this.hrNo,
    required this.loginType,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      userId: json['UserID'] as int? ?? 0,
      companyId: json['Company_ID'] as int? ?? 0,
      userCode: json['UserCode'] as String? ?? '',
      userName: json['UserName'] as String? ?? '',
      userType: json['UserType'] as String? ?? 'U',
      brieftName: json['BrieftName'] as String? ?? '',
      token: json['Token'] as String? ?? '',
      tokenExpired: json['TokenExpired'] as String? ?? '',
      language: json['Language'] as String? ?? 'VN',
      devices: json['Devices'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      attribute: json['Attribute'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      phone: json['Phone'] as String? ?? '',
      status: json['Status'] as String? ?? 'OK',
      pwdLevel: json['Pwd_Level'] as String? ?? 'DIFFICULT',
      recUserID: json['RecUserID'] as int? ?? 0,
      newPassword: json['NewPassword'] as String? ?? '',
      companyCode: json['CompanyCode'] as String? ?? '',
      companyNameVN: json['CompanyName_VN'] as String? ?? '',
      companyNameEN: json['CompanyName_EN'] as String? ?? '',
      masterCompanyId: json['MasterCompany_ID'] as int? ?? 0,
      masterCompanyCode: json['MasterCompanyCode'] as String? ?? '',
      masterCompanyNameVN: json['MasterCompanyName_VN'] as String? ?? '',
      masterCompanyNameEN: json['MasterCompanyName_EN'] as String? ?? '',
      branchId: json['Branch_ID'] as int? ?? 0,
      branchCode: json['BranchCode'] as String? ?? '',
      branchNameVN: json['BranchName_VN'] as String? ?? '',
      branchNameEN: json['BranchName_EN'] as String? ?? '',
      hrId: json['HR_ID'] as int? ?? 0,
      hrNo: json['HR_No'] as String? ?? '',
      loginType: json['Login_Type'] as String? ?? 'EAF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userId,
      'Company_ID': companyId,
      'UserCode': userCode,
      'UserName': userName,
      'UserType': userType,
      'BrieftName': brieftName,
      'Token': token,
      'TokenExpired': tokenExpired,
      'Language': language,
      'Devices': devices,
      'Description': description,
      'Attribute': attribute,
      'Email': email,
      'Phone': phone,
      'Status': status,
      'Pwd_Level': pwdLevel,
      'RecUserID': recUserID,
      'NewPassword': newPassword,
      'CompanyCode': companyCode,
      'CompanyName_VN': companyNameVN,
      'CompanyName_EN': companyNameEN,
      'MasterCompany_ID': masterCompanyId,
      'MasterCompanyCode': masterCompanyCode,
      'MasterCompanyName_VN': masterCompanyNameVN,
      'MasterCompanyName_EN': masterCompanyNameEN,
      'Branch_ID': branchId,
      'BranchCode': branchCode,
      'BranchName_VN': branchNameVN,
      'BranchName_EN': branchNameEN,
      'HR_ID': hrId,
      'HR_No': hrNo,
      'Login_Type': loginType,
    };
  }

  // Convert to Domain Entity
  UserProfile toDomain() {
    return UserProfile(
      userId: userId,
      companyId: companyId,
      userCode: userCode,
      userName: userName,
      userType: userType,
      brieftName: brieftName,
      token: token,
      tokenExpired: tokenExpired,
      language: language,
      devices: devices,
      description: description,
      attribute: attribute,
      email: email,
      phone: phone,
      status: status,
      pwdLevel: pwdLevel,
      recUserID: recUserID,
      newPassword: newPassword,
      companyCode: companyCode,
      companyNameVN: companyNameVN,
      companyNameEN: companyNameEN,
      masterCompanyId: masterCompanyId,
      masterCompanyCode: masterCompanyCode,
      masterCompanyNameVN: masterCompanyNameVN,
      masterCompanyNameEN: masterCompanyNameEN,
      branchId: branchId,
      branchCode: branchCode,
      branchNameVN: branchNameVN,
      branchNameEN: branchNameEN,
      hrId: hrId,
      hrNo: hrNo,
      loginType: loginType,
    );
  }

  // Create from Domain Entity
  factory UserProfileDto.fromDomain(UserProfile profile) {
    return UserProfileDto(
      userId: profile.userId,
      companyId: profile.companyId,
      userCode: profile.userCode,
      userName: profile.userName,
      userType: profile.userType,
      brieftName: profile.brieftName,
      token: profile.token,
      tokenExpired: profile.tokenExpired,
      language: profile.language,
      devices: profile.devices,
      description: profile.description,
      attribute: profile.attribute,
      email: profile.email,
      phone: profile.phone,
      status: profile.status,
      pwdLevel: profile.pwdLevel,
      recUserID: profile.recUserID,
      newPassword: profile.newPassword,
      companyCode: profile.companyCode,
      companyNameVN: profile.companyNameVN,
      companyNameEN: profile.companyNameEN,
      masterCompanyId: profile.masterCompanyId,
      masterCompanyCode: profile.masterCompanyCode,
      masterCompanyNameVN: profile.masterCompanyNameVN,
      masterCompanyNameEN: profile.masterCompanyNameEN,
      branchId: profile.branchId,
      branchCode: profile.branchCode,
      branchNameVN: profile.branchNameVN,
      branchNameEN: profile.branchNameEN,
      hrId: profile.hrId,
      hrNo: profile.hrNo,
      loginType: profile.loginType,
    );
  }
}

