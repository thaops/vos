import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(
        title: 'Điều khoản sử dụng',
        isBack: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth =
              constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;
          final isWide = maxContentWidth >= 780;
          final sectionWidth =
              isWide ? (maxContentWidth - 16) / 2 : maxContentWidth;

          final sections = [
            _buildSection(
              title: '1. Sử dụng app',
              content: [
                'App chỉ dành để xem tin tuyển dụng công khai và văn hóa công ty.',
                'Không được sử dụng app cho mục đích trái pháp luật hoặc gây hại cho VOS.',
              ],
            ),
            _buildSection(
              title: '2. Ứng tuyển',
              content: [
                'Mọi ứng tuyển được thực hiện qua email của VOS.',
                'VOS chịu trách nhiệm xử lý thông tin ứng viên. App không lưu trữ thông tin ứng viên.',
              ],
            ),
            _buildSection(
              title: '3. Nội dung',
              content: [
                'Nội dung trong app thuộc sở hữu của VOS.',
                'Không sao chép, chia sẻ nội dung mà không được phép.',
              ],
            ),
            _buildSection(
              title: '4. Thay đổi',
              content: [
                'VOS có thể cập nhật app, Privacy Policy, và Terms of Service.',
                'Người dùng nên kiểm tra định kỳ.',
              ],
            ),
            _buildSection(
              title: '5. Giới hạn trách nhiệm',
              content: [
                'App được cung cấp "as-is".',
                'VOS không chịu trách nhiệm về việc thất bại trong ứng tuyển hoặc vấn đề phát sinh ngoài app.',
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
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Effective Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Bằng việc sử dụng VOS Mobile App, bạn đồng ý với các điều khoản sau:',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
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
        ...content.map((text) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            )),
      ],
    );
  }
}

