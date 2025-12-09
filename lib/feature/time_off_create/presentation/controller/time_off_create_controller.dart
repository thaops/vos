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
import 'package:vos_flutter/feature/time_off_create/domain/usecases/upload_files_usecase.dart';

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
    // remainingLeave, remainingOT, pendingLeave - cần API riêng hoặc lấy từ profile nếu có
    // Tạm thời giữ giá trị mặc định
    remainingLeave.value = 0;
    remainingOT.value = 0;
    pendingLeave.value = 0;
  }

  Future<void> loadLeaveTypes() async {
    // Load Vacation Reasons để dùng cho dropdown "Loại phép"
    await handleApiCall<List<VacationReason>>(
      apiCall: () => getAllVacationReasonsUsecase.call(),
      onSuccess: (data) {
        vacationReasons.assignAll(data);
        // Map Vacation Reasons vào leaveTypeOptions để hiển thị trong dropdown "Loại phép"
        leaveTypeOptions.value = data.map((e) => e.nameVn).toList();
        // Gọi các API con độc lập (không phụ thuộc vào status)
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
        // Map WorkCode domain models thành WorkCodeItem cho work code list
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

  /// Load work codes độc lập (không check status)
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

  /// Load leave locations độc lập (không check status)
  Future<void> _loadLeaveLocationsIndependent() async {
    try {
      print('🔄 [LeaveLocation] Loading independently...');
      final result = await getLeaveLocationsUsecase.call();
      if (result.isSuccess && result.data != null) {
        leaveLocations.assignAll(result.data!);
        leaveLocationOptions.value = result.data!.map((e) => e.nameVn).toList();
        print(
          '✅ [LeaveLocation] Loaded ${result.data!.length} locations independently',
        );
      } else {
        print('❌ [LeaveLocation] Error: ${result.error}');
      }
    } catch (e) {
      print('❌ [LeaveLocation] Error loading independently: $e');
    }
  }

  Future<void> loadStatuses() async {
    await handleApiCall<List<Status>>(
      apiCall: () => getStatusesUsecase.call(),
      onSuccess: (data) {
        print('✅ [Status] Loaded ${data.length} statuses');
        statuses.assignAll(data);
        statusOptions.assignAll(data.map((e) => e.nameVn).toList());
        print('✅ [Status] Options: ${statusOptions.length} items');
      },
      onError: (error) {
        print('❌ [Status] Error loading statuses: $error');
      },
    );
  }

  /// Load statuses độc lập (không check status)
  Future<void> _loadStatusesIndependent() async {
    try {
      final result = await getStatusesUsecase.call();
      if (result.isSuccess && result.data != null) {
        statuses.assignAll(result.data!);
        statusOptions.assignAll(result.data!.map((e) => e.nameVn).toList());
        print(
          '✅ [Status] Loaded ${result.data!.length} statuses independently',
        );
      } else {
        print('❌ [Status] Error: ${result.error}');
      }
    } catch (e) {
      print('❌ [Status] Error loading independently: $e');
    }
  }

  double get totalDays {
    return workCodeList.fold(0.0, (sum, item) => sum + item.days);
  }

  void incrementDays(int index) {
    if (index < workCodeList.length) {
      workCodeList[index].days += 0.5; // Tăng 0.5 thay vì 1
      workCodeList.refresh();
    }
  }

  void decrementDays(int index) {
    if (index < workCodeList.length && workCodeList[index].days > 0) {
      workCodeList[index].days -= 0.5; // Giảm 0.5 thay vì 1
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
      // Tìm VacationReason tương ứng (vì giờ "Loại phép" dùng Vacation Reasons)
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
    print('📝 [TimeOffCreate] _buildRequestData() - Bắt đầu build request');

    // Lấy UserID từ ProfileController
    int userId = 0;
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      userId = profileController.userProfile.value?.userId ?? 0;
    }

    // Build ls_Detail từ workCodeList
    final selectedWorkCodes = workCodeList
        .where((item) => item.days > 0)
        .toList();
    final lsDetail = selectedWorkCodes
        .map(
          (item) =>
              WorkCodeDetail(jobCode: item.code, soLuong: item.days.toDouble()),
        )
        .toList();

    // Vacation_Reason: Lấy từ selectedVacationReasonCode hoặc selectedLeaveTypeCode
    String vacationReasonCode = selectedVacationReasonCode.value;
    if (vacationReasonCode.isEmpty) {
      vacationReasonCode = selectedLeaveTypeCode.value;
    }

    print('📎 [TimeOffCreate] Files info:');
    print('   - Attached files (chưa upload): ${attachedFiles.length}');
    print('   - Uploaded files: ${uploadedFiles.length}');

    if (uploadedFiles.isNotEmpty) {
      print('   - Uploaded files details:');
      for (var file in uploadedFiles) {
        print('     • ${file.fileName} - ${file.fileUrl}');
      }
    }

    final request = TimeOffCreateRequest(
      vRegId: 0, // Create mới
      fromDate:
          fromDate.value ??
          DateTime.now().add(const Duration(days: 1)), // Mặc định là ngày mai
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

    print(
      '✅ [TimeOffCreate] Request built với ${uploadedFiles.length} file(s)',
    );
    return request;
  }

  Future<void> onSubmit() async {
    print('🚀 [TimeOffCreate] onSubmit() - Bắt đầu submit');

    // Tự động set ngày mai nếu chưa có
    if (fromDate.value == null) {
      fromDate.value = DateTime.now().add(const Duration(days: 1));
    }

    // Kiểm tra và tự động upload files nếu có files chưa upload
    if (attachedFiles.isNotEmpty) {
      print(
        '⚠️ [TimeOffCreate] Có ${attachedFiles.length} file(s) chưa upload, tự động upload...',
      );
      await uploadFiles();
    }

    final request = _buildRequestData();

    print('📤 [TimeOffCreate] Gửi request create time off...');
    await handleApiCall<int>(
      apiCall: () => createTimeOffUsecase.call(request),
      onSuccess: (id) {
        print('✅ [TimeOffCreate] Create thành công với VReg_ID: $id');
        _sendApproveRequest(id);
      },
    );
  }

  void _sendApproveRequest(int vRegId) async {
    await handleApiCallVoid(
      apiCall: () => sendApproveRequestUsecase.call(vRegId),
      onSuccess: () async {
        // ✅ Gọi API mới sau khi thành công
        await _callCreateAflVos(vRegId);

        // Hiển thị dialog thành công trước khi quay lại
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

  Future<void> _callCreateAflVos(int vRegId) async {
    try {
      // Lấy email từ ProfileController
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

      // Map data
      final request = CreateAflVosRequest.fromTimeOff(
        timeOff: timeOff,
        processes: processes,
      );

      // Call API
      await handleApiCallVoid(
        apiCall: () =>
            createAflVosUsecase.call(request: request, email: emailWithDefault),
        onSuccess: () {
          print('✅ [CreateAflVos] Gửi thành công');
        },
        onError: (error) {
          print('❌ [CreateAflVos] Lỗi: $error');
          // Không hiển thị lỗi cho user, chỉ log
        },
      );
    } catch (e) {
      print('❌ [CreateAflVos] Exception: $e');
    }
  }

  Future<void> onSaveDraft() async {
    print('💾 [TimeOffCreate] onSaveDraft() - Bắt đầu lưu tạm');

    if (fromDate.value == null) {
      fromDate.value = DateTime.now().add(const Duration(days: 1));
    }

    // Kiểm tra và tự động upload files nếu có files chưa upload
    if (attachedFiles.isNotEmpty) {
      print(
        '⚠️ [TimeOffCreate] Có ${attachedFiles.length} file(s) chưa upload, tự động upload...',
      );
      await uploadFiles();
    }

    final request = _buildRequestData();

    print('📤 [TimeOffCreate] Gửi request save draft...');
    await handleApiCallVoid(
      apiCall: () => createTimeOffUsecase.call(request),
      onSuccess: () {
        print('✅ [TimeOffCreate] Save draft thành công');
        // Hiển thị dialog thành công trước khi quay lại
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
      print('ℹ️ [TimeOffCreate] uploadFiles() - Không có file để upload');
      return;
    }

    print(
      '📤 [TimeOffCreate] uploadFiles() - Bắt đầu upload ${attachedFiles.length} file(s)',
    );
    isUploading.value = true;

    await handleApiCall<List<FileAttachment>>(
      apiCall: () => uploadFilesUsecase.call(attachedFiles.toList()),
      onSuccess: (data) {
        print('✅ [TimeOffCreate] Upload thành công ${data.length} file(s)');
        uploadedFiles.addAll(data);
        attachedFiles.clear(); // Clear local files after upload
        print(
          '📊 [TimeOffCreate] Tổng số files đã upload: ${uploadedFiles.length}',
        );
        Get.snackbar(
          'Thành công',
          'Upload ${data.length} file thành công',
          snackPosition: SnackPosition.TOP,
        );
      },
      onError: (error) {
        print('❌ [TimeOffCreate] Upload thất bại: $error');
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
