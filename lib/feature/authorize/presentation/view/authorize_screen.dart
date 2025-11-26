// import 'dart:convert'; // Commented for test mode
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:dio/dio.dart' as dioLib; // Commented for test mode
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/feature/authorize/presentation/controller/authorize_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/router/app_router.dart';
// import 'package:vos_flutter/common/utils/auth_utils.dart'; // Commented for test mode
import 'package:intl/intl.dart';

class AuthorizeScreen extends StatefulWidget {
  const AuthorizeScreen({super.key});

  @override
  State<AuthorizeScreen> createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends State<AuthorizeScreen> {
  // Search và filter state
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all'; // 'all' hoặc status code từ API
  List<Map<String, String>> _statuses = []; // Danh sách status từ API

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadStatuses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStatuses() async {
    // TEST MODE: Set cứng data để test
    setState(() {
      _statuses = [
        {'code': 'OK', 'name': 'Đang sử dụng'},
        {'code': 'XX', 'name': 'Đánh dấu xóa'},
      ];
      print('✅ [TEST MODE] Set hardcoded statuses: ${_statuses.length} items');
      print('   - ${_statuses[0]["name"]} (${_statuses[0]["code"]})');
      print('   - ${_statuses[1]["name"]} (${_statuses[1]["code"]})');
    });

    // Code gốc (đã comment để test):
    // try {
    //   if (!Get.isRegistered<ProfileController>()) {
    //     return;
    //   }
    //
    //   final profileController = Get.find<ProfileController>();
    //   final token = profileController.userProfile.value?.token ?? '';
    //
    //   if (token.isEmpty) {
    //     return;
    //   }
    //
    //   // Gọi API trực tiếp từ datasource (tạm thời)
    //   // TODO: Thêm vào controller/repository/usecase sau
    //   final dio = Get.find<dioLib.Dio>();
    //   final headers = {
    //     'Authorization': token,
    //     'Content-Type': 'application/x-www-form-urlencoded',
    //   };
    //   final data = {
    //     'FunctionCode': 'EAF_HR.dbo.HR_Authorize.Status',
    //     'ls_Data': '{}',
    //   };
    //
    //   final response = await dio.request(
    //     'https://share-api.viags.vn/Share/Share_Get',
    //     options: dioLib.Options(
    //       method: 'POST',
    //       headers: headers,
    //       responseType: dioLib.ResponseType.plain,
    //     ),
    //     data: data,
    //   );
    //
    //   if (response.statusCode == 200 && response.data != null) {
    //     final responseData =
    //         json.decode(response.data as String) as Map<String, dynamic>;
    //     if (responseData['ResultCode'] == 0) {
    //       final dataString = responseData['Data'] as String?;
    //       if (dataString != null && dataString.isNotEmpty) {
    //         final cleanedString = dataString
    //             .replaceAll('\r\n', '')
    //             .replaceAll('\r', '')
    //             .replaceAll('\n', '')
    //             .trim();
    //         final List<dynamic> dataList = jsonDecode(cleanedString);
    //         final statuses = <Map<String, String>>[];
    //         for (final item in dataList) {
    //           if (item is Map<String, dynamic>) {
    //             statuses.add({
    //               'code': (item['Code'] as String? ?? '').toString(),
    //               'name': (item['Name_VN'] as String? ?? '').toString(),
    //             });
    //           }
    //         }
    //         setState(() {
    //           _statuses = statuses;
    //           print(
    //             '✅ Loaded ${statuses.length} statuses: ${statuses.map((s) => '${s["name"]} (${s["code"]})').join(", ")}',
    //           );
    //         });
    //       }
    //     }
    //   }
    // } catch (e) {
    //   print('❌ Error loading statuses: $e');
    // }
  }

  void _loadData() {
    try {
      print('🔄 AuthorizeScreen _loadData called');

      // Đảm bảo ProfileController được register
      if (!Get.isRegistered<ProfileController>()) {
        print('⚠️ ProfileController not registered, registering now...');
        ProfileBinding().dependencies();

        // Đợi một chút để ProfileController được khởi tạo và load data
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && Get.isRegistered<ProfileController>()) {
            // Load user profile trước khi load authorizes
            final profileController = Get.find<ProfileController>();
            profileController.loadUserProfile().then((_) {
              if (mounted) {
                _loadData();
              }
            });
          }
        });
        return;
      }

      final profileController = Get.find<ProfileController>();

      // Đảm bảo userProfile đã được load
      if (profileController.userProfile.value == null) {
        print('⚠️ UserProfile is null, loading profile first...');
        profileController.loadUserProfile().then((_) {
          if (mounted) {
            _loadData();
          }
        });
        return;
      }

      final token = profileController.userProfile.value?.token ?? '';
      final hrId = profileController.userProfile.value?.hrId ?? 0;
      final userId = profileController.userProfile.value?.userId ?? 0;
      final hrNo = profileController.userProfile.value?.hrNo ?? '';
      final userType = profileController.userProfile.value?.userType ?? '';
      final userCode = profileController.userProfile.value?.userCode ?? '';

