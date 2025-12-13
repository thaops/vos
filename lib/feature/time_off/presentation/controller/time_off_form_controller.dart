import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/time_off/domain/models/createafl_vos_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off/domain/models/leave_location.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/models/send_approve_result.dart';
import 'package:vos_flutter/feature/time_off/domain/models/status.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off.dart';
import 'package:vos_flutter/feature/time_off/domain/models/time_off_create_request.dart';
import 'package:vos_flutter/feature/time_off/domain/models/vacation_reason.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code.dart';
import 'package:vos_flutter/feature/time_off/domain/models/work_code_detail.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/create_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/createafl_vos_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_all_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_leave_locations_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_leave_types_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_statuses_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_vacation_reasons_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_work_codes_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/send_approve_request_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/update_time_off_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/upload_files_usecase.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/mixins/time_off_form_files_mixin.dart';
import 'package:vos_flutter/feature/time_off/presentation/controller/mixins/time_off_form_work_code_mixin.dart';
import 'package:vos_flutter/feature/time_off/presentation/models/time_off_work_code_item.dart';
import 'package:vos_flutter/feature/time_off_detail/domain/usecases/get_time_off_detail_usecase.dart';

enum TimeOffFormMode { create, update }

enum TimeOffFormFieldError { leaveType, reason }

