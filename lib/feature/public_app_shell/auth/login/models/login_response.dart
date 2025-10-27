class LoginResponse {
  final int resultCode;
  final String message;
  final int totalRecord;
  final LoginData? data;

  LoginResponse({
    required this.resultCode,
    required this.message,
    required this.totalRecord,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      resultCode: json['ResultCode'] ?? -1,
      message: json['Message'] ?? '',
      totalRecord: json['TotalRecord'] ?? 0,
      data: json['Data'] != null ? LoginData.fromJson(json['Data']) : null,
    );
  }

  bool get isSuccess => resultCode == 0;
}

class LoginData {
  final int userId;
  final int companyId;
  final String userCode;
  final String userName;
  final String userType;
  final String briefName;
  final String password;
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
  final int recUserId;
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

  LoginData({
    required this.userId,
    required this.companyId,
    required this.userCode,
    required this.userName,
    required this.userType,
    required this.briefName,
    required this.password,
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
    required this.recUserId,
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

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      userId: json['UserID'] ?? 0,
      companyId: json['Company_ID'] ?? 0,
      userCode: json['UserCode'] ?? '',
      userName: json['UserName'] ?? '',
      userType: json['UserType'] ?? '',
      briefName: json['BrieftName'] ?? '',
      password: json['Password'] ?? '',
      token: json['Token'] ?? '',
      tokenExpired: json['TokenExpired'] ?? '',
      language: json['Language'] ?? '',
      devices: json['Devices'] ?? '',
      description: json['Description'] ?? '',
      attribute: json['Attribute'] ?? '',
      email: json['Email'] ?? '',
      phone: json['Phone'] ?? '',
      status: json['Status'] ?? '',
      pwdLevel: json['Pwd_Level'] ?? '',
      recUserId: json['RecUserID'] ?? 0,
      newPassword: json['NewPassword'] ?? '',
      companyCode: json['CompanyCode'] ?? '',
      companyNameVN: json['CompanyName_VN'] ?? '',
      companyNameEN: json['CompanyName_EN'] ?? '',
      masterCompanyId: json['MasterCompany_ID'] ?? 0,
      masterCompanyCode: json['MasterCompanyCode'] ?? '',
      masterCompanyNameVN: json['MasterCompanyName_VN'] ?? '',
      masterCompanyNameEN: json['MasterCompanyName_EN'] ?? '',
      branchId: json['Branch_ID'] ?? 0,
      branchCode: json['BranchCode'] ?? '',
      branchNameVN: json['BranchName_VN'] ?? '',
      branchNameEN: json['BranchName_EN'] ?? '',
      hrId: json['HR_ID'] ?? 0,
      hrNo: json['HR_No'] ?? '',
      loginType: json['Login_Type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userId,
      'Company_ID': companyId,
      'UserCode': userCode,
      'UserName': userName,
      'UserType': userType,
      'BrieftName': briefName,
      'Password': password,
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
      'RecUserID': recUserId,
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
