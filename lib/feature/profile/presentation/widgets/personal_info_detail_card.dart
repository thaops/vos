import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';

class PersonalInfoDetailCard extends StatelessWidget {
  final UserProfile user;

  const PersonalInfoDetailCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin cá nhân'),
          SizedBox(height: 16.h),
          _buildInfoRow('Mã nhân viên', user.userCode),
          _buildInfoRow('Họ và tên', user.userName),
          _buildInfoRow('Email', user.email.isNotEmpty ? user.email : 'N/A'),
          _buildInfoRow(
            'Số điện thoại',
            user.phone.isNotEmpty ? user.phone : 'N/A',
          ),
          _buildInfoRow('Trạng thái', user.status),
          _buildInfoRow('Loại người dùng', user.userType),
          if (user.brieftName.isNotEmpty)
            _buildInfoRow('Tên viết tắt', user.brieftName),
          _buildInfoRow('Thuộc tính', user.attribute),
          _buildInfoRow('Mức độ mật khẩu', user.pwdLevel),
          _buildInfoRow('Ngôn ngữ', user.language),
          _buildInfoRow('Loại đăng nhập', user.loginType),
          if (user.devices.isNotEmpty) _buildInfoRow('Thiết bị', user.devices),
          if (user.description.isNotEmpty)
            _buildInfoRow('Mô tả', user.description),
          SizedBox(height: 24.h),
          _buildSectionTitle('Thông tin công ty'),
          SizedBox(height: 16.h),
          if (user.companyCode.isNotEmpty)
            _buildInfoRow('Mã công ty', user.companyCode),
          if (user.companyNameVN.isNotEmpty)
            _buildInfoRow('Tên công ty (VN)', user.companyNameVN),
          if (user.companyNameEN.isNotEmpty)
            _buildInfoRow('Tên công ty (EN)', user.companyNameEN),
          SizedBox(height: 24.h),
          _buildSectionTitle('Thông tin công ty mẹ'),
          SizedBox(height: 16.h),
          if (user.masterCompanyCode.isNotEmpty)
            _buildInfoRow('Mã công ty mẹ', user.masterCompanyCode),
          if (user.masterCompanyNameVN.isNotEmpty)
            _buildInfoRow('Tên công ty mẹ (VN)', user.masterCompanyNameVN),
          if (user.masterCompanyNameEN.isNotEmpty)
            _buildInfoRow('Tên công ty mẹ (EN)', user.masterCompanyNameEN),
          SizedBox(height: 24.h),
          _buildSectionTitle('Thông tin chi nhánh'),
          SizedBox(height: 16.h),
          if (user.branchCode.isNotEmpty)
            _buildInfoRow('Mã chi nhánh', user.branchCode),
          if (user.branchNameVN.isNotEmpty)
            _buildInfoRow('Tên chi nhánh (VN)', user.branchNameVN),
          if (user.branchNameEN.isNotEmpty)
            _buildInfoRow('Tên chi nhánh (EN)', user.branchNameEN),
          SizedBox(height: 24.h),
          _buildSectionTitle('Thông tin HR'),
          SizedBox(height: 16.h),
          if (user.hrId > 0) _buildInfoRow('HR ID', user.hrId.toString()),
          if (user.hrNo.isNotEmpty) _buildInfoRow('HR No', user.hrNo),
          SizedBox(height: 24.h),
          _buildSectionTitle('Thông tin hệ thống'),
          SizedBox(height: 16.h),
          _buildInfoRow('User ID', user.userId.toString()),
          _buildInfoRow('Company ID', user.companyId.toString()),
          _buildInfoRow('Master Company ID', user.masterCompanyId.toString()),
          _buildInfoRow('Branch ID', user.branchId.toString()),
          if (user.recUserID > 0)
            _buildInfoRow('Rec User ID', user.recUserID.toString()),
          _buildInfoRow('Token hết hạn', _formatDateTime(user.tokenExpired)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[900]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
