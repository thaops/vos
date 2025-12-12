import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';
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
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off_create/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/models/time_off_update_args.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off_update/domain/usecases/upload_files_usecase.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/personal_vacation.dart';

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
  final GetPersonalVacationUsecase getPersonalVacationUsecase;
  final UpdateTimeOffUsecase updateTimeOffUsecase;
  final SendApproveRequestUsecase sendApproveRequestUsecase;
  final UploadFilesUsecase uploadFilesUsecase;
  final CreateAflVosUsecase createAflVosUsecase;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;

  late final TimeOff timeOff = args.timeOff;
  TimeOff? _detailTimeOff;
  late final int vRegId = timeOff.vRegId;
  TimeOff get _currentTimeOff => _detailTimeOff ?? timeOff;

  // User Info
  final RxString userName = ''.obs;
  final RxString userPosition = ''.obs;
  final RxString userDepartment = ''.obs;
  final Rx<PersonalVacation?> personalVacation = Rx<PersonalVacation?>(null);
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

  TimeOffUpdateController({
    required this.args,
    required this.getLeaveTypesUsecase,
    required this.getStatusesUsecase,
    required this.getVacationReasonsUsecase,
    required this.getAllVacationReasonsUsecase,
    required this.getWorkCodesUsecase,
    required this.getLeaveLocationsUsecase,
    required this.getPersonalVacationUsecase,
    required this.updateTimeOffUsecase,
    required this.sendApproveRequestUsecase,
    required this.uploadFilesUsecase,
    required this.createAflVosUsecase,
    required this.getTimeOffDetailUsecase,
  });

  String get formattedFromDate {
    if (fromDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(fromDate.value!);
  }

  String get formattedFromTime {
    if (fromDate.value == null) return '';
    return DateFormat('HH:mm').format(fromDate.value!);
  }

  String get formattedToTime {
    if (toDate.value == null) return '';
    return DateFormat('HH:mm').format(toDate.value!);
  }

  bool get isReasonRequired {
    return leaveLocationCode.value == 'NO' && selectedStatusCode.value == 'YES';
  }

  String get formattedToDate {
    if (toDate.value == null) return '';
    return DateFormat('dd/MM/yyyy').format(toDate.value!);
  }

  @override
  void onInit() {
    super.onInit();
    _setupTextControllers();
    _initializeData();
    _loadUserInfoFromProfile();
    _setupProfileListener();
    loadPersonalVacation();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadTimeOffDetail();
    await loadLeaveTypes();
  }

  Future<void> _loadTimeOffDetail() async {
    try {
      final result = await getTimeOffDetailUsecase.call(vRegId: vRegId);
      if (result.isSuccess && result.data != null) {
        _detailTimeOff = result.data;
      }
    } catch (e) {
      print('❌ [TimeOffUpdate] Không thể load detail, dùng dữ liệu sẵn có: $e');
    }
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
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      final profile = profileController.userProfile.value;

      if (profile != null) {
        userName.value = profile.userName;
        // Chức danh: Lấy từ description (job title/position)
        userPosition.value = profile.description.isNotEmpty
            ? profile.description
            : '';
        // Đơn vị: Ưu tiên branchNameVN, sau đó companyNameVN
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
    personalVacation.value = null;
    remainingLeave.value = 0;
    remainingOT.value = 0;
    pendingLeave.value = 0;
  }

  Future<void> loadPersonalVacation() async {
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
      apiCall: () => getPersonalVacationUsecase.call(hrId: hrId),
      showErrorSnackbar: false,
      onSuccess: (data) {
        personalVacation.value = data;
        userName.value = data.fullName;
        userPosition.value = data.jobTitleNameVN;
        userDepartment.value = data.departmentName;
        remainingLeave.value = data.paidLeaveRemain;
        remainingOT.value = data.overTimeRemain;
        pendingLeave.value = data.paidLeaveUsedTotal;
      },
      onError: (error) {
        _loadUserInfoFromProfile();
      },
    );
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

  void _prefillFormData() {
    final current = _currentTimeOff;

    if (current.fromDate != null) {
      fromDate.value = current.fromDate;
    }
    if (current.toDate != null) {
      toDate.value = current.toDate;
    }

    if (current.vacationReason != null && current.vacationReason!.isNotEmpty) {
      selectedLeaveTypeCode.value = current.vacationReason!;
      selectedVacationReasonCode.value = current.vacationReason!;

      final vacationReason = vacationReasons.firstWhereOrNull(
        (vr) => vr.code == current.vacationReason,
      );
      if (vacationReason != null) {
        selectedLeaveType.value = vacationReason.nameVn;
        selectedVacationReason.value = vacationReason.nameVn;
      } else if (current.vacationReasonName != null &&
          current.vacationReasonName!.isNotEmpty) {
        // Fallback: dùng name nếu không tìm thấy
        selectedLeaveType.value = current.vacationReasonName!;
        selectedVacationReason.value = current.vacationReasonName!;
      }
    }

    if (current.domInt != null && current.domInt!.isNotEmpty) {
      leaveLocationCode.value = current.domInt!;
      final location = leaveLocations.firstWhereOrNull(
        (loc) => loc.code == current.domInt,
      );
      if (location != null) {
        leaveLocation.value = location.nameVn;
      } else if (current.domIntName != null && current.domIntName!.isNotEmpty) {
        leaveLocation.value = current.domIntName!;
      }
    }

    if (current.description != null && current.description!.isNotEmpty) {
      reasonController.text = current.description!;
    }

    if (current.contactPerson != null && current.contactPerson!.isNotEmpty) {
      contactInfoController.text = current.contactPerson!;
    }

    if (current.contactInfor != null && current.contactInfor!.isNotEmpty) {
      addressController.text = current.contactInfor!;
    }

    if (current.status != null && current.status!.isNotEmpty) {
      selectedStatusCode.value = current.status!;
      final status = statuses.firstWhereOrNull((s) => s.code == current.status);
      if (status != null) {
        selectedStatus.value = status.nameVn;
      } else if (current.statusName != null && current.statusName!.isNotEmpty) {
        // Fallback: dùng name nếu không tìm thấy
        selectedStatus.value = current.statusName!;
      }
    }

    // Load file attachments từ timeOff vào uploadedFiles
    if (current.attachFiles != null && current.attachFiles!.isNotEmpty) {
      uploadedFiles.assignAll(current.attachFiles!);
      print(
        '✅ [TimeOffUpdate] Đã load ${uploadedFiles.length} file(s) từ timeOff.attachFiles',
      );
    }
  }

  void _prefillWorkCodes() {
    final current = _currentTimeOff;
    if (current.details != null && current.details!.isNotEmpty) {
      for (final detail in current.details!) {
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
    final currentDate = fromDate.value ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      // Giữ nguyên giờ, chỉ cập nhật ngày
      fromDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      // Nếu toDate nhỏ hơn fromDate, cập nhật toDate
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
    final currentDate = fromDate.value ?? DateTime.now();
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
    final currentDate = toDate.value ?? fromDate.value ?? DateTime.now();
    final minDate = fromDate.value ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      // Giữ nguyên giờ, chỉ cập nhật ngày
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
    final currentDate = toDate.value ?? fromDate.value ?? DateTime.now();
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
    print('📝 [TimeOffUpdate] _buildRequestData() - Bắt đầu build request');

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

    final request = TimeOffCreateRequest(
      vRegId: vRegId,
      fromDate: fromDate.value ?? _currentTimeOff.fromDate ?? DateTime.now(),
      toDate: toDate.value ?? _currentTimeOff.toDate,
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
    if (isReasonRequired && reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập mô tả nghỉ phép',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    if (fromDate.value == null) {
      fromDate.value = _currentTimeOff.fromDate ?? DateTime.now();
    }

    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    await handleApiCall<int>(
      apiCall: () => updateTimeOffUsecase.call(request),
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

      final emailWithDefault = email ?? 'phongdh@viags.vn';

      final detailResult = await getTimeOffDetailUsecase.call(vRegId: vRegId);
      if (!detailResult.isSuccess || detailResult.data == null) {
        return;
      }

      final timeOff = detailResult.data!;
      final processes = timeOff.processes ?? [];
      if (processes.isEmpty) {
        return;
      }

      final request = CreateAflVosRequest.fromTimeOff(
        timeOff: timeOff,
        processes: processes,
        approvalsOverride: approvalsFromApi,
      );

      await handleApiCallVoid(
        apiCall: () =>
            createAflVosUsecase.call(request: request, email: emailWithDefault),
        onSuccess: () {
          print('[CreateAflVos] Gửi thành công');
        },
        onError: (error) {
          print(' [CreateAflVos] Lỗi: $error');
        },
      );
    } catch (e) {
      print('[CreateAflVos] Exception: $e');
    }
  }

  Future<void> onSaveDraft() async {
    if (fromDate.value == null) {
      fromDate.value = _currentTimeOff.fromDate ?? DateTime.now();
    }

    // Kiểm tra và tự động upload files nếu có files chưa upload
    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    await handleApiCallVoid(
      apiCall: () => updateTimeOffUsecase.call(request),
      onSuccess: () {
        SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Cập nhật thành công',
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
      print('ℹ️ [TimeOffUpdate] uploadFiles() - Không có file để upload');
      return;
    }

    isUploading.value = true;

    await handleApiCall<List<FileAttachment>>(
      apiCall: () => uploadFilesUsecase.call(attachedFiles.toList()),
      onSuccess: (data) {
        uploadedFiles.addAll(data);
        attachedFiles.clear();
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
