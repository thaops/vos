class UserProfileModel {
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

  UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['UserID'] as int,
      companyId: json['Company_ID'] as int,
      userCode: json['UserCode'] as String,
      userName: json['UserName'] as String,
      userType: json['UserType'] as String,
      brieftName: json['BrieftName'] as String,
      token: json['Token'] as String,
      tokenExpired: json['TokenExpired'] as String,
      language: json['Language'] as String,
      devices: json['Devices'] as String,
      description: json['Description'] as String,
      attribute: json['Attribute'] as String,
      email: json['Email'] as String,
      phone: json['Phone'] as String,
      status: json['Status'] as String,
      pwdLevel: json['Pwd_Level'] as String,
      recUserID: json['RecUserID'] as int,
      newPassword: json['NewPassword'] as String,
      companyCode: json['CompanyCode'] as String,
      companyNameVN: json['CompanyName_VN'] as String,
      companyNameEN: json['CompanyName_EN'] as String,
      masterCompanyId: json['MasterCompany_ID'] as int,
      masterCompanyCode: json['MasterCompanyCode'] as String,
      masterCompanyNameVN: json['MasterCompanyName_VN'] as String,
      masterCompanyNameEN: json['MasterCompanyName_EN'] as String,
      branchId: json['Branch_ID'] as int,
      branchCode: json['BranchCode'] as String,
      branchNameVN: json['BranchName_VN'] as String,
      branchNameEN: json['BranchName_EN'] as String,
      hrId: json['HR_ID'] as int,
      hrNo: json['HR_No'] as String,
      loginType: json['Login_Type'] as String,
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
}
