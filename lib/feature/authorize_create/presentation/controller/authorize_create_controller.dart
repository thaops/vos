import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/create_authorize_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/load_authorize_statuses_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/load_authorize_types_usecase.dart';
import 'package:vos_flutter/feature/authorize_create/domain/usecases/search_authorized_persons_usecase.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class AuthorizeCreateController extends BaseController with ApiResultMixin {
  final SearchAuthorizedPersonsUsecase searchAuthorizedPersonsUsecase;
  final LoadAuthorizeTypesUsecase loadAuthorizeTypesUsecase;
  final LoadAuthorizeStatusesUsecase loadAuthorizeStatusesUsecase;
  final CreateAuthorizeUsecase createAuthorizeUsecase;

  final Rxn<Map<String, dynamic>> selectedDelegate =
      Rxn<Map<String, dynamic>>();
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();
  final Rxn<String> selectedAuthorizeType = Rxn<String>();
  final RxString selectedStatus = 'OK'.obs;

  final RxList<Map<String, dynamic>> authorizedPersons =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, String>> authorizeTypes =
      <Map<String, String>>[].obs;
  final RxList<Map<String, String>> statuses = <Map<String, String>>[].obs;

  final RxBool isLoadingPersons = false.obs;
  final RxBool isLoadingAuthorizeTypes = false.obs;
  final RxBool isLoadingStatuses = false.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController delegateSearchController =
      TextEditingController();
  final TextEditingController authorizeTypeController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  String get token => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>().userProfile.value?.token ?? ''
      : '';

  int get hrId => Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>().userProfile.value?.hrId ?? 0
      : 0;

  AuthorizeCreateController({
    required this.searchAuthorizedPersonsUsecase,
    required this.loadAuthorizeTypesUsecase,
    required this.loadAuthorizeStatusesUsecase,
    required this.createAuthorizeUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    _initDefaultDates();
    _loadInitialData();
  }

  @override
  void onClose() {
    delegateSearchController.dispose();
    authorizeTypeController.dispose();
    statusController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([loadAuthorizeTypes(), loadStatuses()]);
  }

  Future<List<Map<String, dynamic>>> searchAuthorizedPersons(
    String query,
  ) async {
    if (query.trim().isEmpty || token.isEmpty) return [];

    isLoadingPersons.value = true;
    try {
      final result = await searchAuthorizedPersonsUsecase.call(token, query);
      if (result.isSuccess && result.data != null) {
        authorizedPersons.assignAll(result.data!);
        return result.data!;
      }
      return [];
    } catch (e) {
      return [];
    } finally {
      isLoadingPersons.value = false;
    }
  }

  Future<void> loadAuthorizeTypes() async {
    if (token.isEmpty) return;
    isLoadingAuthorizeTypes.value = true;
    try {
      final result = await loadAuthorizeTypesUsecase.call(token);
      if (result.isSuccess && result.data != null) {
        authorizeTypes.assignAll(result.data!);
        if (result.data!.isNotEmpty && selectedAuthorizeType.value == null) {
          selectedAuthorizeType.value = result.data!.first['code'];
          authorizeTypeController.text = result.data!.first['name'] ?? '';
        }
      }
    } catch (e) {
    } finally {
      isLoadingAuthorizeTypes.value = false;
    }
  }

  Future<void> loadStatuses() async {
    if (token.isEmpty) return;
    isLoadingStatuses.value = true;
    try {
      final result = await loadAuthorizeStatusesUsecase.call(token);
      if (result.isSuccess && result.data != null) {
        statuses.assignAll(result.data!);
        final selectedItem = result.data!.firstWhere(
          (item) => item['code'] == selectedStatus.value,
          orElse: () => <String, String>{},
        );
        if (selectedItem.isNotEmpty) {
          statusController.text = selectedItem['name'] ?? '';
        }
      }
    } catch (e) {
    } finally {
      isLoadingStatuses.value = false;
    }
  }

  void selectDelegate(Map<String, dynamic> person) {
    selectedDelegate.value = person;
    delegateSearchController.text =
        '${person['FullName']} (${person['HR_No']})';
  }

  void clearDelegate() {
    selectedDelegate.value = null;
    delegateSearchController.clear();
  }

  void selectAuthorizeType(String? code) {
    selectedAuthorizeType.value = code;
    if (code != null) {
      final selectedItem = authorizeTypes.firstWhere(
        (item) => item['code'] == code,
        orElse: () => <String, String>{},
      );
      authorizeTypeController.text = selectedItem['name'] ?? '';
    } else {
      authorizeTypeController.clear();
    }
  }

  void selectStatus(String? code) {
    selectedStatus.value = code ?? 'OK';
    if (code != null) {
      final selectedItem = statuses.firstWhere(
        (item) => item['code'] == code,
        orElse: () => <String, String>{},
      );
      statusController.text = selectedItem['name'] ?? '';
    } else {
      statusController.clear();
    }
  }

  void _initDefaultDates() {
    // Mặc định: ngày mai 00:00 đến 23:59
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    fromDate.value = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      0,
      0,
    );
    toDate.value = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      23,
      59,
    );
  }

  Future<void> selectFromDate(DateTime dateTime) async {
    fromDate.value = dateTime;

    // Nếu ToDate trước FromDate thì đẩy ToDate cùng ngày, 23:59
    if (toDate.value != null && toDate.value!.isBefore(dateTime)) {
      final d = dateTime;
      toDate.value = DateTime(d.year, d.month, d.day, 23, 59);
    }
  }

  Future<void> selectToDate(DateTime dateTime) async {
    toDate.value = dateTime;
  }

  String? get formattedFromDate => fromDate.value != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(fromDate.value!)
      : null;

  String? get formattedToDate => toDate.value != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(toDate.value!)
      : null;

  Future<void> createAuthorize() async {
    if (selectedDelegate.value == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn người được ủy quyền',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }
    if (fromDate.value == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn từ ngày',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }
    if (selectedAuthorizeType.value == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn loại ủy quyền',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    final delegateHrId = selectedDelegate.value!['HR_ID'] as int? ?? 0;
    if (delegateHrId == 0) {
      Get.snackbar(
        'Lỗi',
        'Thông tin nhân sự không hợp lệ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final payload = {
        'Authorize_ID': 0,
        'HR_ID': hrId,
        'forHR_ID': delegateHrId,
        'FromDate': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(fromDate.value!),
        'ToDate': toDate.value != null
            ? DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(toDate.value!)
            : '1900-01-01T00:00:00',
        'Description': '',
        'ls_Authorize': selectedAuthorizeType.value,
        'Status': selectedStatus.value,
      };
      final result = await createAuthorizeUsecase.call(token, payload);

      if (result.isSuccess) {
        await SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Tạo ủy quyền thành công',
          buttonText: 'Đóng',
          onClose: () {
            Get.back(result: true);
          },
        );
      } else {
        await SuccessDialog.show(
          context: Get.context!,
          title: 'Không thành công',
          message: result.error ?? 'Tạo ủy quyền thất bại',
          buttonText: 'Đóng',
        );
      }
    } catch (e) {
      await SuccessDialog.show(
        context: Get.context!,
        title: 'Không thành công',
        message: 'Có lỗi xảy ra khi tạo ủy quyền: ${e.toString()}',
        buttonText: 'Đóng',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
