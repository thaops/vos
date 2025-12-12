import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/base_share_datasource.dart';
import 'package:vos_flutter/feature/vacation/data/models/vacation_dto.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';

abstract class VacationRemoteDataSource {
  Future<ApiResult<List<Vacation>>> getVacationList({
    int year = 0,
    int hrId = 0,
    String viewData = '',
  });
}

class VacationRemoteDataSourceImpl extends BaseShareDataSource
    implements VacationRemoteDataSource {
  VacationRemoteDataSourceImpl({required super.shareApiRepository});

  @override
  Future<ApiResult<List<Vacation>>> getVacationList({
    int year = 0,
    int hrId = 0,
    String viewData = '',
  }) async {
    return shareApiRepository.callShareGet<List<Vacation>>(
      functionCode: 'Vacation_Get',
      token: getToken(),
      data: {
        'Year': year,
        'HR_ID': hrId,
        'ViewData': viewData,
      },
      parser: (json) {
        if (json is! List) return [];

        final vacations = <Vacation>[];
        for (int i = 0; i < json.length; i++) {
          try {
            final item = json[i];
            if (item is! Map<String, dynamic>) continue;

            // Skip items where all values are null
            final allNull = item.values.every((value) => value == null);
            if (allNull) continue;

            final dto = VacationDto.fromJson(item);
            vacations.add(dto.toDomain());
          } catch (e) {
            print('Error parsing vacation item: $e');
            continue;
          }
        }

        return vacations;
      },
    );
  }
}

