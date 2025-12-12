import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';
import 'package:vos_flutter/feature/vacation/domain/usecases/get_vacation_list_usecase.dart';

class VacationController extends BaseController with ApiResultMixin {
  final GetVacationListUsecase getVacationListUsecase;

  final RxList<Vacation> vacationList = <Vacation>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  List<int> get yearList {
    final currentYear = DateTime.now().year;
    return List.generate(6, (index) => currentYear - index);
  }

  VacationController({required this.getVacationListUsecase});

  @override
  void onInit() {
    super.onInit();
    loadVacationList();
  }

  Future<void> loadVacationList() async {
    // Lấy HR_ID từ ProfileController - nếu = 0 hoặc null thì dùng 1752
    int hrId = 1752; // Giá trị mặc định
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        final profile = profileController.userProfile.value;
        if (profile != null && profile.hrId > 0) {
          hrId = profile.hrId;
          print('📤 [VacationController] Using HR_ID from profile: $hrId');
        } else {
          print(
            '⚠️ [VacationController] Profile is null or HR_ID is invalid (${profile?.hrId ?? 'null'}), using default HR_ID: $hrId',
          );
        }
      } else {
        print(
          '⚠️ [VacationController] ProfileController not registered, using default HR_ID: $hrId',
        );
      }
    } catch (e) {
      print(
        '❌ [VacationController] Error getting HR_ID from ProfileController: $e, using default HR_ID: $hrId',
      );
    }

    await handleApiCall<List<Vacation>>(
      apiCall: () => getVacationListUsecase.call(
        year: selectedYear.value,
        hrId: hrId,
        viewData: '',
      ),
      onSuccess: (data) {
        vacationList.assignAll(data);
      },
    );
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    loadVacationList();
  }

  Future<void> onRefresh() async {
    await loadVacationList();
  }
}
