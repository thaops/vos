import 'package:flutter/material.dart';

/// Success Dialog với thiết kế đẹp mắt
class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onClose;
  final bool autoClose;
  final Duration autoCloseDelay;

  const SuccessDialog({
    super.key,
    this.title = 'Thành công',
    this.message = 'Tạo công việc thành công',
    this.buttonText = 'Đóng',
    this.onClose,
    this.autoClose = true,
    this.autoCloseDelay = const Duration(seconds: 2),
  });

  /// Hiển thị success dialog
  static Future<void> show({
    required BuildContext context,
    String title = 'Thành công',
    String message = 'Tạo nghỉ phép thành công',
    String buttonText = 'Đóng',
    VoidCallback? onClose,
    bool autoClose = false, // Mặc định không auto close
    Duration autoCloseDelay = const Duration(seconds: 2),
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Cho phép đóng bằng cách tap bên ngoài
      builder:
          (context) => SuccessDialog(
            title: title,
            message: message,
            buttonText: buttonText,
            onClose: onClose,
            autoClose: autoClose,
            autoCloseDelay: autoCloseDelay,
          ),
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  void initState() {
    super.initState();
    // Auto close sau delay nếu được bật
    if (widget.autoClose) {
      Future.delayed(widget.autoCloseDelay, () {
        // Kiểm tra widget còn mounted trước khi sử dụng Navigator
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          widget.onClose?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, minWidth: 300),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // Nền thẻ: #FFFFFF
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Shadow: 0 4px 16px rgba(0, 0, 0, 0.08)
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon success - Nền tròn: 56 × 56 px, Icon check: 24 px
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0F5E5), // Icon nền: #D0F5E5 (xanh mint nhạt)
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF0BA360), // Icon check: #0BA360 (xanh success)
                  size: 24,
                ),
              ),

              const SizedBox(height: 16), // Icon → Tiêu đề: 16 px

              // Tiêu đề "Thành công"
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18, // Font size: 18 px
                  fontWeight: FontWeight.w700, // Weight: 700
                  color: Color(0xFF0A4E75), // Color: #0A4E75 (xanh đậm)
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6), // Tiêu đề → Mô tả: 4-8 px (dùng 6)

              // Mô tả "Tạo nghỉ phép thành công"
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 14, // Font size: 14 px
                  fontWeight: FontWeight.w400, // Weight: 400
                  color: Color(0xFF6B6B6B), // Text mô tả: #6B6B6B (xám trung tính)
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24), // Mô tả → Nút: 24 px

              // Nút "Đóng" - Width: 100%, Height: 44 px, Border radius: 12 px
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                      widget.onClose?.call();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFD9D9D9), // Viền nút: #D9D9D9
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Border radius: 12 px
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(
                      const Color(0xFFF4F4F4).withOpacity(0.5), // Hover/Pressed: #F4F4F4
                    ),
                  ),
                  child: Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontSize: 16, // Font size: 16 px
                      fontWeight: FontWeight.w600, // Weight: 600
                      color: Color(0xFF555555), // Text nút: #555555
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success Dialog với backdrop overlay
class SuccessDialogWithBackdrop extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onClose;
  final bool autoClose;
  final Duration autoCloseDelay;

  const SuccessDialogWithBackdrop({
    super.key,
    this.title = 'Thành công',
    this.message = 'Tạo công việc thành công',
    this.buttonText = 'Đóng',
    this.onClose,
    this.autoClose = true,
    this.autoCloseDelay = const Duration(seconds: 2),
  });

  /// Hiển thị success dialog với backdrop
  static Future<void> show({
    required BuildContext context,
    String title = 'Thành công',
    String message = 'Tạo công việc thành công',
    String buttonText = 'Đóng',
    VoidCallback? onClose,
    bool autoClose = true,
    Duration autoCloseDelay = const Duration(seconds: 2),
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SuccessDialogWithBackdrop(
            title: title,
            message: message,
            buttonText: buttonText,
            onClose: onClose,
            autoClose: autoClose,
            autoCloseDelay: autoCloseDelay,
          ),
    );
  }

  @override
  State<SuccessDialogWithBackdrop> createState() =>
      _SuccessDialogWithBackdropState();
}

class _SuccessDialogWithBackdropState extends State<SuccessDialogWithBackdrop> {
  @override
  void initState() {
    super.initState();
    // Auto close sau delay nếu được bật
    if (widget.autoClose) {
      Future.delayed(widget.autoCloseDelay, () {
        // Kiểm tra widget còn mounted trước khi sử dụng Navigator
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          widget.onClose?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4), // Backdrop mờ nhẹ
      child: Center(
        child: Container(
          width: 280,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon trạng thái
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7EC), // Xanh lá nhạt
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF00B87C), // Xanh lá đậm
                    size: 24,
                  ),
                ),

                const SizedBox(height: 16),

                // Tiêu đề
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00695C), // Xanh đậm
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Mô tả phụ
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E), // Xám nhạt
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Nút hành động
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0), // Viền xám nhạt
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        color: Color(0xFF616161), // Text color xám
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
