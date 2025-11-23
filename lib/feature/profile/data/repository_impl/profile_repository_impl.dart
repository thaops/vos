import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:vos_flutter/feature/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:vos_flutter/feature/profile/data/models/link_viags_request_dto.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ApiResult<UserProfile>> getUserProfile() async {
    // Ưu tiên lấy từ local trước
    final localProfile = await localDataSource.getUserProfile();
    if (localProfile != null) {
      return ApiResult.success(localProfile.toDomain());
    }

    // Nếu không có local, lấy từ remote
    final remoteResult = await remoteDataSource.getUserProfile();
    if (remoteResult.isSuccess && remoteResult.data != null) {
      // Cache vào local
      await localDataSource.saveUserProfile(remoteResult.data!);
      return ApiResult.success(remoteResult.data!.toDomain());
    }

    return remoteResult.isSuccess
        ? ApiResult.success(remoteResult.data!.toDomain())
        : ApiResult.error(remoteResult.error ?? 'Failed to get user profile');
  }

  @override
  Future<ApiResult<UserProfile>> linkViagsAccount(
      String name, String password) async {
    try {
      // Name chính là UserCode
      final userCode = name.trim();

      // Lấy Device ID
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      // Generate Token (UUID)
      final uuid = Uuid();
      final token = uuid.v4();

      final request = LinkViagsRequestDto(
        userCode: userCode,
        password: password,
        companyId: 2,
        token: token,
        language: 'VN',
        devices: deviceId.isNotEmpty ? '$deviceId.' : '',
        loginType: 'EAF',
      );

      // Call API VACS
      final remoteResult = await remoteDataSource.linkViagsAccount(request);

      if (remoteResult.isSuccess && remoteResult.data != null) {
        final dto = remoteResult.data!;

        // Cache profile từ VACS (KHÔNG xóa Google cache)
        await localDataSource.saveUserProfile(dto);

        // Lưu trạng thái liên kết - lấy email từ dto nếu có, nếu không thì dùng name
        final email = dto.email.isNotEmpty ? dto.email : name;
        await localDataSource.saveViagsStatus(true, email);

        // Lưu name và password để điền sẵn lần sau
        await localDataSource.saveViagsCredentials(name, password);

        // Không cần set is_employee nữa, vì getEmployeeStatus() sẽ tự động check profile

        return ApiResult.success(dto.toDomain());
      } else {
        return ApiResult.error(
            remoteResult.error ?? 'Failed to link VIAGS account');
      }
    } catch (e) {
      return ApiResult.error('linkViagsAccount failed: $e');
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await localDataSource.clearAll();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.error('logout failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getViagsStatus() async {
    return await localDataSource.getViagsStatus();
  }

  @override
  Future<bool> getEmployeeStatus() async {
    // Kiểm tra xem có VACS profile hay không
    // Nếu có profile VACS thì là nhân viên, nếu không có thì là khách
    final profile = await localDataSource.getUserProfile();
    return profile != null;
  }
}
