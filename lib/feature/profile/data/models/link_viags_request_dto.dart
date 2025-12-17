class LinkViagsRequestDto {
  final String userCode;
  final String password;
  final int companyId;
  final String token;
  final String language;
  final String devices;
  final String loginType;
  final String email;

  LinkViagsRequestDto({
    required this.userCode,
    required this.password,
    required this.companyId,
    required this.token,
    required this.language,
    required this.devices,
    required this.loginType,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserCode': userCode,
      'Password': password,
      'Company_ID': companyId,
      'Token': token,
      'Language': language,
      'Devices': devices,
      'Login_Type': loginType,
      'Email': email,
    };
  }

  // Convert to JSON string for Is_Data field
  String toJsonString() {
    return '{"UserCode": "$userCode", "Password": "$password", "Company_ID": $companyId, "Token": "$token", "Language": "$language", "Devices": "$devices", "Login_Type": "$loginType", "Email": "$email"}';
  }
}

