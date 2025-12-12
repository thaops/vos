import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/leave_type.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/create_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/upload_files_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/personal_vacation.dart';

class WorkCodeItem {
  final String code;
  final String name;
  double days;

  WorkCodeItem({required this.code, required this.name, this.days = 0.0});
}

class TimeOffCreateController extends BaseController with ApiResultMixin {
  final GetLeaveTypesUsecase getLeaveTypesUsecase;
  final GetStatusesUsecase getStatusesUsecase;
  final GetVacationReasonsUsecase getVacationReasonsUsecase;
  final GetAllVacationReasonsUsecase getAllVacationReasonsUsecase;
  final GetWorkCodesUsecase getWorkCodesUsecase;
  final GetLeaveLocationsUsecase getLeaveLocationsUsecase;
  final CreateTimeOffUsecase createTimeOffUsecase;
  final SendApproveRequestUsecase sendApproveRequestUsecase;
  final UploadFilesUsecase uploadFilesUsecase;
  final CreateAflVosUsecase createAflVosUsecase;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;
  final GetPersonalVacationUsecase? getPersonalVacationUsecase;

  // User Info - Sử dụng PersonalVacation model
  final Rx<PersonalVacation?> personalVacation = Rx<PersonalVacation?>(null);

  // Giữ lại các field cũ để backward compatibility (nếu có nơi khác dùng)
  final RxString userName = ''.obs;
  final RxString userPosition = ''.obs;
  final RxString userDepartment = ''.obs;
  final RxInt remainingLeave = 0.obs;
  final RxInt remainingOT = 0.obs;
  final RxInt paidLeaveUsedTotal = 0.obs;

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
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxList<File> attachedFiles = <File>[].obs;
  final RxList<FileAttachment> uploadedFiles = <FileAttachment>[].obs;
  final RxBool isUploading = false.obs;

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

  TimeOffCreateController({
    required this.getLeaveTypesUsecase,
    required this.getStatusesUsecase,
    required this.getVacationReasonsUsecase,
    required this.getAllVacationReasonsUsecase,
    required this.getWorkCodesUsecase,
    required this.getLeaveLocationsUsecase,
    required this.createTimeOffUsecase,
    required this.sendApproveRequestUsecase,
    required this.uploadFilesUsecase,
    required this.createAflVosUsecase,
    required this.getTimeOffDetailUsecase,
    this.getPersonalVacationUsecase,
  });

  String get formattedFromDate {
    if (fromDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(fromDate.value!);
  }

  String get formattedFromTime {
    if (fromDate.value == null) return '';
    return DateFormat('HH:mm').format(fromDate.value!);
  }

  String get formattedToDate {
    if (toDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(toDate.value!);
  }

  String get formattedToTime {
    if (toDate.value == null) return '';
    return DateFormat('HH:mm').format(toDate.value!);
  }

  bool get isReasonRequired => leaveLocationCode.value.toUpperCase() != 'NO';

  @override
  Future<void> onInit() async {
    super.onInit();

    _setupTextControllers();
    _initializeData();
    _loadUserInfoFromProfile();
    _setupProfileListener();
    _setDefaultDates();

    // Chạy tuần tự để tránh ControllerStatus.loading chặn call sau
    await loadPersonalVacation();
    await loadLeaveTypes();
  }

  void _setDefaultDates() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
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

  void _setupProfileListener() {
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      ever(profileController.userProfile, (profile) {
        loadPersonalVacation();
      });
    }
  }

  void _loadUserInfoFromProfile() {
    userName.value = personalVacation.value?.fullName ?? '';
    userPosition.value = personalVacation.value?.jobTitleNameVN ?? '';
    userDepartment.value = personalVacation.value?.departmentName ?? '';
    remainingLeave.value = personalVacation.value?.paidLeaveRemain ?? 0;
    remainingOT.value = personalVacation.value?.overTimeRemain ?? 0;
    paidLeaveUsedTotal.value = personalVacation.value?.paidLeaveUsedTotal ?? 0;
  }

  Future<void> loadPersonalVacation() async {
    if (getPersonalVacationUsecase == null) {
      return;
    }

    int hrId = 0;
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        final profile = profileController.userProfile.value;
        if (profile != null && profile.hrId > 0) {
          hrId = profile.hrId;
        } else {
          hrId = 2215;
        }
      } else {
        hrId = 2215;
      }
    } catch (e) {
      hrId = 2215;
    }

