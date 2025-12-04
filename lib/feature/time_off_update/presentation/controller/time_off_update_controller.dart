import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';

class WorkCodeItem {
  final String code;
  final String name;
  double days;

  WorkCodeItem({required this.code, required this.name, this.days = 0.0});
}

class TimeOffUpdateController extends BaseController with ApiResultMixin {
  final TimeOffUpdateArgs args;
  final GetLeaveTypesUsecase getLeaveTypesUsecase;
  final GetStatusesUsecase getStatusesUsecase;
  final GetVacationReasonsUsecase getVacationReasonsUsecase;
  final GetAllVacationReasonsUsecase getAllVacationReasonsUsecase;
  final GetWorkCodesUsecase getWorkCodesUsecase;
  final GetLeaveLocationsUsecase getLeaveLocationsUsecase;
  final UpdateTimeOffUsecase updateTimeOffUsecase;

  late final TimeOff timeOff = args.timeOff;
  late final int vRegId = timeOff.vRegId;

  // User Info
  final RxString userName = ''.obs;
  final RxString userPosition = ''.obs;
  final RxString userDepartment = ''.obs;
  final RxInt remainingLeave = 0.obs;
  final RxInt remainingOT = 0.obs;
  final RxInt pendingLeave = 0.obs;

  // Form fields
  final RxString selectedLeaveType = ''.obs;
  final RxString selectedLeaveTypeCode = ''.obs;
  final RxList<WorkCodeItem> workCodeList = <WorkCodeItem>[].obs;
  final RxString reason = ''.obs;
  final RxString leaveLocation = ''.obs;
  final RxString leaveLocationCode = ''.obs;
  final RxString contactInfo = ''.obs;
  final RxString address = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxString selectedStatusCode = ''.obs;
  final RxString selectedVacationReason = ''.obs;
  final RxString selectedVacationReasonCode = ''.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final RxList<String> attachedFiles = <String>[].obs;

  // TextEditingControllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Dropdown options
  final RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  final RxList<String> leaveTypeOptions = <String>[].obs;
  final RxList<Status> statuses = <Status>[].obs;
  final RxList<String> statusOptions = <String>[].obs;
  final RxList<VacationReason> vacationReasons = <VacationReason>[].obs;
  final RxList<String> vacationReasonOptions = <String>[].obs;
  final RxList<WorkCode> workCodes = <WorkCode>[].obs;
  final RxList<LeaveLocation> leaveLocations = <LeaveLocation>[].obs;
  final RxList<String> leaveLocationOptions = <String>[].obs;

  TimeOffUpdateController({
    required this.args,
    required this.getLeaveTypesUsecase,
    required this.getStatusesUsecase,
    required this.getVacationReasonsUsecase,
    required this.getAllVacationReasonsUsecase,
    required this.getWorkCodesUsecase,
    required this.getLeaveLocationsUsecase,
    required this.updateTimeOffUsecase,
  });

  String get formattedFromDate {
    if (fromDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(fromDate.value!);
  }

  @override
  void onInit() {
    super.onInit();
    _setupTextControllers();
    _initializeData();
    _loadUserInfoFromProfile();
    _setupProfileListener();
    loadLeaveTypes();
  }

  void _setupProfileListener() {
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      ever(profileController.userProfile, (profile) {
        _loadUserInfoFromProfile();
      });
    }
  }

