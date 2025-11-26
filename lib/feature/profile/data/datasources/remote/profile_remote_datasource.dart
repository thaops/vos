import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/share_api_repository.dart';
import 'package:vos_flutter/feature/profile/data/models/link_viags_request_dto.dart';
import 'package:vos_flutter/feature/profile/data/models/user_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<ApiResult<UserProfileDto>> getUserProfile();
  Future<ApiResult<UserProfileDto>> linkViagsAccount(LinkViagsRequestDto request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ShareApiRepository shareApiRepository;

  ProfileRemoteDataSourceImpl({required this.shareApiRepository});

  @override
  Future<ApiResult<UserProfileDto>> getUserProfile() async {
    try {
      // TODO: Implement get user profile API if needed
      return ApiResult.error('Not implemented');
    } catch (e) {
      return ApiResult.error('getUserProfile failed: $e');
    }
  }

  @override
  Future<ApiResult<UserProfileDto>> linkViagsAccount(
      LinkViagsRequestDto request) async {
    // Parse request data
    final requestData = request.toJson();
    
    return shareApiRepository.callShareUpdate<UserProfileDto>(
      functionCode: 'MOBI_LOGIN',
      token: '', // Profile API không dùng token trong header
      data: requestData,
      parser: (json) {
        if (json is! Map<String, dynamic>) {
          throw Exception('No data in response');
        }
        return UserProfileDto.fromJson(json);
      },
    );
  }
}

