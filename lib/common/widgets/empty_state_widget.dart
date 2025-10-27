import 'package:flutter/material.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

/// Widget hiển thị trạng thái rỗng có thể tái sử dụng
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon = Icons.data_usage_outlined,
    this.title = 'Không có dữ liệu',
    this.subtitle,
    this.iconSize = 20,
    this.titleFontSize = 12,
    this.subtitleFontSize = 10,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.padding = const EdgeInsets.all(8),
    this.spacing = 8,
    this.onTap,
  });

  /// Icon hiển thị
  final IconData icon;

  /// Tiêu đề chính
  final String title;

  /// Phụ đề (optional)
  final String? subtitle;

  /// Kích thước icon
  final double iconSize;

  /// Kích thước font tiêu đề
  final double titleFontSize;

  /// Kích thước font phụ đề
  final double subtitleFontSize;

  /// Màu icon
  final Color? iconColor;

  /// Màu tiêu đề
  final Color? titleColor;

  /// Màu phụ đề
  final Color? subtitleColor;

  /// Padding xung quanh widget
  final EdgeInsets padding;

  /// Khoảng cách giữa các elements
  final double spacing;

  /// Callback khi tap vào widget
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.textSecondary,
              size: iconSize,
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: TextStyle(
                color: titleColor ?? const Color(0xFF666666),
                fontSize: titleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: spacing / 2),
              Text(
                subtitle!,
                style: TextStyle(
                  color: subtitleColor ?? const Color(0xFF999999),
                  fontSize: subtitleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

/// Predefined empty states cho các trường hợp phổ biến
class EmptyStatePresets {
  /// Empty state cho danh sách người thực hiện
  static Widget assigneeEmpty({VoidCallback? onTap}) {
    return EmptyStateWidget(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Chọn người thực hiện',
      iconColor: AppColors.textSecondary,
      onTap: onTap,
    );
  }

  /// Empty state cho danh sách chung
  static Widget listEmpty({
    String title = 'Không có dữ liệu',
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return EmptyStateWidget(
      icon: Icons.data_usage_outlined,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  /// Empty state cho tìm kiếm
  static Widget searchEmpty({
    String title = 'Không tìm thấy kết quả',
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: title,
      subtitle: subtitle,
    );
  }

  /// Empty state cho lỗi
  static Widget errorEmpty({
    String title = 'Có lỗi xảy ra',
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: title,
      subtitle: subtitle,
      iconColor: Colors.red,
      onTap: onRetry,
    );
  }
}
