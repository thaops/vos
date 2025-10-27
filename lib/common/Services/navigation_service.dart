import 'package:get/get.dart';
// import 'package:vos_flutter/feature/private_app_shell/work_management/controllers/work_management_controller.dart';
// import 'package:vos_flutter/feature/private_app_shell/work_management/models/filter_model.dart';
// import 'package:vos_flutter/feature/private_app_shell/document_management/controllers/document_management_controller.dart';
// import 'package:vos_flutter/feature/private_app_shell/document_management/models/document_filter_model.dart';

/// Service để handle navigation từ home tab đến work management tab với filter
/// DISABLED: Depends on deleted private_app_shell modules
/*
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Callback để switch tab trong MainScreen
  static Function(int)? _onTabChanged;

  /// Set callback để switch tab
  static void setTabChangeCallback(Function(int) callback) {
    _onTabChanged = callback;
  }

  /// Navigate đến work management tab với filter tương ứng
  static void navigateToWorkManagement({
    required int targetTab, // 0: Việc tôi giao, 1: Việc giao đến tôi
    FilterModel? filter,
    bool resetFilter = false,
  }) {
    // Switch to work management tab (index 1)
    _onTabChanged?.call(1);

    // Delay một chút để đảm bảo tab đã switch xong
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final workController = Get.find<WorkManagementController>();
        workController.changeTab(targetTab);

        // Reset filter nếu cần
        if (resetFilter) {
          workController.resetFilter();
        }
        // Apply filter nếu có - sử dụng method mới để đảm bảo áp dụng đúng tab
        else if (filter != null) {
          workController.applyFilterForTab(filter, targetTab);
        }
      } catch (e) {
        // Controller chưa được khởi tạo, thử lại sau
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            final workController = Get.find<WorkManagementController>();
            workController.changeTab(targetTab);

            // Reset filter nếu cần
            if (resetFilter) {
              workController.resetFilter();
            }
            // Apply filter nếu có - sử dụng method mới để đảm bảo áp dụng đúng tab
            else if (filter != null) {
              workController.applyFilterForTab(filter, targetTab);
            }
          } catch (e2) {
            print('Error applying navigation: $e2');
          }
        });
      }
    });
  }

  /// Navigate với filter theo trạng thái cụ thể
  static void navigateWithStatusFilter({
    required int targetTab,
    required int status,
  }) {
    final filter = FilterModel(status: status);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter cho "Công việc trong ngày" (filter theo ngày hôm nay)
  static void navigateWithInDateFilter({required int targetTab}) {
    // Tạo filter với ngày hôm nay - sử dụng timezone hiện tại của device
    final today = DateTime.now();

    // Tạo end of day (23:59:59) với timezone hiện tại
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final dueDate = endOfDay.toIso8601String();

    final filter = FilterModel(dueDate: dueDate);

    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter cho "Công việc đang xử lý" (status = 1)
  static void navigateWithDoingFilter({required int targetTab}) {
    final filter = FilterModel(status: 1);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter theo mức độ ưu tiên
  static void navigateWithPriorityFilter({
    required int targetTab,
    required int priority,
  }) {
    final filter = FilterModel(priority: priority);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate đến Document Management tab với filter tương ứng
  static void navigateToDocumentManagement({
    required int targetTab, // 0: Văn bản đến, 1: Văn bản đi
    DocumentFilterModel? filter,
    bool resetFilter = false,
  }) {
    // Switch to document management tab (index 2)
    _onTabChanged?.call(2);

    // Delay một chút để đảm bảo tab đã switch xong
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final documentController = Get.find<DocumentManagementController>();
        documentController.changeTab(targetTab);

        // Reset filter nếu cần
        if (resetFilter) {
          documentController.resetFilter();
        }
        // Apply filter nếu có
        else if (filter != null) {
          documentController.applyFilter(filter);
        }
      } catch (e) {
        // Controller chưa được khởi tạo, thử lại sau
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            final documentController = Get.find<DocumentManagementController>();
            documentController.changeTab(targetTab);

            // Reset filter nếu cần
            if (resetFilter) {
              documentController.resetFilter();
            }
            // Apply filter nếu có
            else if (filter != null) {
              documentController.applyFilter(filter);
            }
          } catch (e2) {
            print('Error applying document navigation: $e2');
          }
        });
      }
    });
  }

  /// Navigate với filter theo trạng thái văn bản
  static void navigateWithDocumentStatusFilter({
    required int targetTab,
    required String status,
  }) {
    final filter = DocumentFilterModel(status: status);
    navigateToDocumentManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter theo loại văn bản
  static void navigateWithDocumentTypeFilter({
    required int targetTab,
    required String documentType,
  }) {
    final filter = DocumentFilterModel(documentType: documentType);
    navigateToDocumentManagement(targetTab: targetTab, filter: filter);
  }
}
*/