      print('📊 Profile data:');
      print(
        '   - token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "empty"}',
      );
      print('   - hrId: $hrId');
      print('   - userId: $userId');
      print('   - hrNo: "$hrNo"');
      print('   - userCode: "$userCode"');
      print('   - userType: "$userType"');

      if (token.isEmpty) {
        print('⚠️ Token is empty, cannot load authorizes');
        return;
      }

      // TEST MODE: Bỏ qua check company account để test với HR_ID cứng
      // Code gốc (đã comment để test):
      // // Kiểm tra nếu là company account (UserType = "U")
      // // Nếu profile không có userType, thử decode từ token
      // String finalUserType = userType;
      // if (finalUserType.isEmpty) {
      //   final tokenPayload = AuthUtils.decodeJwtToken(token);
      //   if (tokenPayload != null) {
      //     finalUserType =
      //         tokenPayload['UserType'] as String? ??
      //         tokenPayload['userType'] as String? ??
      //         '';
      //     print('📊 UserType from token: "$finalUserType"');
      //   }
      // }
      // final isCompanyAccount = finalUserType == 'U' || finalUserType == 'u';
      // if (isCompanyAccount) {
      //   print('⚠️ User is a company account (UserType: $finalUserType)');
      //   print(
      //     '⚠️ Company accounts do not have HR_ID. Cannot load authorizes without valid HR_ID.',
      //   );
      //   print(
      //     '💡 Company accounts need to specify HR_ID of employee to view authorizations.',
      //   );
      //   Get.snackbar(
      //     'Thông báo',
      //     'Tài khoản công ty không có mã nhân viên (HR_ID). Vui lòng sử dụng tài khoản nhân viên để xem danh sách ủy quyền.',
      //     snackPosition: SnackPosition.BOTTOM,
      //     duration: const Duration(seconds: 4),
      //   );
      //   return;
      // }

      // TEST MODE: Set cứng HR_ID = 1750 để test API
      const int testHrId = 1750;
      int finalHrId = testHrId;
      print('🧪 [TEST MODE] Using hardcoded HR_ID: $finalHrId');

      // Code gốc (đã comment để test):
      // // Thử lấy HR_ID từ nhiều nguồn
      // int finalHrId = 0;
      // // 1. Ưu tiên HR_ID từ profile
      // if (hrId > 0) {
      //   finalHrId = hrId;
      //   print('✅ Using HR_ID from profile: $finalHrId');
      // } else {
      //   // 2. Thử decode JWT token để lấy HR_ID
      //   final hrIdFromToken = AuthUtils.getHrIdFromToken(token);
      //   if (hrIdFromToken != null && hrIdFromToken > 0) {
      //     finalHrId = hrIdFromToken;
      //     print('✅ Using HR_ID from JWT token: $finalHrId');
      //   } else {
      //     // 3. KHÔNG dùng userId làm HR_ID vì chúng khác nhau
      //     // userId là ID của user account, HR_ID là ID của nhân viên
      //     print('❌ HR_ID not found in profile or token');
      //     print(
      //       '❌ Cannot use userId ($userId) as HR_ID - they are different values',
      //     );
      //   }
      // }
      // if (finalHrId == 0) {
      //   print('⚠️ HR_ID is 0, cannot load authorizes');
      //   Get.snackbar(
      //     'Lỗi',
      //     'Không tìm thấy mã nhân viên (HR_ID). Vui lòng liên kết lại tài khoản VIAGS hoặc liên hệ quản trị viên.',
      //     snackPosition: SnackPosition.BOTTOM,
      //   );
      //   return;
      // }

      print('🚀 Calling loadAuthorizes with hrId: $finalHrId');
      print(
        '💡 If API returns no data, HR_ID may be incorrect. Check API response for correct HR_ID.',
      );