class TimeOffFormController extends BaseController
    with ApiResultMixin, TimeOffFormFilesMixin, TimeOffFormWorkCodeMixin {
  static const tagCreate = 'time_off_form_create';
  static const tagUpdate = 'time_off_form_update';

  final TimeOffFormMode mode;

  /// Chỉ dùng cho update mode.
  final TimeOff? initialTimeOff;

  final GetLeaveTypesUsecase getLeaveTypesUsecase;
  final GetStatusesUsecase getStatusesUsecase;
  final GetVacationReasonsUsecase getVacationReasonsUsecase;
  final GetAllVacationReasonsUsecase getAllVacationReasonsUsecase;
  final GetWorkCodesUsecase getWorkCodesUsecase;
  final GetLeaveLocationsUsecase getLeaveLocationsUsecase;

  final CreateTimeOffUsecase? createTimeOffUsecase;
  final UpdateTimeOffUsecase? updateTimeOffUsecase;

  final SendApproveRequestUsecase sendApproveRequestUsecase;

  @override
  final UploadFilesUsecase uploadFilesUsecase;

  final CreateAflVosUsecase createAflVosUsecase;
  final GetTimeOffDetailUsecase getTimeOffDetailUsecase;
  final GetPersonalVacationUsecase? getPersonalVacationUsecase;

  // Detail data (update only)
  TimeOff? _detailTimeOff;
  TimeOff get _currentTimeOff => _detailTimeOff ?? (initialTimeOff!);

  int get vRegId {
    if (mode == TimeOffFormMode.update) {
      return initialTimeOff?.vRegId ?? 0;
    }
    return 0;
  }

  // User info
  final Rx<PersonalVacation?> personalVacation = Rx<PersonalVacation?>(null);
  final RxString userName = ''.obs;
  final RxString userPosition = ''.obs;
  final RxString userDepartment = ''.obs;
  final RxInt remainingLeave = 0.obs;
  final RxInt remainingOT = 0.obs;

  /// Create mode dùng field này.
  final RxInt paidLeaveUsedTotal = 0.obs;

  /// Update mode dùng field này.
  final RxInt pendingLeave = 0.obs;

  // Form fields
  final RxString selectedLeaveType = ''.obs;
  final RxString selectedLeaveTypeCode = ''.obs;
  final RxnString leaveTypeError = RxnString();

  @override
  final RxList<TimeOffWorkCodeItem> workCodeList = <TimeOffWorkCodeItem>[].obs;

  final RxString reason = ''.obs;
  final RxnString reasonError = RxnString();
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

  @override
  final RxList<File> attachedFiles = <File>[].obs;

  @override
  final RxList<FileAttachment> uploadedFiles = <FileAttachment>[].obs;

  @override
  final RxBool isUploading = false.obs;

  // TextEditingControllers
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Dropdown options
  final RxList<VacationReason> vacationReasons = <VacationReason>[].obs;
  final RxList<String> leaveTypeOptions = <String>[].obs;
  final RxList<Status> statuses = <Status>[].obs;
  final RxList<String> statusOptions = <String>[].obs;
  final RxList<WorkCode> workCodes = <WorkCode>[].obs;
  final RxList<LeaveLocation> leaveLocations = <LeaveLocation>[].obs;
  final RxList<String> leaveLocationOptions = <String>[].obs;
  final RxList<String> vacationReasonOptions = <String>[].obs;

  TimeOffFormController({
    required this.mode,
    this.initialTimeOff,
    required this.getLeaveTypesUsecase,
    required this.getStatusesUsecase,
    required this.getVacationReasonsUsecase,
    required this.getAllVacationReasonsUsecase,
    required this.getWorkCodesUsecase,
    required this.getLeaveLocationsUsecase,
    this.createTimeOffUsecase,
    this.updateTimeOffUsecase,
    required this.sendApproveRequestUsecase,
    required this.uploadFilesUsecase,
    required this.createAflVosUsecase,
    required this.getTimeOffDetailUsecase,
    this.getPersonalVacationUsecase,
  }) : assert(
         mode == TimeOffFormMode.create || initialTimeOff != null,
         'Update mode requires initialTimeOff',
       );

  String get formattedFromDate {
    final value = fromDate.value;
    if (value == null) return '';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String get formattedFromTime {
    final value = fromDate.value;
    if (value == null) return '';
    return DateFormat('HH:mm').format(value);
  }

  String get formattedToDate {
    final value = toDate.value;
    if (value == null) return '';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String get formattedToTime {
    final value = toDate.value;
    if (value == null) return '';
    return DateFormat('HH:mm').format(value);
  }

  bool get isReasonRequired {
    if (mode == TimeOffFormMode.create) {
      return leaveLocationCode.value.toUpperCase() != 'NO';
    }
    return leaveLocationCode.value == 'NO' && selectedStatusCode.value == 'YES';
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    _setupTextControllers();
    _initializeData();
    _loadUserInfoFromProfile();
    _setupProfileListener();

    if (mode == TimeOffFormMode.create) {
      _setDefaultDates();
    }

    await loadPersonalVacation();

    if (mode == TimeOffFormMode.update) {
      await _loadTimeOffDetail();
    }

    await loadLeaveTypes();
  }

  void _setupProfileListener() {
    if (!Get.isRegistered<ProfileController>()) return;
    final profileController = Get.find<ProfileController>();
    ever(profileController.userProfile, (profile) {
      loadPersonalVacation();
    });
  }

  void _setDefaultDates() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    fromDate.value = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      8,
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

  void _initializeData() {
    personalVacation.value = null;
    remainingLeave.value = 0;
    remainingOT.value = 0;
    paidLeaveUsedTotal.value = 0;
    pendingLeave.value = 0;
  }

  void _loadUserInfoFromProfile() {
    if (mode == TimeOffFormMode.create) {
      final vacation = personalVacation.value;
      userName.value = vacation?.fullName ?? '';
      userPosition.value = vacation?.jobTitleNameVN ?? '';
      userDepartment.value = vacation?.departmentName ?? '';
      remainingLeave.value = vacation?.paidLeaveRemain ?? 0;
      remainingOT.value = vacation?.overTimeRemain ?? 0;
      paidLeaveUsedTotal.value = vacation?.paidLeaveUsedTotal ?? 0;
      return;
    }

    if (!Get.isRegistered<ProfileController>()) return;
    final profile = Get.find<ProfileController>().userProfile.value;
    if (profile == null) return;

    userName.value = profile.userName;
    userPosition.value = profile.description.isNotEmpty
        ? profile.description
        : '';
    userDepartment.value = profile.branchNameVN.isNotEmpty
        ? profile.branchNameVN
        : (profile.companyNameVN.isNotEmpty ? profile.companyNameVN : '');
  }

  Future<void> loadPersonalVacation() async {
    if (getPersonalVacationUsecase == null) {
      return;
    }

    int hrId = 0;
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>().userProfile.value;
        hrId = (profile != null && profile.hrId > 0) ? profile.hrId : 2215;
      } else {
        hrId = 2215;
      }
    } catch (_) {
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
        if (mode == TimeOffFormMode.create) {
          paidLeaveUsedTotal.value = data.paidLeaveUsedTotal;
        } else {
          pendingLeave.value = data.paidLeaveUsedTotal;
        }
      },
      onError: (error) {
        _loadUserInfoFromProfile();
      },
    );
  }

  void _setupTextControllers() {
    reasonController.addListener(() {
      reason.value = reasonController.text;
      if (reasonError.value != null &&
          reasonController.text.trim().isNotEmpty) {
        reasonError.value = null;
      }
    });
    contactInfoController.addListener(
      () => contactInfo.value = contactInfoController.text,
    );
    addressController.addListener(() => address.value = addressController.text);
  }

  @override
  void onClose() {
    reasonController.dispose();
    contactInfoController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> _loadTimeOffDetail() async {
    if (mode != TimeOffFormMode.update) return;
    try {
      final result = await getTimeOffDetailUsecase.call(vRegId: vRegId);
      if (result.isSuccess && result.data != null) {
        _detailTimeOff = result.data;
      }
    } catch (_) {
      // Fallback: dùng initialTimeOff.
    }
  }

  Future<void> loadLeaveTypes() async {
    await handleApiCall<List<VacationReason>>(
      apiCall: () => getAllVacationReasonsUsecase.call(),
      onSuccess: (data) async {
        vacationReasons.assignAll(data);
        leaveTypeOptions.value = data.map((e) => e.nameVn).toList();

        if (mode == TimeOffFormMode.update) {
          await Future.wait([
            _loadWorkCodesIndependent(),
            _loadStatusesIndependent(),
            _loadLeaveLocationsIndependent(),
          ]);
          _prefillFormData();
          _prefillWorkCodes();
          return;
        }

        await Future.wait([
          _loadWorkCodesIndependent(),
          _loadStatusesIndependent(),
          _loadLeaveLocationsIndependent(),
        ]);
      },
    );
  }

  Future<void> _loadWorkCodesIndependent() async {
    try {
      final result = await getWorkCodesUsecase.call();
      if (result.isSuccess && result.data != null) {
        workCodes.assignAll(result.data!);
        workCodeList.value = result.data!
            .map(
              (workCode) => TimeOffWorkCodeItem(
                code: workCode.jobCode,
                name: workCode.jobName,
                days: 0,
              ),
            )
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _loadLeaveLocationsIndependent() async {
    try {
      final result = await getLeaveLocationsUsecase.call();
      if (result.isSuccess && result.data != null) {
        leaveLocations.assignAll(result.data!);
        leaveLocationOptions.value = result.data!.map((e) => e.nameVn).toList();
        if (mode == TimeOffFormMode.create) {
          _setDefaultLeaveLocation();
        }
      }
    } catch (_) {}
  }

  Future<void> _loadStatusesIndependent() async {
    try {
      final result = await getStatusesUsecase.call();
      if (result.isSuccess && result.data != null) {
        statuses.assignAll(result.data!);
        statusOptions.assignAll(result.data!.map((e) => e.nameVn).toList());
        if (mode == TimeOffFormMode.create) {
          _setDefaultStatus();
        }
      }
    } catch (_) {}
  }

  void _setDefaultStatus() {
    if (selectedStatus.value.isNotEmpty || statuses.isEmpty) return;

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
    if (leaveLocation.value.isNotEmpty || leaveLocations.isEmpty) return;

    final defaultLocation = leaveLocations.firstWhereOrNull(
      (location) =>
          location.code.toUpperCase() == 'NO' ||
          location.nameVn.toLowerCase().contains('trong nước'),
    );
    final locationToUse = defaultLocation ?? leaveLocations.first;
    leaveLocation.value = locationToUse.nameVn;
    leaveLocationCode.value = locationToUse.code;
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
    if (value == null) return;
    selectedVacationReason.value = value;
    final vacationReason = vacationReasons.firstWhereOrNull(
      (e) => e.nameVn == value,
    );
    if (vacationReason != null) {
      selectedVacationReasonCode.value = vacationReason.code;
    }
  }

  void onLeaveTypeChanged(String? value) {
    if (value == null) return;
    selectedLeaveType.value = value;
    if (leaveTypeError.value != null) {
      leaveTypeError.value = null;
    }
    final vacationReason = vacationReasons.firstWhereOrNull(
      (e) => e.nameVn == value,
    );
    if (vacationReason != null) {
      selectedLeaveTypeCode.value = vacationReason.code;
      selectedVacationReasonCode.value = vacationReason.code;
    }
  }

  void _clearValidationErrors() {
    leaveTypeError.value = null;
    reasonError.value = null;
  }

  TimeOffFormFieldError? validateForSubmit() {
    _clearValidationErrors();

    if (mode == TimeOffFormMode.create && selectedLeaveType.value.isEmpty) {
      leaveTypeError.value = 'Vui lòng chọn loại phép';
      return TimeOffFormFieldError.leaveType;
    }

    if (isReasonRequired && reasonController.text.trim().isEmpty) {
      reasonError.value = 'Vui lòng nhập mô tả nghỉ phép';
      return TimeOffFormFieldError.reason;
    }

    return null;
  }

  TimeOffFormFieldError? validateForDraft() {
    _clearValidationErrors();

    if (mode == TimeOffFormMode.create && selectedLeaveType.value.isEmpty) {
      leaveTypeError.value = 'Vui lòng chọn loại phép';
      return TimeOffFormFieldError.leaveType;
    }

    if (mode == TimeOffFormMode.create &&
        isReasonRequired &&
        reasonController.text.trim().isEmpty) {
      reasonError.value = 'Vui lòng nhập lý do nghỉ phép';
      return TimeOffFormFieldError.reason;
    }

    return null;
  }

  void onStatusChanged(String? value) {
    if (value == null) return;
    selectedStatus.value = value;
    final status = statuses.firstWhereOrNull((e) => e.nameVn == value);
    if (status != null) {
      selectedStatusCode.value = status.code;
    }
  }

  void onLeaveLocationChanged(String? value) {
    if (value == null) return;
    leaveLocation.value = value;
    final location = leaveLocations.firstWhereOrNull((e) => e.nameVn == value);
    if (location != null) {
      leaveLocationCode.value = location.code;
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final currentDate =
        fromDate.value ??
        (mode == TimeOffFormMode.update
            ? (_currentTimeOff.fromDate ?? DateTime.now())
            : DateTime.now().add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
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

  Future<void> selectFromTime(BuildContext context) async {
    final current =
        fromDate.value ??
        (mode == TimeOffFormMode.update
            ? (_currentTimeOff.fromDate ?? DateTime.now())
            : DateTime.now().add(const Duration(days: 1)));
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    fromDate.value = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
  }

  Future<void> selectToDate(BuildContext context) async {
    final base =
        fromDate.value ??
        (mode == TimeOffFormMode.update
            ? (_currentTimeOff.fromDate ?? DateTime.now())
            : DateTime.now().add(const Duration(days: 1)));
    final current = toDate.value ?? base;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    toDate.value = DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
  }

  Future<void> selectToTime(BuildContext context) async {
    final base =
        fromDate.value ??
        (mode == TimeOffFormMode.update
            ? (_currentTimeOff.fromDate ?? DateTime.now())
            : DateTime.now().add(const Duration(days: 1)));
    final current = toDate.value ?? base;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    toDate.value = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
  }

  void _prefillFormData() {
    if (mode != TimeOffFormMode.update) return;
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
        selectedStatus.value = current.statusName!;
      }
    }

    if (current.attachFiles != null && current.attachFiles!.isNotEmpty) {
      uploadedFiles.assignAll(current.attachFiles!);
    }
  }

  void _prefillWorkCodes() {
    if (mode != TimeOffFormMode.update) return;
    final current = _currentTimeOff;
    if (current.details == null || current.details!.isEmpty) return;
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

  TimeOffCreateRequest _buildRequestData() {
    int userId = 0;
    if (Get.isRegistered<ProfileController>()) {
      userId = Get.find<ProfileController>().userProfile.value?.userId ?? 0;
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

    if (mode == TimeOffFormMode.create) {
      final baseFromDate =
          fromDate.value ?? DateTime.now().add(const Duration(days: 1));
      final finalFromDate = DateTime(
        baseFromDate.year,
        baseFromDate.month,
        baseFromDate.day,
        baseFromDate.hour,
        baseFromDate.minute,
      );
      final normalizedFromDate =
          (baseFromDate.hour == 0 && baseFromDate.minute == 0)
          ? DateTime(
              baseFromDate.year,
              baseFromDate.month,
              baseFromDate.day,
              8,
              0,
            )
          : finalFromDate;

      final leaveTimes = totalDays;
      final baseToDate = toDate.value ?? normalizedFromDate;
      final daysToAdd = leaveTimes.ceil().clamp(0, 365);
      final computedToDate = leaveTimes <= 1
          ? baseToDate
          : DateTime(
              normalizedFromDate.year,
              normalizedFromDate.month,
              normalizedFromDate.day,
              baseToDate.hour,
              baseToDate.minute,
            ).add(Duration(days: daysToAdd - 1));

      return TimeOffCreateRequest(
        vRegId: 0,
        fromDate: normalizedFromDate,
        toDate: computedToDate,
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
    }

    return TimeOffCreateRequest(
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
  }

  Future<void> onSubmit() async {
    final firstError = validateForSubmit();
    if (firstError != null) return;
    await submit();
  }

  Future<void> submit() async {
    if (fromDate.value == null) {
      fromDate.value = mode == TimeOffFormMode.update
          ? (_currentTimeOff.fromDate ?? DateTime.now())
          : DateTime.now().add(const Duration(days: 1));
    }

    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    if (mode == TimeOffFormMode.create) {
      await handleApiCall<int>(
        apiCall: () => createTimeOffUsecase!.call(request),
        onSuccess: (id) => _sendApproveRequest(id),
      );
      return;
    }

    await handleApiCall<int>(
      apiCall: () => updateTimeOffUsecase!.call(request),
      onSuccess: (id) => _sendApproveRequest(id),
    );
  }

  Future<void> onSaveDraft() async {
    final firstError = validateForDraft();
    if (firstError != null) return;
    await saveDraft();
  }

  Future<void> saveDraft() async {
    if (fromDate.value == null) {
      fromDate.value = mode == TimeOffFormMode.update
          ? (_currentTimeOff.fromDate ?? DateTime.now())
          : DateTime.now().add(const Duration(days: 1));
    }

    if (attachedFiles.isNotEmpty) {
      await uploadFiles();
    }

    final request = _buildRequestData();

    if (mode == TimeOffFormMode.create) {
      await handleApiCallVoid(
        apiCall: () => createTimeOffUsecase!.call(request),
        onSuccess: () {
          SuccessDialog.show(
            context: Get.context!,
            title: 'Thành công',
            message: 'Lưu tạm thành công',
            buttonText: 'Đóng',
            onClose: () => Get.back(result: true),
          );
        },
      );
      return;
    }

    await handleApiCallVoid(
      apiCall: () => updateTimeOffUsecase!.call(request),
      onSuccess: () {
        SuccessDialog.show(
          context: Get.context!,
          title: 'Thành công',
          message: 'Cập nhật thành công',
          buttonText: 'Đóng',
          onClose: () => Get.back(result: true),
        );
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
          onClose: () => Get.back(result: true),
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
      int? hrId;
      if (Get.isRegistered<ProfileController>()) {
        final profile = Get.find<ProfileController>().userProfile.value;
        email = profile?.email;
        hrId = profile?.hrId;
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

      CreateAflVosRequest request;

      request = CreateAflVosRequest.fromTimeOff(
        timeOff: timeOff,
        processes: processes,
        approvalsOverride: approvalsFromApi,
        hrId: hrId,
      );

      await handleApiCallVoid(
        apiCall: () =>
            createAflVosUsecase.call(request: request, email: emailWithDefault),
        showErrorSnackbar: false,
      );
    } catch (_) {}
  }
}
