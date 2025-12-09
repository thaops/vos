import 'package:dio/dio.dart' as dioLib;
import 'package:get/get.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/core/network/dio_api.dart';
import 'package:vos_flutter/core/network/share_Json_helper.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/leave_location_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/leave_type_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/status_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/time_off_create_request_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/vacation_reason_dto.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/work_code_dto.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';

abstract class TimeOffCreateRemoteDataSource {
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
  Future<ApiResult<int>> sendApproveRequest(int vRegId);
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  });
}

class TimeOffCreateRemoteDataSourceImpl extends BaseShareDataSource
    implements TimeOffCreateRemoteDataSource {
  TimeOffCreateRemoteDataSourceImpl({required super.shareApiRepository});

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
          } catch (e, stackTrace) {
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
        print('🔍 [createTimeOff] Parser data: $vRegId');
        return vRegId;
      },
    );
  }

  @override
  Future<ApiResult<int>> sendApproveRequest(int vRegId) async {
    return shareApiRepository.callShareUpdateMix<int>(
      functionCode: 'Vacation_Approve_Creator',
      token: getToken(),
      data: {'VReg_ID': vRegId, 'CreateAgain': 'YES'},
      parser: (json) {
        final map = ShareJsonHelper.decode(json);
        return ShareJsonHelper.getInt(map, 'VReg_ID');
      },
    );
  }

  @override
  Future<ApiResult<void>> createAflVos({
    required CreateAflVosRequest request,
    required String email,
  }) async {
    try {
      final dioApi = Get.find<DioApi>();

      // URL với email encoded
      final emailWithDefault = email ?? 'phongdh@viags.vn';
      final encodedEmail = Uri.encodeComponent(emailWithDefault);
      final url =
          'https://viagsapi-eoffice-dev.azurewebsites.net/api/vos/createafl_vos/$encodedEmail';

      // Headers theo yêu cầu
      final headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
        'X-API-KEY':
            '8492f144615571ac043b943e58471ba3bc37d7a59d065b1e6ff2d0106c1a1dc2',
        'Cookie':
            'ARRAffinity=a6e48b9e9d2653435be7b61998d8624b44115214104213d6c8b8c526cc56dc70; ARRAffinitySameSite=a6e48b9e9d2653435be7b61998d8624b44115214104213d6c8b8c526cc56dc70',
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
}