      if (Get.isRegistered<AuthorizeController>()) {
        final authorizeController = Get.find<AuthorizeController>();
        // authorizeId: 0 (lấy tất cả), year: 0 (năm hiện tại)
        authorizeController.loadAuthorizes(token, 0, finalHrId, 0);
      } else {
        print('⚠️ AuthorizeController not registered');
      }
    } catch (e) {
      print('❌ Error loading authorize data: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách ủy quyền: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthorizeController>()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Danh sách ủy quyền')),
        body: const Center(child: Text('Controller not found')),
      );
    }

    final controller = Get.find<AuthorizeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(
        title: 'Danh sách ủy quyền',
        iconRightfirst: Icons.add,
        colorfirst: Colors.white,
        functionfirst: () async {
          final result = await Get.toNamed(AppRouter.authorizeCreate);
          if (result == true) {
            _loadData();
          }
        },
      ),
      body: Obx(() {
        print(
          '🔄 AuthorizeScreen Obx rebuild - isLoading: ${controller.isLoading.value}, error: ${controller.error.value}, count: ${controller.authorizes.length}',
        );

        // Loading state
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // Error state
        if (controller.error.value.isNotEmpty) {
          print('❌ Showing error: ${controller.error.value}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    controller.error.value,
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => _loadData(),
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (controller.authorizes.isEmpty) {
          print('⚠️ Authorize list is empty');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Chưa có ủy quyền nào',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _loadData(),
                  child: Text('Tải lại'),
                ),
              ],
            ),
          );
        }

        // List state
        final filteredList = _getFilteredList(controller.authorizes);
        print(
          '✅ Displaying ${filteredList.length}/${controller.authorizes.length} authorizes (filtered)',
        );

        return Column(
          children: [
            // Search bar và filter
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.white,
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF006884),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Filter button - dùng PopupMenuButton để tránh lỗi layout
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _statusFilter = value;
                        });
                      },
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.grey[700],
                        size: 24.sp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'all',
                          child: Container(
                            width: 140.w,
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Text(
                              'Tất cả',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                        ..._statuses.map((status) {
                          final code = status['code'] ?? '';
                          // Chỉ hiển thị "Đang sử dụng" nếu code là "OK"
                          final name = code == 'OK'
                              ? 'Đang sử dụng'
                              : status['name'] ?? '';

                          return PopupMenuItem(
                            value: code,
                            child: Container(
                              width: 140.w,
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Text(
                                '$name',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // List
            if (filteredList.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'Không tìm thấy kết quả'
                            : _statusFilter != 'all'
                            ? 'Không có ủy quyền với trạng thái này'
                            : 'Không có dữ liệu',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final authorize = filteredList[index];
                    return _buildAuthorizeCard(authorize);
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildAuthorizeCard(authorize) {
    // Debug: Log data của authorize
    print(
      '🎨 Building card for authorize: FullName=${authorize.fullName}, forFullName=${authorize.forFullName}, Status=${authorize.status}',
    );

    // Xác định trạng thái và text hiển thị
    final statusText = _getStatusText(authorize.status);
    final isActive = authorize.status == 'OK';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tên người được ủy quyền + Badge trạng thái
            Row(
              children: [
                Expanded(
                  child: Text(
                    authorize.forFullName.isNotEmpty
                        ? authorize.forFullName
                        : 'Chưa có tên',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0A0A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                // Badge trạng thái
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFE0FFF3)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF00B894)
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Từ ngày đến ngày
            _buildInfoItemWithIcon(
              icon: Icons.calendar_today,
              label: 'Từ ngày đến ngày',
              value: _formatDateRange(authorize.fromDate, authorize.toDate),
            ),
            SizedBox(height: 16.h),

            // Loại ủy quyền
            _buildInfoItemWithIcon(
              icon: Icons.label_outline,
              label: 'Loại ủy quyền',
              value: authorize.lsAuthorize.isNotEmpty
                  ? authorize.lsAuthorize
                  : 'Chưa cập nhật',
            ),
            SizedBox(height: 16.h),

            // Mô tả quyền
            if (authorize.description.isNotEmpty)
              _buildInfoItemWithIcon(
                icon: Icons.description_outlined,
                label: 'Mô tả quyền',
                value: authorize.description,
              ),
            if (authorize.description.isNotEmpty) SizedBox(height: 16.h),

            // Cập nhật cuối
            _buildInfoItemWithIcon(
              icon: Icons.access_time,
              label: 'Cập nhật cuối',
              value: _formatDateTime(authorize.recdate),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OK':
        return 'Hoạt động';
      case 'XX':
        return 'Hết hiệu lực';
      default:
        return status;
    }
  }

  String _formatDateRange(String fromDate, String toDate) {
    final from = _formatDate(fromDate);
    final isToDateNull = toDate.isEmpty || toDate == '1900-01-01T00:00:00';

    if (isToDateNull) {
      return from;
    }

    final to = _formatDate(toDate);
    return '$from - $to';
  }

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty || dateString == '1900-01-01T00:00:00') {
      return 'Chưa cập nhật';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoItemWithIcon({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty || dateString == '1900-01-01T00:00:00') {
      return 'Không giới hạn';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Filter và search list
  List<Authorize> _getFilteredList(List<Authorize> authorizes) {
    var filtered = authorizes;

    // Filter theo trạng thái
    if (_statusFilter != 'all') {
      filtered = filtered
          .where((item) => item.status == _statusFilter)
          .toList();
    }

    // Search theo text
    final searchText = _searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((item) {
        // Search trong: fullName, forFullName, lsAuthorize, description
        final fullName = item.fullName.toLowerCase();
        final forFullName = item.forFullName.toLowerCase();
        final lsAuthorize = item.lsAuthorize.toLowerCase();
        final description = item.description.toLowerCase();
        final hrNo = item.hrNo.toLowerCase();
        final forHrNo = item.forHrNo.toLowerCase();

        return fullName.contains(searchText) ||
            forFullName.contains(searchText) ||
            lsAuthorize.contains(searchText) ||
            description.contains(searchText) ||
            hrNo.contains(searchText) ||
            forHrNo.contains(searchText);
      }).toList();
    }

    return filtered;
  }
}
