import 'package:flutter/material.dart';
import 'package:vos_flutter/common/widgets/error_404_widget.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

/// Demo widget để test các loại Error404Widget
class Error404Demo extends StatelessWidget {
  const Error404Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error 404 Widget Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic Error404Widget
            const Text(
              '1. Basic Error404Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Error404Widget(
                title: 'Không tìm thấy dữ liệu',
                message:
                    'Dữ liệu bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.',
                buttonText: 'Thử lại',
              ),
            ),

            const SizedBox(height: 24),

            // Error404WidgetWithLottie
            const Text(
              '2. Error404WidgetWithLottie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Error404WidgetWithLottie(
                title: 'Lỗi kết nối',
                message:
                    'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.',
                buttonText: 'Kết nối lại',
              ),
            ),

            const SizedBox(height: 24),

            // Error404Card
            const Text(
              '3. Error404Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Error404Card(
              title: 'Không có quyền truy cập',
              message: 'Bạn không có quyền xem nội dung này.',
              buttonText: 'Quay lại',
            ),

            const SizedBox(height: 24),

            // Custom Error404Widget
            const Text(
              '4. Custom Error404Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Error404Widget(
                title: 'API Error',
                message: 'Lỗi từ server: 500 Internal Server Error',
                buttonText: 'Refresh',
                onRetry: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang thử lại...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Error404Widget without retry button
            const Text(
              '5. Error404Widget (No Retry)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Error404Widget(
                title: 'Không tìm thấy công việc',
                message: 'Công việc này không tồn tại hoặc đã bị xóa.',
                showRetryButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
