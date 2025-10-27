import 'package:flutter/material.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

/// Utility class cho các function liên quan đến Task
class TaskUtils {
  /// Format date string thành định dạng dd/MM/yyyy
  static String formatTaskDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Lấy màu cho status của task
  static Color getStatusColor(String status) {
    // Xử lý cả số và string
    if (RegExp(r'^\d+$').hasMatch(status)) {
      switch (int.parse(status)) {
        case 1:
          return AppColors.statusInProgress; // Đang thực hiện
        case 2:
          return AppColors.statusCompleted; // Hoàn thành
        case 3:
          return AppColors.statusOverdue; // Quá hạn
        default:
          return AppColors.statusInProgress;
      }
    }

    // Xử lý theo string
    switch (status.toLowerCase()) {
      case 'completed':
      case 'hoàn thành':
      case 'done':
        return AppColors.statusCompleted;
      case 'overdue':
      case 'trễ hạn':
      case 'quá hạn':
        return AppColors.statusOverdue;
      case 'in progress':
      case 'đang thực hiện':
      case 'in-progress':
      case 'doing':
        return AppColors.statusInProgress;
      default:
        return AppColors.statusInProgress;
    }
  }

  /// Lấy màu cho priority của task
  static Color getPriorityColor(String priority) {
    // Xử lý cả số và string
    if (RegExp(r'^\d+$').hasMatch(priority)) {
      switch (int.parse(priority)) {
        case 0:
          return AppColors.priorityCritical; // Khẩn cấp
        case 1:
          return AppColors.priorityHigh; // Ưu tiên cao
        case 2:
          return AppColors.priorityMedium; // Trung bình
        case 3:
          return AppColors.priorityNormal; // Bình thường
        case 4:
          return AppColors.priorityLow; // Thấp
        case 5:
          return AppColors.priorityCritical; // Khẩn cấp
        default:
          return AppColors.priorityNormal;
      }
    }

    // Xử lý theo string
    switch (priority.toLowerCase()) {
      case 'critical':
      case 'khẩn cấp':
      case 'urgent':
        return AppColors.priorityCritical;
      case 'high':
      case 'ưu tiên cao':
      case 'cao':
        return AppColors.priorityHigh;
      case 'medium':
      case 'trung bình':
      case 'trung':
        return AppColors.priorityMedium;
      case 'normal':
      case 'bình thường':
      case 'thường':
        return AppColors.priorityNormal;
      case 'low':
      case 'thấp':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityNormal;
    }
  }

  /// Lấy màu text dựa trên label (status/priority)
  static Color getTextColor(String label) {
    final lowerLabel = label.toLowerCase();

    // Status colors
    if (lowerLabel.contains('hoàn thành') ||
        lowerLabel.contains('completed') ||
        lowerLabel.contains('done')) {
      return AppColors.textCompleted;
    } else if (lowerLabel.contains('trễ hạn') ||
        lowerLabel.contains('overdue') ||
        lowerLabel.contains('quá hạn')) {
      return AppColors.textOverdue;
    } else if (lowerLabel.contains('đang thực hiện') ||
        lowerLabel.contains('in progress') ||
        lowerLabel.contains('doing')) {
      return AppColors.textInProgress;
    }
    // Priority colors
    else if (lowerLabel.contains('khẩn cấp') ||
        lowerLabel.contains('critical') ||
        lowerLabel.contains('urgent')) {
      return AppColors.textCritical;
    } else if (lowerLabel.contains('cao') || lowerLabel.contains('high')) {
      return AppColors.textHigh;
    } else if (lowerLabel.contains('trung bình') ||
        lowerLabel.contains('medium') ||
        lowerLabel.contains('trung')) {
      return AppColors.textMedium;
    } else if (lowerLabel.contains('bình thường') ||
        lowerLabel.contains('normal') ||
        lowerLabel.contains('thường')) {
      return AppColors.textNormal;
    } else if (lowerLabel.contains('thấp') || lowerLabel.contains('low')) {
      return AppColors.textLow;
    }

    return AppColors.textInProgress;
  }

  /// Lấy màu background cho status của task
  static Color getStatusBackgroundColor(String status) {
    // Xử lý cả số và string
    if (RegExp(r'^\d+$').hasMatch(status)) {
      switch (int.parse(status)) {
        case 1:
          return AppColors.statusInProgressBg; // Đang thực hiện
        case 2:
          return AppColors.statusCompletedBg; // Hoàn thành
        case 3:
          return AppColors.statusOverdueBg; // Quá hạn
        default:
          return AppColors.statusInProgressBg;
      }
    }

    // Xử lý theo string
    switch (status.toLowerCase()) {
      case 'completed':
      case 'hoàn thành':
      case 'done':
        return AppColors.statusCompletedBg;
      case 'overdue':
      case 'trễ hạn':
      case 'quá hạn':
        return AppColors.statusOverdueBg;
      case 'in progress':
      case 'đang thực hiện':
      case 'in-progress':
      case 'doing':
        return AppColors.statusInProgressBg;
      default:
        return AppColors.statusInProgressBg;
    }
  }

  /// Lấy màu background cho priority của task
  static Color getPriorityBackgroundColor(String priority) {
    // Xử lý cả số và string
    final lowerPriority = priority.toLowerCase();

    // Xử lý theo số (dựa vào dữ liệu thực tế từ API)
    if (RegExp(r'^\d+$').hasMatch(priority)) {
      switch (int.parse(priority)) {
        case 0:
          return AppColors.priorityCriticalBg; // Khẩn cấp
        case 1:
          return AppColors.priorityHighBg; // Ưu tiên cao
        case 2:
          return AppColors.priorityMediumBg; // Trung bình
        case 3:
          return AppColors.priorityNormalBg; // Bình thường
        case 4:
          return AppColors.priorityLowBg; // Thấp
        case 5:
          return AppColors.priorityCriticalBg; // Khẩn cấp
        default:
          return AppColors.priorityNormalBg;
      }
    }

    // Xử lý theo string
    switch (lowerPriority) {
      case 'critical':
      case 'khẩn cấp':
      case 'urgent':
        return AppColors.priorityCriticalBg;
      case 'high':
      case 'cao':
        return AppColors.priorityHighBg;
      case 'medium':
      case 'trung bình':
      case 'trung':
        return AppColors.priorityMediumBg;
      case 'normal':
      case 'bình thường':
      case 'thường':
        return AppColors.priorityNormalBg;
      case 'low':
      case 'thấp':
        return AppColors.priorityLowBg;
      default:
        return AppColors.priorityNormalBg;
    }
  }
}
