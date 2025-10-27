import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controller/webview_controller.dart';

class WebViewTab extends StatelessWidget {
  const WebViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebViewTabController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WebView',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF006884),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.reload,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return WebViewWidget(controller: controller.webViewController);
      }),
    );
  }
}
