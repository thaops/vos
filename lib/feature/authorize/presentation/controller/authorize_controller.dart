import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/cancel_authorize_usecase.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorize_statuses_usecase.dart';
import 'package:vos_flutter/feature/authorize/domain/usecases/get_authorizes_usecase.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class AuthorizeController extends GetxController {
  final GetAuthorizesUsecase getAuthorizesUsecase;
  final GetAuthorizeStatusesUsecase getAuthorizeStatusesUsecase;
  final CancelAuthorizeUsecase cancelAuthorizeUsecase;
  final ProfileController profileController;

  AuthorizeController({
    required this.getAuthorizesUsecase,
    required this.getAuthorizeStatusesUsecase,
    required this.cancelAuthorizeUsecase,
    required this.profileController,
  });

  final RxList<Authorize> authorizes = <Authorize>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isStatusLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, String>> statuses = <Map<String, String>>[].obs;
  final RxString statusFilter = 'all'.obs;
  final RxString searchText = ''.obs;
  final RxSet<int> cancelingIds = <int>{}.obs;
  final TextEditingController searchController = TextEditingController();

  String? _token;
  int? _hrId;
  bool _initializing = false;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onReady() {
    super.onReady();
    initialize();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> initialize() async {
    if (_initializing) return;
    _initializing = true;

    final hasProfile = await _ensureProfile();
    if (!hasProfile) {
      _initializing = false;
      return;
    }

    await Future.wait([
      loadStatuses(),
      loadAuthorizes(),
    ]);

    _initializing = false;
  }

  Future<bool> _ensureProfile() async {
    if (_setProfile(profileController.userProfile.value)) {
      return true;
    }

    try {
      await profileController.loadUserProfile();
    } catch (_) {
      // ignore, will handle below
    }

    return _setProfile(profileController.userProfile.value);
  }

  bool _setProfile(dynamic profile) {
    if (profile == null) {
      error.value = 'Không tìm thấy thông tin người dùng';
      return false;
    }

    final token = profile.token as String? ?? '';
    final hrId = profile.hrId as int? ?? 0;

    if (token.isEmpty) {
      error.value = 'Thiếu token đăng nhập';
      return false;
    }

    _token = token;
    _hrId = hrId;
    return true;
  }

  Future<void> loadAuthorizes({int authorizeId = 0, int year = 0}) async {
    if (!await _ensureProfile()) return;

    try {
      isLoading.value = true;
      error.value = '';

      final result =
          await getAuthorizesUsecase.call(_token!, authorizeId, _hrId ?? 0, year);
      if (result.isSuccess && result.data != null) {
        authorizes.value = result.data!;
      } else {
        error.value = result.error ?? 'Không thể tải danh sách ủy quyền';
        authorizes.clear();
      }
    } catch (e) {
      error.value = 'Lỗi: $e';
      authorizes.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStatuses() async {
    if (!await _ensureProfile()) return;

    try {
      isStatusLoading.value = true;
      final ApiResult<List<Map<String, String>>> result =
          await getAuthorizeStatusesUsecase.call(_token!);

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        statuses.value = result.data!;
      } else {
        statuses.value = _defaultStatuses();
      }
    } catch (_) {
      statuses.value = _defaultStatuses();
    } finally {
      isStatusLoading.value = false;
    }
  }

  List<Map<String, String>> _defaultStatuses() {
    return const [
      {'code': 'OK', 'name': 'Đang sử dụng'},
      {'code': 'XX', 'name': 'Đánh dấu xóa'},
    ];
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
  }

  void _onSearchChanged() {
    searchText.value = searchController.text;
  }

  List<Authorize> get filteredAuthorizes {
    var filtered = authorizes.toList();

    if (statusFilter.value != 'all') {
      filtered = filtered
          .where((item) => item.status.toUpperCase() == statusFilter.value)
          .toList();
    }

    final query = searchText.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.fullName.toLowerCase().contains(query) ||
            item.forFullName.toLowerCase().contains(query) ||
            item.lsAuthorize.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.hrNo.toLowerCase().contains(query) ||
            item.forHrNo.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<bool> cancelAuthorize(Authorize authorize) async {
    if (!await _ensureProfile()) return false;

    final authorizeId = authorize.authorizeId;
    if (cancelingIds.contains(authorizeId)) return false;

    cancelingIds.add(authorizeId);
    try {
      final result = await cancelAuthorizeUsecase.call(
        token: _token!,
        authorizeId: authorizeId,
        fromDate: authorize.fromDate,
        lsAuthorize: authorize.lsAuthorize.isNotEmpty
            ? authorize.lsAuthorize
            : 'ALL',
      );

      if (result.isSuccess) {
        await loadAuthorizes();
        return true;
      }

      error.value = result.error ?? 'Không thể hủy ủy quyền';
      return false;
    } catch (e) {
      error.value = 'Lỗi: $e';
      return false;
    } finally {
      cancelingIds.remove(authorizeId);
    }
  }
}