    await handleApiCall<PersonalVacation>(
      apiCall: () => getPersonalVacationUsecase!.call(hrId: hrId),
      showErrorSnackbar: false,
      onSuccess: (data) {
        personalVacation.value = data;
        userName.value = data.fullName;
        userPosition.value = data.jobTitleNameVN;
        userDepartment.value = data.departmentName;
        remainingLeave.value = data.paidLeaveRemain;
        remainingOT.value = data.overTimeRemain;
        paidLeaveUsedTotal.value = data.paidLeaveUsedTotal;
      },
      onError: (error) {
        _loadUserInfoFromProfile();
      },
    );
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
    paidLeaveUsedTotal.value = 0;
  }

  Future<void> loadLeaveTypes() async {
    await handleApiCall<List<VacationReason>>(
      apiCall: () => getAllVacationReasonsUsecase.call(),
      onSuccess: (data) {
        vacationReasons.assignAll(data);
        leaveTypeOptions.value = data.map((e) => e.nameVn).toList();
        _loadWorkCodesIndependent();
        _loadStatusesIndependent();
        _loadLeaveLocationsIndependent();
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
    } catch (e) {}
  }

  Future<void> loadLeaveLocations() async {
    await handleApiCall<List<LeaveLocation>>(
      apiCall: () => getLeaveLocationsUsecase.call(),
      onSuccess: (data) {
        leaveLocations.assignAll(data);
        leaveLocationOptions.value = data.map((e) => e.nameVn).toList();
        _setDefaultLeaveLocation();
      },
    );
  }

  Future<void> _loadLeaveLocationsIndependent() async {
    try {
      final result = await getLeaveLocationsUsecase.call();
      if (result.isSuccess && result.data != null) {
        leaveLocations.assignAll(result.data!);
        leaveLocationOptions.value = result.data!.map((e) => e.nameVn).toList();
        _setDefaultLeaveLocation();
      }
    } catch (e) {}
  }

  Future<void> loadStatuses() async {
    await handleApiCall<List<Status>>(
      apiCall: () => getStatusesUsecase.call(),
      onSuccess: (data) {
        statuses.assignAll(data);
        statusOptions.assignAll(data.map((e) => e.nameVn).toList());
        _setDefaultStatus();
      },
    );
  }

  Future<void> _loadStatusesIndependent() async {
    try {
      final result = await getStatusesUsecase.call();
      if (result.isSuccess && result.data != null) {
        statuses.assignAll(result.data!);
        statusOptions.assignAll(result.data!.map((e) => e.nameVn).toList());
        _setDefaultStatus();
      }
    } catch (e) {}
  }

  void _setDefaultStatus() {
    if (selectedStatus.value.isNotEmpty || statuses.isEmpty) {
      return;
    }

    final defaultStatus = statuses.firstWhereOrNull(
      (status) =>
          status.code.toUpperCase() == 'YES' ||
          status.nameVn.toLowerCase().contains('sử dụng'),
    );

    final statusToUse = defaultStatus ?? statuses.first;
    selectedStatus.value = statusToUse.nameVn;
    selectedStatusCode.value = statusToUse.code;
  }

  void _setDefaultLeaveLocation() {
    if (leaveLocation.value.isNotEmpty || leaveLocations.isEmpty) {
      return;
    }

    final defaultLocation = leaveLocations.firstWhereOrNull(
      (location) =>
          location.code.toUpperCase() == 'NO' ||
          location.nameVn.toLowerCase().contains('trong nước'),
    );

    final locationToUse = defaultLocation ?? leaveLocations.first;
    leaveLocation.value = locationToUse.nameVn;
    leaveLocationCode.value = locationToUse.code;
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

  void updateDays(int index, String value) {
    if (index < workCodeList.length) {
      final parsedValue = double.tryParse(value);
      if (parsedValue != null && parsedValue >= 0) {
        workCodeList[index].days = parsedValue;
        workCodeList.refresh();
      } else if (value.isEmpty) {
        workCodeList[index].days = 0.0;
        workCodeList.refresh();
      }
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
    final currentDate =
        fromDate.value ?? DateTime.now().add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      fromDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      if (toDate.value != null && toDate.value!.isBefore(fromDate.value!)) {
        toDate.value = DateTime(
          picked.year,
          picked.month,
          picked.day,
          toDate.value!.hour,
          toDate.value!.minute,
        );
      }
    }
  }

  Future<void> selectFromTime(BuildContext context) async {
    final currentDate =
        fromDate.value ?? DateTime.now().add(const Duration(days: 1));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (picked != null) {
      fromDate.value = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final currentDate =
        toDate.value ??
        fromDate.value ??
        DateTime.now().add(const Duration(days: 1));
    final minDate = fromDate.value ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      toDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
    }
  }

  Future<void> selectToTime(BuildContext context) async {
    final currentDate =
        toDate.value ??
        fromDate.value ??
        DateTime.now().add(const Duration(days: 1));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (picked != null) {
      toDate.value = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
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

    final finalFromDate =
        fromDate.value ?? DateTime.now().add(const Duration(days: 1));
    final finalToDate = toDate.value ?? finalFromDate;

    final request = TimeOffCreateRequest(
      vRegId: 0, // Create mới
      fromDate: finalFromDate,
      toDate: finalToDate,
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
      jsonAttachFiles: uploadedFiles.toList(),
    );

    return request;
  }

  Future<void> onSubmit() async {
    if (selectedLeaveType.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn loại phép',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (isReasonRequired && reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập lý do nghỉ phép',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (fromDate.value == null) {
      fromDate.value = DateTime.now().add(const Duration(days: 1));
    }

    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    await handleApiCall<int>(
      apiCall: () => createTimeOffUsecase.call(request),
      onSuccess: (id) {
        _sendApproveRequest(id);
      },
    );
  }

  void _sendApproveRequest(int vRegId) async {
    await handleApiCall<SendApproveResult>(
      apiCall: () => sendApproveRequestUsecase.call(vRegId),
      onSuccess: (result) async {
        await _callCreateAflVos(vRegId, result.approvals);

        SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Gửi phê duyệt thành công',
          buttonText: 'Đóng',
          onClose: () {
            Get.back(result: true);
          },
        );
      },
    );
  }

  Future<void> _callCreateAflVos(
    int vRegId,
    List<ApprovalItem> approvalsFromApi,
  ) async {
    try {
      String? email;
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        email = profileController.userProfile.value?.email;
      }

      // Dùng email mặc định nếu null
      final emailWithDefault = email ?? 'phongdh@viags.vn';

      // Load TimeOff detail để lấy đầy đủ thông tin (processes, attachFiles)
      final detailResult = await getTimeOffDetailUsecase.call(vRegId: vRegId);
      if (!detailResult.isSuccess || detailResult.data == null) {
        print('⚠️ [CreateAflVos] Không load được detail, bỏ qua');
        return;
      }

      final TimeOff timeOff = detailResult.data!;
      final processes = timeOff.processes ?? [];
      if (processes.isEmpty) {
        print('⚠️ [CreateAflVos] Không có processes, bỏ qua');
        return;
      }

      // Map data (ưu tiên approvals từ API sendApprove)
      final request = CreateAflVosRequest.fromTimeOff(
        timeOff: timeOff,
        processes: processes,
        approvalsOverride: approvalsFromApi,
      );

      // Call API
      await handleApiCallVoid(
        apiCall: () =>
            createAflVosUsecase.call(request: request, email: emailWithDefault),
        showErrorSnackbar: false,
      );
    } catch (e) {
      print('❌ [CreateAflVos] Exception: $e');
    }
  }

  Future<void> onSaveDraft() async {
    // Validation: Loại phép là bắt buộc
    if (selectedLeaveType.value.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn loại phép',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    // Validation: Lý do là bắt buộc
    if (isReasonRequired && reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập lý do nghỉ phép',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (fromDate.value == null) {
      fromDate.value = DateTime.now().add(const Duration(days: 1));
    }

    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    await handleApiCallVoid(
      apiCall: () => createTimeOffUsecase.call(request),
      onSuccess: () {
        SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Lưu tạm thành công',
          buttonText: 'Đóng',
          onClose: () {
            Get.back(result: true);
          },
        );
      },
    );
  }

  // Add files to list (chưa upload)
  void onFilesSelected(List<File> files) {
    attachedFiles.addAll(files);
  }

  // Remove file from list
  void removeFile(int index) {
    if (index < attachedFiles.length) {
      attachedFiles.removeAt(index);
    }
  }

  // Remove uploaded file
  void removeUploadedFile(int index) {
    if (index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
    }
  }

  // Upload files to server
  Future<void> uploadFiles() async {
    if (attachedFiles.isEmpty) {
      return;
    }

    isUploading.value = true;

    await handleApiCall<List<FileAttachment>>(
      apiCall: () => uploadFilesUsecase.call(attachedFiles.toList()),
      onSuccess: (data) {
        uploadedFiles.addAll(data);
        attachedFiles.clear();
        Get.snackbar(
          'Thành công',
          'Upload ${data.length} file thành công',
          snackPosition: SnackPosition.TOP,
        );
      },
      onError: (error) {
        Get.snackbar(
          'Lỗi',
          'Upload file thất bại: $error',
          snackPosition: SnackPosition.TOP,
        );
      },
    );

    isUploading.value = false;
  }
}
