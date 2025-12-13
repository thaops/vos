import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/services/services.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/api_endpoints.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/core/network/share_Json_helper.dart';
import 'package:vos_flutter/feature/time_off/data/models/leave_location_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/leave_type_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/status_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/time_off_create_request_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/send_approve_result_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/vacation_reason_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/work_code_dto.dart';
import 'package:vos_flutter/feature/time_off/data/models/personal_vacation_dto.dart';
import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/updateafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';

abstract class TimeOffFormRemoteDataSource {
  Future<ApiResult<List<LeaveType>>> getLeaveTypes();
  Future<ApiResult<List<Status>>> getStatuses();
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  });
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons();
  Future<ApiResult<List<WorkCode>>> getWorkCodes();
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations();
  Future<ApiResult<int>> createTimeOff(TimeOffCreateRequestDto request);
  Future<ApiResult<SendApproveResult>> sendApproveRequest(int vRegId);
  Future<ApiResult<void>> recallTimeOff(int vRegId);
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  });
  Future<ApiResult<void>> updateAflVos({
    required UpdateAflVosRequest request,
    required int vRegId,
    required String email,
  });
  Future<ApiResult<PersonalVacation>> getPersonalVacation({required int hrId});
}

class TimeOffFormRemoteDataSourceImpl extends BaseShareDataSource
    implements TimeOffFormRemoteDataSource {
  TimeOffFormRemoteDataSourceImpl({required super.shareApiRepository});

  @override
  Future<ApiResult<List<LeaveType>>> getLeaveTypes() async {
    return shareApiRepository.callShareGet<List<LeaveType>>(
      functionCode: 'CODE_JOB_VACATION',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) return [];

        final leaveTypes = <LeaveType>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = LeaveTypeDto.fromJson(item);
            leaveTypes.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return leaveTypes;
      },
    );
  }

  @override
  Future<ApiResult<List<Status>>> getStatuses() async {
    return shareApiRepository.callShareGet<List<Status>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Status',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) {
          return [];
        }

        final statuses = <Status>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              continue;
            }

            final dto = StatusDto.fromJson(item);
            statuses.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return statuses;
      },
    );
  }

  @override
  Future<ApiResult<List<VacationReason>>> getVacationReasons({
    required String workCode,
    required String name,
  }) async {
    return shareApiRepository.callShareGet<List<VacationReason>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Vacation_Reason',
      token: getToken(),
      data: {'Code': workCode, 'Name': name},
      parser: (json) {
        if (json is! List) return [];

        final reasons = <VacationReason>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = VacationReasonDto.fromJson(item);
            reasons.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return reasons;
      },
    );
  }

  @override
  Future<ApiResult<List<VacationReason>>> getAllVacationReasons() async {
    return shareApiRepository.callShareGet<List<VacationReason>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Vacation_Reason',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) {
          return [];
        }

        final reasons = <VacationReason>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              continue;
            }

            final dto = VacationReasonDto.fromJson(item);
            reasons.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }

        return reasons;
      },
    );
  }

  @override
  Future<ApiResult<List<WorkCode>>> getWorkCodes() async {
    return shareApiRepository.callShareGet<List<WorkCode>>(
      functionCode: 'CODE_JOB_VACATION',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) return [];

        final workCodes = <WorkCode>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            final dto = WorkCodeDto.fromJson(item);
            workCodes.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }
        return workCodes;
      },
    );
  }

  @override
  Future<ApiResult<List<LeaveLocation>>> getLeaveLocations() async {
    return shareApiRepository.callShareGet<List<LeaveLocation>>(
      functionCode: 'EAF_HR.dbo.Vacation_Register.Dom_Int',
      token: getToken(),
      data: {},
      parser: (json) {
        if (json is! List) {
          return [];
        }

        final locations = <LeaveLocation>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) {
              continue;
            }

            final dto = LeaveLocationDto.fromJson(item);
            locations.add(dto.toDomain());
          } catch (e) {
            continue;
          }
        }

        return locations;
      },
    );
  }

  @override
  Future<ApiResult<int>> createTimeOff(TimeOffCreateRequestDto request) async {
    return shareApiRepository.callShareUpdate<int>(
      functionCode: 'Vacation_Register_Update',
      token: getToken(),
      data: request.toJson(),
      parser: (json) {
        final map = ShareJsonHelper.decode(json);
        final vRegId = ShareJsonHelper.getInt(map, 'VReg_ID');
        return vRegId;
      },
    );
  }

  @override
  Future<ApiResult<SendApproveResult>> sendApproveRequest(int vRegId) async {
    return shareApiRepository.callShareUpdateMix<SendApproveResult>(
      functionCode: 'Vacation_Approve_Creator',
      token: getToken(),
      data: {'VReg_ID': vRegId, 'CreateAgain': 'YES'},
      parser: (json) {
        // Share API trả Data là string list -> parser nhận trực tiếp list/str
        // Gói vào map với key Data để tái sử dụng logic hiện có
        final dto = SendApproveResultDto.fromMap({'Data': json});
        return dto.toDomain();
      },
    );
  }

  @override
  Future<ApiResult<void>> recallTimeOff(int vRegId) async {
    return shareApiRepository.callShareUpdate<void>(
      functionCode: 'Vacation_Approve_Status_Update',
      token: getToken(),
      data: {'VReg_ID': vRegId, 'ApproveStatus': 'BK'},
      parser: (json) => null, // void return
    );
  }

  @override
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  }) async {
    try {
      final dioApi = Get.find<DioApi>();

      // Lấy email từ cache trước - đảm bảo có giá trị
      final emailWithDefault = _getEmailFromCache();

      // Validate email trước khi dùng
      if (emailWithDefault.isEmpty) {
        return ApiResult.error('Email không được tìm thấy trong cache');
      }

      // Sau đó mới encode và gắn vào URL
      final encodedEmail = Uri.encodeComponent(emailWithDefault);
      final url = '${ApiEndpoints.createAflVosBaseUrl}/$encodedEmail';

      // Headers theo yêu cầu - dùng constants từ ApiEndpoints
      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'X-API-KEY': ApiEndpoints.vosApiKey,
        'Cookie': ApiEndpoints.vosCookie,
      };
      print("CreateNPP request: ${request.toJson()}");
      print("CreateNPP url: $url");
      print("CreateNPP headers: $headers");

      final response = await dioApi.post(
        url,
        data: request.toJson(),
        options: dioLib.Options(headers: headers),
      );
      print("CreateNPP response: ${response.data}");

      if (response.statusCode == 200) {
        return ApiResult.success(null);
      } else {
        return ApiResult.error(response.statusMessage ?? 'Unknown error');
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  String _getEmailFromCache() {
    try {
      final userProfileData = GetStorage().read('user_profile_data');
      if (userProfileData != null && userProfileData is Map) {
        final email = userProfileData['Email'] as String?;
        if (_isValidEmail(email)) {
          return email!;
        }
      }

      final viagsEmail = GetStorage().read<String>('viags_email');
      if (_isValidEmail(viagsEmail)) {
        return viagsEmail!;
      }

      return 'phongdh@viags.vn';
    } catch (e) {
      return 'phongdh@viags.vn';
    }
  }

  bool _isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email.trim());
  }

  @override
  Future<ApiResult<void>> updateAflVos({
    required UpdateAflVosRequest request,
    required int vRegId,
    required String email,
  }) async {
    try {
      final dioApi = Get.find<DioApi>();
      final services = await Services.create();
      final accessToken = await services.getAccessToken();

      // Validate email
      final emailWithDefault = _isValidEmail(email)
          ? email
          : _getEmailFromCache();
      if (emailWithDefault.isEmpty) {
        return ApiResult.error('Email không được tìm thấy');
      }

      // Encode email và build URL
      final encodedEmail = Uri.encodeComponent(emailWithDefault);
      final url =
          '${ApiEndpoints.revokeRequestVosBaseUrl}/revoke-request-vos/$vRegId?userEmail=$encodedEmail';

      // Headers với Authorization Bearer token
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'X-API-KEY': ApiEndpoints.vosApiKey,
        'Cookie': ApiEndpoints.vosCookie,
      };

      print("UpdateAflVos request: ${request.toJson()}");
      print("UpdateAflVos url: $url");

      final response = await dioApi.dio.request(
        url,
        data: request.toJson(),
        options: dioLib.Options(method: 'PATCH', headers: headers),
      );

      if (response.data['StatusCode'] == 200) {
        return ApiResult.success(response.data['Data'] ?? '');
      } else {
        return ApiResult.error(response.data['Message'] ?? 'Unknown error');
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  @override
  Future<ApiResult<PersonalVacation>> getPersonalVacation({
    required int hrId,
  }) async {
    return shareApiRepository.callShareGet<PersonalVacation>(
      functionCode: 'Pesonal_Vacation_GET',
      token: getToken(),
      data: {'HR_ID': hrId},
      parser: (json) {
        if (json is! List || json.isEmpty) {
          throw Exception('Personal vacation data trống hoặc sai định dạng');
        }

        final item = json.first;
        if (item is! Map<String, dynamic>) {
          throw Exception('Personal vacation item không hợp lệ');
        }

        final dto = PersonalVacationDto.fromJson(item);
        return dto.toDomain();
      },
    );
  }
}
