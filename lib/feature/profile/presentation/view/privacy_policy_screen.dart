import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'Chính sách bảo mật', isBack: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;
          final isWide = maxContentWidth >= 780;
          final sectionWidth =
              isWide ? (maxContentWidth - 16) / 2 : maxContentWidth;

          final sections = [
            _buildSection(
              title: '1. Thông tin chúng tôi thu thập',
              content: [
                'Thông tin không bắt buộc: Chúng tôi không yêu cầu đăng nhập hay thu thập dữ liệu cá nhân trừ khi bạn gửi email ứng tuyển.',
                'Thông tin khi ứng tuyển: Khi nhấn nút Apply, app sẽ mở ứng dụng email mặc định để gửi email trực tiếp đến VOS. Chúng tôi không lưu hoặc truy cập nội dung email của bạn.',
              ],
            ),
            _buildSection(
              title: '2. Cách chúng tôi sử dụng thông tin',
              content: [
                'Chỉ để gửi tin tuyển dụng đến VOS qua email (bạn gửi trực tiếp).',
                'Không sử dụng thông tin để quảng cáo hoặc chia sẻ với bên thứ ba.',
              ],
            ),
            _buildSection(
              title: '3. Cookies & Analytics',
              content: [
                'App không sử dụng cookie hoặc theo dõi hành vi người dùng.',
              ],
            ),
            _buildSection(
              title: '4. Bảo vệ dữ liệu',
              content: [
                'Chúng tôi cam kết không lưu trữ dữ liệu nhạy cảm từ người dùng.',
                'Mọi dữ liệu gửi qua email được quản lý bởi VOS theo quy định riêng.',
              ],
            ),
            _buildSection(
              title: '5. Liên hệ',
              content: [
                'Nếu có thắc mắc về Privacy Policy, liên hệ:',
                'Email: tuyen.dung@vos.com',
                'Website: www.vos.com',
              ],
            ),
          ];

          return SingleChildScrollView(
            padding: EdgeInsets.all(0.w),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Effective Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24.h),
                      Wrap(
                        spacing: 12.w,
                        runSpacing: 24.h,
                        children: sections
                            .map((section) =>
                                SizedBox(width: sectionWidth, child: section))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        ...content.map(
          (text) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
