import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:vos_flutter/common/Services/device_id_service.dart';
import 'package:vos_flutter/common/services/keychain_test_service.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:vos_flutter/feature/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:vos_flutter/feature/profile/data/models/link_viags_request_dto.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/repositories/profile_repository.dart';
import 'package:vos_flutter/router/one_signal_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<ApiResult<UserProfile>> getUserProfile() async {
    final localProfile = await localDataSource.getUserProfile();
    if (localProfile != null) {
      return ApiResult.success(localProfile.toDomain());
    }

    final remoteResult = await remoteDataSource.getUserProfile();
    if (remoteResult.isSuccess && remoteResult.data != null) {
      await localDataSource.saveUserProfile(remoteResult.data!);
      return ApiResult.success(remoteResult.data!.toDomain());
    }

    return remoteResult.isSuccess
        ? ApiResult.success(remoteResult.data!.toDomain())
        : ApiResult.error(remoteResult.error ?? 'Failed to get user profile');
  }

  @override
  Future<ApiResult<UserProfile>> linkViagsAccount(
    String name,
    String password,
  ) async {
    try {
      final userCode = name.trim();

      String deviceId = '';
      if (Platform.isAndroid) {
        final androidId = await DeviceIdService.getAndroidId();
        deviceId = androidId ?? '';
      } else if (Platform.isIOS) {
        final keychainService = KeychainTestService();
        deviceId = await keychainService.getDeviceId();
      }

      String email = '';
      try {
        final box = Hive.box('google_user_box');
        final userData = box.get('current_user');
        if (userData != null) {
          final googleUser = GoogleUserDto.fromJson(
            Map<String, dynamic>.from(userData),
          );
          email = googleUser.email ?? '';
        }
      } catch (e) {
        email = '';
      }

      String token = '';
      try {
        final pushToken = await OneSignalService().getPushToken();
        if (pushToken != null && pushToken.isNotEmpty) {
          token = pushToken;
        } else {
          final playerId = OneSignal.User.pushSubscription.id;
          if (playerId != null && playerId.isNotEmpty) {
            token = playerId;
          }
        }
      } catch (e) {
        token = '';
      }

      final request = LinkViagsRequestDto(
        userCode: userCode,
        password: password,
        companyId: 2,
        token: token,
        language: 'VN',
        devices: deviceId.isNotEmpty ? '$deviceId.' : '',
        loginType: 'EAF',
        email: email,
      );
      print('requestlinkviags: ${request.toJson()}');

      final remoteResult = await remoteDataSource.linkViagsAccount(request);

      if (remoteResult.isSuccess && remoteResult.data != null) {
        final dto = remoteResult.data!;

        await localDataSource.saveUserProfile(dto);

        final savedEmail = dto.email.isNotEmpty ? dto.email : name;
        await localDataSource.saveViagsStatus(true, savedEmail);

        await localDataSource.saveViagsCredentials(name, password);

        return ApiResult.success(dto.toDomain());
      } else {
        return ApiResult.error(
          remoteResult.error ?? 'Failed to link VIAGS account',
        );
      }
    } catch (e) {
      return ApiResult.error('linkViagsAccount failed: $e');
    }
  }

  @override
  Future<ApiResult<void>> unlinkViagsAccount() async {
    try {
      await localDataSource.unlinkViagsAccount();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.error('unlinkViagsAccount failed: $e');
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
    final profile = await localDataSource.getUserProfile();
    return profile != null;
  }
}
