import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class AppDialog {
  static Future<void> showError({
    required String title,
    required String message,
    String confirmText = 'Đóng',
    bool useBackdrop = true, // Thêm tùy chọn tắt backdrop
  }) async {
    return Get.dialog(
      Stack(
        children: [
          // Backdrop + blur (có thể tắt)
          if (useBackdrop)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {}, // khóa dismiss qua chạm nền
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Đơn giản hóa, giảm độ đen
                    ),
                  ),
                ),
              ),
            ),
          // Dialog card
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x11000000)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Badge icon lấn ra ngoài popup ~ một nửa
                    Positioned(
                      top: -34,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.primary, Color(0xFF04506B)],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 14),
                          // Title
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Message cuộn được nếu dài
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Confirm button
                          SizedBox(
                            height: 46,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Material(
                                color: Colors.transparent,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        const Color(0xFF0A7CA1),
                                      ],
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => Get.back(),
                                    child: Center(
                                      child: Text(
                                        confirmText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button (top-right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {}, // vô hiệu hóa đóng ngoài luồng
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.transparent,
                        ),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
