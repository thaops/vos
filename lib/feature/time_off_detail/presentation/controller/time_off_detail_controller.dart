import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/models/time_off_detail_args.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';

class TimeOffDetailController extends BaseController with ApiResultMixin {
  final TimeOffDetailArgs args;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;

  late final int vRegId = args.vRegId;

  final Rx<TimeOff?> timeOffDetail = Rx<TimeOff?>(null);

  TimeOffDetailController({
    required this.args,
    required this.getTimeOffDetailUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    loadTimeOffDetail();
  }

  Future<void> loadTimeOffDetail() async {
    await handleApiCall<TimeOff>(
      apiCall: () => getTimeOffDetailUsecase.call(vRegId: vRegId),
      onSuccess: (data) {
        timeOffDetail.value = data;
      },
    );
  }

  Future<void> onRefresh() async {
    await loadTimeOffDetail();
  }
}

