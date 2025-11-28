import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';

class WorkCodeItem {
  final String code;
  final String name;
  int days;

  WorkCodeItem({required this.code, required this.name, this.days = 0});
}

class TimeOffCreateController extends BaseController with ApiResultMixin {
  final GetLeaveTypesUsecase getLeaveTypesUsecase;
  final GetStatusesUsecase getStatusesUsecase;

  // User Info
  final RxString userName = ''.obs;
  final RxString userPosition = ''.obs;
  final RxString userDepartment = ''.obs;
  final RxInt remainingLeave = 0.obs;
  final RxInt remainingOT = 0.obs;
  final RxInt pendingLeave = 0.obs;

  // Form fields
  final RxString selectedLeaveType = ''.obs;
  final RxList<WorkCodeItem> workCodeList = <WorkCodeItem>[].obs;
  final RxString reason = ''.obs;
  final RxString leaveLocation = ''.obs;
  final RxString contactInfo = ''.obs;
  final RxString address = ''.obs;
  final RxString selectedStatus = ''.obs;
  final RxList<String> attachedFiles = <String>[].obs;

  // TextEditingControllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController leaveLocationController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Dropdown options
  final RxList<LeaveType> leaveTypes = <LeaveType>[].obs;
  final RxList<String> leaveTypeOptions = <String>[].obs;
  final RxList<Status> statuses = <Status>[].obs;
  final RxList<String> statusOptions = <String>[].obs;

  TimeOffCreateController({
    required this.getLeaveTypesUsecase,
    required this.getStatusesUsecase,
  });

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
    // Listen profile changes và tự động update user info
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
    leaveLocationController.addListener(() {
      leaveLocation.value = leaveLocationController.text;
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
    leaveLocationController.dispose();
    contactInfoController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void _initializeData() {
    // remainingLeave, remainingOT, pendingLeave - cần API riêng hoặc lấy từ profile nếu có
    // Tạm thời giữ giá trị mặc định
    remainingLeave.value = 0;
    remainingOT.value = 0;
    pendingLeave.value = 0;

    workCodeList.value = [
      WorkCodeItem(code: '001', name: 'Mã công 1'),
      WorkCodeItem(code: '002', name: 'Mã công 2'),
      WorkCodeItem(code: '003', name: 'Mã công 3'),
    ];
  }

  Future<void> loadLeaveTypes() async {
    await handleApiCall<List<LeaveType>>(
      apiCall: () => getLeaveTypesUsecase.call(),
      onSuccess: (data) {
        leaveTypes.assignAll(data);
        leaveTypeOptions.value = data.map((e) => e.jobName).toList();
        loadStatuses();
      },
    );
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

  int get totalDays {
    return workCodeList.fold(0, (sum, item) => sum + item.days);
  }

  void incrementDays(int index) {
    if (index < workCodeList.length) {
      workCodeList[index].days++;
      workCodeList.refresh();
    }
  }

  void decrementDays(int index) {
    if (index < workCodeList.length && workCodeList[index].days > 0) {
      workCodeList[index].days--;
      workCodeList.refresh();
    }
  }

  void onLeaveTypeChanged(String? value) {
    if (value != null) {
      selectedLeaveType.value = value;
      // Tìm LeaveType tương ứng để lưu thêm thông tin nếu cần
      final leaveType = leaveTypes.firstWhereOrNull(
        (e) => e.jobName == value || e.jobCode == value,
      );
      if (leaveType != null) {
        // Có thể lưu thêm jobCode hoặc jobId nếu cần
      }
    }
  }

  void onStatusChanged(String? value) {
    if (value != null) {
      selectedStatus.value = value;
    }
  }

  Future<void> onSubmit() async {
    // TODO: Implement submit logic
    Get.snackbar('Thành công', 'Đã gửi phê duyệt');
  }

  Future<void> onSaveDraft() async {
    // TODO: Implement save draft logic
    Get.snackbar('Thành công', 'Đã lưu tạm');
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
