import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/authorize/presentation/controller/authorize_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/common/utils/auth_utils.dart';
import 'package:intl/intl.dart';

class AuthorizeScreen extends StatefulWidget {
  const AuthorizeScreen({super.key});

  @override
  State<AuthorizeScreen> createState() => _AuthorizeScreenState();
}

class _AuthorizeScreenState extends State<AuthorizeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    try {
      print('🔄 AuthorizeScreen _loadData called');
      if (!Get.isRegistered<ProfileController>()) {
        print('⚠️ ProfileController not registered');
        return;
      }

      final profileController = Get.find<ProfileController>();
      final token = profileController.userProfile.value?.token ?? '';
      final hrId = profileController.userProfile.value?.hrId ?? 0;
      final userId = profileController.userProfile.value?.userId ?? 0;
      final hrNo = profileController.userProfile.value?.hrNo ?? '';

      print('📊 Profile data:');
      print('   - token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "empty"}');
      print('   - hrId: $hrId');
      print('   - userId: $userId');
      print('   - hrNo: "$hrNo"');
      print('   - userCode: ${profileController.userProfile.value?.userCode ?? ""}');

      if (token.isEmpty) {
        print('⚠️ Token is empty, cannot load authorizes');
        return;
      }

      // Thử lấy HR_ID từ nhiều nguồn
      int finalHrId = 0;
      
      // 1. Ưu tiên HR_ID từ profile
      if (hrId > 0) {
        finalHrId = hrId;
        print('✅ Using HR_ID from profile: $finalHrId');
      } else {
        // 2. Thử decode JWT token để lấy HR_ID
        final hrIdFromToken = AuthUtils.getHrIdFromToken(token);
        if (hrIdFromToken != null && hrIdFromToken > 0) {
          finalHrId = hrIdFromToken;
          print('✅ Using HR_ID from JWT token: $finalHrId');
        } else {
          // 3. Fallback: thử dùng userId (nhưng có thể không đúng)
          if (userId > 0) {
            finalHrId = userId;
            print('⚠️ HR_ID not found, trying with userId: $finalHrId');
            print('⚠️ NOTE: This may not work if user is a company account');
          }
        }
      }
      
      if (finalHrId == 0) {
        print('⚠️ HR_ID is 0, cannot load authorizes');
        Get.snackbar(
          'Lỗi',
          'Không tìm thấy mã nhân viên (HR_ID). Vui lòng liên kết lại tài khoản VIAGS hoặc liên hệ quản trị viên.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('🚀 Calling loadAuthorizes with hrId: $finalHrId');
      print('💡 If API returns no data, HR_ID may be incorrect. Check API response for correct HR_ID.');

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
        appBar: AppBar(
          title: const Text('Danh sách ủy quyền'),
        ),
        body: const Center(child: Text('Controller not found')),
      );
    }

    final controller = Get.find<AuthorizeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006884),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Danh sách ủy quyền',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        print('🔄 AuthorizeScreen Obx rebuild - isLoading: ${controller.isLoading.value}, error: ${controller.error.value}, count: ${controller.authorizes.length}');
        
        // Loading state
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
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
                Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'Chưa có ủy quyền nào',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                  ),
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
        print('✅ Displaying ${controller.authorizes.length} authorizes');
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.authorizes.length,
          itemBuilder: (context, index) {
            final authorize = controller.authorizes[index];
            return _buildAuthorizeCard(authorize);
          },
        );
      }),
    );
  }

  Widget _buildAuthorizeCard(authorize) {
    // Debug: Log data của authorize
    print('🎨 Building card for authorize: FullName=${authorize.fullName}, forFullName=${authorize.forFullName}, Status=${authorize.status}');
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            // Header: Người ủy quyền
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Người ủy quyền',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: authorize.status == 'OK'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    authorize.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: authorize.status == 'OK' ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Thông tin người ủy quyền
            _buildInfoRow('Họ tên', authorize.fullName),
            _buildInfoRow('Mã NV', authorize.hrNo),
            _buildInfoRow('Chức vụ', authorize.nameJobTitle),
            _buildInfoRow('Cấp bậc', authorize.nameLevelTitle),
            _buildInfoRow('Mã phòng ban', authorize.depCode),
            _buildInfoRow('Phòng ban', authorize.depName),
            if (authorize.depLevel2Code.isNotEmpty)
              _buildInfoRow('Phòng ban cấp 2', authorize.depLevel2Code),
            if (authorize.depLevel3Code.isNotEmpty)
              _buildInfoRow('Phòng ban cấp 3', authorize.depLevel3Code),
            SizedBox(height: 12.h),
            Divider(),
            SizedBox(height: 12.h),
            // Header: Người được ủy quyền
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Người được ủy quyền',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Thông tin người được ủy quyền
            _buildInfoRow('Họ tên', authorize.forFullName),
            _buildInfoRow('Mã NV', authorize.forHrNo),
            _buildInfoRow('Chức vụ', authorize.forNameJobTitle),
            _buildInfoRow('Cấp bậc', authorize.forNameLevelTitle),
            _buildInfoRow('Mã phòng ban', authorize.forDepCode),
            _buildInfoRow('Phòng ban', authorize.forDepName),
            if (authorize.forDepLevel2Code.isNotEmpty)
              _buildInfoRow('Phòng ban cấp 2', authorize.forDepLevel2Code),
            if (authorize.forDepLevel3Code.isNotEmpty)
              _buildInfoRow('Phòng ban cấp 3', authorize.forDepLevel3Code),
            SizedBox(height: 12.h),
            Divider(),
            SizedBox(height: 12.h),
            // Thông tin ủy quyền
            _buildInfoRow('Mã ủy quyền', authorize.authorizeId.toString()),
            _buildInfoRow('Từ ngày', _formatDate(authorize.fromDate)),
            _buildInfoRow('Đến ngày', _formatDate(authorize.toDate)),
            _buildInfoRow('Loại ủy quyền', authorize.lsAuthorize),
            _buildInfoRow('Ngày tạo', _formatDate(authorize.recdate)),
            if (authorize.description.isNotEmpty)
              _buildInfoRow('Mô tả', authorize.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Chưa cập nhật',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
}

