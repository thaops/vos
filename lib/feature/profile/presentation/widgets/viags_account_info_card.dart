import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/img/img.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';

class ViagsAccountInfoCard extends StatelessWidget {
  final UserProfile user;
  final ProfileController controller;

  const ViagsAccountInfoCard({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20.h),
          Obx(() => _buildViagsInfoItem(
            'Email',
            controller.isViagsLinked.value &&
                    controller.viagsEmail.value.isNotEmpty
                ? controller.viagsEmail.value
                : user.email,
          )),
          _buildViagsInfoItem(
            'Chức vụ',
            user.description.isNotEmpty ? user.description : 'Trưởng phòng',
          ),
          _buildViagsInfoItem('Tổ đội', 'Đội hệ thống'),
          _buildViagsInfoItem('Mã nhân viên', user.userCode),
          _buildViagsInfoItem('Ngày vào làm', '01/01/2024'),
        ],
      ),
    );
  }

  Widget _buildViagsInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Image.asset(Img.copy, width: 8.w, height: 8.w, fit: BoxFit.contain),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