  void _loadUserInfoFromProfile() {
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      final profile = profileController.userProfile.value;

      if (profile != null) {
        userName.value = profile.userName;
        userPosition.value = profile.description.isNotEmpty
            ? profile.description
            : '';
        userDepartment.value = profile.branchNameVN.isNotEmpty
            ? profile.branchNameVN
            : profile.companyNameVN.isNotEmpty
            ? profile.companyNameVN
            : '';
      }
    }
  }

  void _setupTextControllers() {
    reasonController.addListener(() {
      reason.value = reasonController.text;
    });
    contactInfoController.addListener(() {
      contactInfo.value = contactInfoController.text;
    });
    addressController.addListener(() {
      address.value = addressController.text;
    });
  }

  @override
  void onClose() {
    reasonController.dispose();
    contactInfoController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void _initializeData() {
    remainingLeave.value = 0;
    remainingOT.value = 0;
    pendingLeave.value = 0;
  }

  Future<void> loadLeaveTypes() async {
    await handleApiCall<List<VacationReason>>(
      apiCall: () => getAllVacationReasonsUsecase.call(),
      onSuccess: (data) async {
        vacationReasons.assignAll(data);
        leaveTypeOptions.value = data.map((e) => e.nameVn).toList();
        // Load tất cả data trước, sau đó mới pre-fill
        await Future.wait([
          _loadWorkCodesIndependent(),
          _loadStatusesIndependent(),
          _loadLeaveLocationsIndependent(),
        ]);
        // Sau khi load xong tất cả data, pre-fill form
        _prefillFormData();
        // Pre-fill work codes sau khi đã load và pre-fill form
        _prefillWorkCodes();
      },
    );
  }

  Future<void> loadWorkCodes() async {
    await handleApiCall<List<WorkCode>>(
      apiCall: () => getWorkCodesUsecase.call(),
      onSuccess: (data) {
        workCodes.assignAll(data);
        workCodeList.value = data.map((workCode) {
          return WorkCodeItem(
            code: workCode.jobCode,
            name: workCode.jobName,
            days: 0,
          );
        }).toList();
      },
    );
  }

  Future<void> _loadWorkCodesIndependent() async {
    try {
      final result = await getWorkCodesUsecase.call();
      if (result.isSuccess && result.data != null) {
        workCodes.assignAll(result.data!);
        workCodeList.value = result.data!.map((workCode) {
          return WorkCodeItem(
            code: workCode.jobCode,
            name: workCode.jobName,
            days: 0,
          );
        }).toList();
      }
    } catch (e) {
      print('❌ [WorkCode] Error loading independently: $e');
    }
  }

  Future<void> loadLeaveLocations() async {
    await handleApiCall<List<LeaveLocation>>(
      apiCall: () => getLeaveLocationsUsecase.call(),
      onSuccess: (data) {
        leaveLocations.assignAll(data);
        leaveLocationOptions.value = data.map((e) => e.nameVn).toList();
      },
    );
  }

  Future<void> _loadLeaveLocationsIndependent() async {
    try {
      final result = await getLeaveLocationsUsecase.call();
      if (result.isSuccess && result.data != null) {
        leaveLocations.assignAll(result.data!);
        leaveLocationOptions.value = result.data!.map((e) => e.nameVn).toList();
      }
    } catch (e) {
      print('❌ [LeaveLocation] Error loading independently: $e');
    }
  }

  Future<void> loadStatuses() async {
    await handleApiCall<List<Status>>(
      apiCall: () => getStatusesUsecase.call(),
      onSuccess: (data) {
        statuses.assignAll(data);
        statusOptions.assignAll(data.map((e) => e.nameVn).toList());
      },
    );
  }

  Future<void> _loadStatusesIndependent() async {
    try {
      final result = await getStatusesUsecase.call();
      if (result.isSuccess && result.data != null) {
        statuses.assignAll(result.data!);
        statusOptions.assignAll(result.data!.map((e) => e.nameVn).toList());
      }
    } catch (e) {
      print('❌ [Status] Error loading independently: $e');
    }
  }

  /// Pre-fill form data từ TimeOff
  void _prefillFormData() {
    print('🔍 [Pre-fill] Starting pre-fill with data:');
    print('   Vacation_Reason: ${timeOff.vacationReason}');
    print('   Vacation_Reason_Name: ${timeOff.vacationReasonName}');
    print('   Dom_Int: ${timeOff.domInt}');
    print('   Dom_Int_Name: ${timeOff.domIntName}');
    print('   Status: ${timeOff.status}');
    print('   Status_Name: ${timeOff.statusName}');
    print('   vacationReasons.length: ${vacationReasons.length}');
    print('   leaveLocations.length: ${leaveLocations.length}');
    print('   statuses.length: ${statuses.length}');

    // Pre-fill từ ngày
    if (timeOff.fromDate != null) {
      fromDate.value = timeOff.fromDate;
    }

    // Pre-fill loại phép - tìm theo code (Vacation_Reason)
    if (timeOff.vacationReason != null && timeOff.vacationReason!.isNotEmpty) {
      selectedLeaveTypeCode.value = timeOff.vacationReason!;
      selectedVacationReasonCode.value = timeOff.vacationReason!;
      
      // Tìm name từ code để hiển thị trong dropdown
      final vacationReason = vacationReasons.firstWhereOrNull(
        (vr) => vr.code == timeOff.vacationReason,
      );
      if (vacationReason != null) {
        selectedLeaveType.value = vacationReason.nameVn;
        selectedVacationReason.value = vacationReason.nameVn;
        print('✅ [Pre-fill] Loại phép: ${vacationReason.code} -> ${vacationReason.nameVn}');
      } else if (timeOff.vacationReasonName != null &&
          timeOff.vacationReasonName!.isNotEmpty) {
        // Fallback: dùng name nếu không tìm thấy
        selectedLeaveType.value = timeOff.vacationReasonName!;
        selectedVacationReason.value = timeOff.vacationReasonName!;
        print('⚠️ [Pre-fill] Loại phép: Fallback to name: ${timeOff.vacationReasonName}');
      }
    }

    // Pre-fill nơi nghỉ - tìm theo code (Dom_Int)
    if (timeOff.domInt != null && timeOff.domInt!.isNotEmpty) {
      leaveLocationCode.value = timeOff.domInt!;
      // Tìm name từ code để hiển thị trong dropdown
      final location = leaveLocations.firstWhereOrNull(
        (loc) => loc.code == timeOff.domInt,
      );
      if (location != null) {
        leaveLocation.value = location.nameVn;
        print('✅ [Pre-fill] Nơi nghỉ: ${location.code} -> ${location.nameVn}');
      } else if (timeOff.domIntName != null &&
          timeOff.domIntName!.isNotEmpty) {
        // Fallback: dùng name nếu không tìm thấy
        leaveLocation.value = timeOff.domIntName!;
        print('⚠️ [Pre-fill] Nơi nghỉ: Fallback to name: ${timeOff.domIntName}');
      }
    }

    // Pre-fill lý do
    if (timeOff.description != null && timeOff.description!.isNotEmpty) {
      reasonController.text = timeOff.description!;
    }

    // Pre-fill thông tin liên lạc
    if (timeOff.contactPerson != null && timeOff.contactPerson!.isNotEmpty) {
      contactInfoController.text = timeOff.contactPerson!;
    }

    // Pre-fill địa chỉ
    if (timeOff.contactInfor != null && timeOff.contactInfor!.isNotEmpty) {
      addressController.text = timeOff.contactInfor!;
    }

    // Pre-fill trạng thái - tìm theo code (Status)
    if (timeOff.status != null && timeOff.status!.isNotEmpty) {
      selectedStatusCode.value = timeOff.status!;
      // Tìm name từ code để hiển thị trong dropdown
      final status = statuses.firstWhereOrNull(
        (s) => s.code == timeOff.status,
      );
      if (status != null) {
        selectedStatus.value = status.nameVn;
        print('✅ [Pre-fill] Trạng thái: ${status.code} -> ${status.nameVn}');
      } else if (timeOff.statusName != null &&
          timeOff.statusName!.isNotEmpty) {
        // Fallback: dùng name nếu không tìm thấy
        selectedStatus.value = timeOff.statusName!;
        print('⚠️ [Pre-fill] Trạng thái: Fallback to name: ${timeOff.statusName}');
      }
    }

    print('🔍 [Pre-fill] Final values:');
    print('   selectedLeaveType: ${selectedLeaveType.value}');
    print('   leaveLocation: ${leaveLocation.value}');
    print('   selectedStatus: ${selectedStatus.value}');
  }

  /// Pre-fill work codes từ TimeOff details
  void _prefillWorkCodes() {
    if (timeOff.details != null && timeOff.details!.isNotEmpty) {
      for (final detail in timeOff.details!) {
        final workCodeItem = workCodeList.firstWhereOrNull(
          (item) => item.code == detail.jobCode,
        );
        if (workCodeItem != null) {
          workCodeItem.days = detail.soLuong;
        }
      }
      workCodeList.refresh();
    }
  }

  double get totalDays {
    return workCodeList.fold(0.0, (sum, item) => sum + item.days);
  }

  void incrementDays(int index) {
    if (index < workCodeList.length) {
      workCodeList[index].days += 0.5;
      workCodeList.refresh();
    }
  }

  void decrementDays(int index) {
    if (index < workCodeList.length && workCodeList[index].days > 0) {
      workCodeList[index].days -= 0.5;
      workCodeList.refresh();
    }
  }

  Future<void> loadVacationReasons({
    required String workCode,
    required String name,
  }) async {
    await handleApiCall<List<VacationReason>>(
      apiCall: () =>
          getVacationReasonsUsecase.call(workCode: workCode, name: name),
      onSuccess: (data) {
        vacationReasons.assignAll(data);
        vacationReasonOptions.value = data.map((e) => e.nameVn).toList();
      },
    );
  }

  void onVacationReasonChanged(String? value) {
    if (value != null) {
      selectedVacationReason.value = value;
      final vacationReason = vacationReasons.firstWhereOrNull(
        (e) => e.nameVn == value,
      );
      if (vacationReason != null) {
        selectedVacationReasonCode.value = vacationReason.code;
      }
    }
  }

  void onLeaveTypeChanged(String? value) {
    if (value != null) {
      selectedLeaveType.value = value;
      final vacationReason = vacationReasons.firstWhereOrNull(
        (e) => e.nameVn == value,
      );
      if (vacationReason != null) {
        selectedLeaveTypeCode.value = vacationReason.code;
        selectedVacationReasonCode.value = vacationReason.code;
      }
    }
  }

  void onStatusChanged(String? value) {
    if (value != null) {
      selectedStatus.value = value;
      final status = statuses.firstWhereOrNull((e) => e.nameVn == value);
      if (status != null) {
        selectedStatusCode.value = status.code;
      }
    }
  }

  void onLeaveLocationChanged(String? value) {
    if (value != null) {
      leaveLocation.value = value;
      final location = leaveLocations.firstWhereOrNull(
        (e) => e.nameVn == value,
      );
      if (location != null) {
        leaveLocationCode.value = location.code;
      }
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      fromDate.value = picked;
    }
  }

  TimeOffCreateRequest _buildRequestData() {
    int userId = 0;
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      userId = profileController.userProfile.value?.userId ?? 0;
    }

    final selectedWorkCodes = workCodeList
        .where((item) => item.days > 0)
        .toList();
    final lsDetail = selectedWorkCodes
        .map(
          (item) =>
              WorkCodeDetail(jobCode: item.code, soLuong: item.days.toDouble()),
        )
        .toList();

    String vacationReasonCode = selectedVacationReasonCode.value;
    if (vacationReasonCode.isEmpty) {
      vacationReasonCode = selectedLeaveTypeCode.value;
    }

    return TimeOffCreateRequest(
      vRegId: vRegId, // Update: dùng VReg_ID của đơn đó
      fromDate: fromDate.value ?? timeOff.fromDate ?? DateTime.now(),
      domInt: leaveLocationCode.value,
      description: reasonController.text,
      vacationReason: vacationReasonCode,
      contactPerson: contactInfoController.text.isEmpty
          ? 'Không có'
          : contactInfoController.text,
      contactInfor: addressController.text,
      status: selectedStatusCode.value,
      recUserID: userId,
      lsDetail: lsDetail,
    );
  }

  Future<void> onSubmit() async {
    if (fromDate.value == null) {
      fromDate.value = timeOff.fromDate ?? DateTime.now();
    }

    if (selectedLeaveTypeCode.value.isEmpty) {
      CustomSnackbar.show('Vui lòng chọn loại phép');
      return;
    }

    if (workCodeList.where((item) => item.days > 0).isEmpty) {
      CustomSnackbar.show('Vui lòng chọn ít nhất một mã công việc');
      return;
    }
    if (leaveLocationCode.value.isEmpty) {
      CustomSnackbar.show('Vui lòng chọn nơi nghỉ');
      return;
    }
    if (selectedStatusCode.value.isEmpty) {
      CustomSnackbar.show('Vui lòng chọn trạng thái');
      return;
    }

    final request = _buildRequestData();

    await handleApiCallVoid(
      apiCall: () => updateTimeOffUsecase.call(request),
      onSuccess: () {
        Get.back(result: true);
      },
    );
  }

  Future<void> onSaveDraft() async {
    if (fromDate.value == null) {
      fromDate.value = timeOff.fromDate ?? DateTime.now();
    }

    final request = _buildRequestData();

    await handleApiCallVoid(
      apiCall: () => updateTimeOffUsecase.call(request),
      onSuccess: () {
        CustomSnackbar.show('Đã lưu tạm thành công');
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: true);
        });
      },
    );
  }

  void onFileAttached(String filePath) {
    attachedFiles.add(filePath);
  }

  void removeFile(int index) {
    if (index < attachedFiles.length) {
      attachedFiles.removeAt(index);
    }
  }
}
