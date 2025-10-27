class LoginRequest {
  final String userCode;
  final String password;
  final String language;
  final int companyId;
  final String token;

  LoginRequest({
    required this.userCode,
    required this.password,
    this.language = 'VN',
    this.companyId = 2,
    this.token = 'E59EDD00-98BB-457B-8A68-5887097274FE',
  });

  Map<String, dynamic> toJson() {
    return {
      'UserCode': userCode,
      'Password': password,
      'Language': language,
      'Company_ID': companyId,
      'Token': token,
    };
  }
}
