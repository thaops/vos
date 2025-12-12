// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:vos_flutter/core/configs/theme/app_colors.dart';
// import 'package:vos_flutter/router/app_router.dart';

// class NotLoggedInState extends StatelessWidget {
//   const NotLoggedInState({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.person_outline, size: 80.sp, color: Colors.grey[400]),
//             SizedBox(height: 24.h),
//             Text(
//               'Chưa đăng nhập',
//               style: TextStyle(
//                 fontSize: 24.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'Vui lòng đăng nhập để xem thông tin cá nhân',
//               style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 32.h),
//             _buildLoginButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     return Container(
//       width: double.infinity,
//       height: 50.h,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary,
//             AppColors.primary.withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: () => Get.toNamed(AppRouter.login),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 24.w,
//               height: 24.w,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//               child: Center(
//                 child: Text(
//                   'G',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue[600],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Text(
//               'Đăng nhập bằng Google',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

