import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/controller/time_off_update_controller.dart';

class FileAttachmentWidget extends GetView<TimeOffUpdateController> {
  const FileAttachmentWidget({super.key});

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        final files = result.paths.map((path) => File(path!)).toList();
        controller.onFilesSelected(files);
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể chọn file: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              text: 'Đính kèm file',
              fontSize: 14,
              color: TimeOffCreateColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            Obx(
              () => controller.attachedFiles.isNotEmpty
                  ? CustomButton(
                      text: 'Upload tất cả',
                      height: 36,
                      fontSize: 13,
                      isLoading: controller.isUploading.value,
                      onPressed: controller.uploadFiles,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: TimeOffCreateColors.fileBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TimeOffCreateColors.fileBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20,
                  color: TimeOffCreateColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Nhấn để chọn file đính kèm',
                        fontSize: 14,
                        color: TimeOffCreateColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 2),
                      TextWidget(
                        text: 'JPG, PNG, PDF, DOC, DOCX',
                        fontSize: 11,
                        color: TimeOffCreateColors.textPlaceholder,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: TimeOffCreateColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Local files (chưa upload)
        Obx(
          () => controller.attachedFiles.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    ...List.generate(controller.attachedFiles.length, (index) {
                      final file = controller.attachedFiles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: TimeOffCreateColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: TimeOffCreateColors.borderColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: TimeOffCreateColors.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.insert_drive_file,
                                size: 24,
                                color: TimeOffCreateColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: _getFileName(file),
                                    fontSize: 14,
                                    color: TimeOffCreateColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 12,
                                        color:
                                            TimeOffCreateColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      TextWidget(
                                        text: _getFileSize(file),
                                        fontSize: 12,
                                        color:
                                            TimeOffCreateColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
        ),
        // Uploaded files
        Obx(
          () => controller.uploadedFiles.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    ...List.generate(controller.uploadedFiles.length, (index) {
                      final file = controller.uploadedFiles[index];
                      return GestureDetector(
                        onTap: () => _openFile(file.fileUrl),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TimeOffCreateColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: TimeOffCreateColors.borderColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Thumbnail cho ảnh hoặc icon cho file
                              if (file.isImage)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: CachedNetworkImage(
                                    imageUrl: file.fileUrl,
                                    width: 60.w,
                                    height: 60.w,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 60.w,
                                      height: 60.w,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          width: 60.w,
                                          height: 60.w,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: TimeOffCreateColors.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.insert_drive_file,
                                    size: 24,
                                    color: TimeOffCreateColors.primary,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: file.fileName,
                                      fontSize: 14,
                                      color: TimeOffCreateColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 12,
                                          color:
                                              TimeOffCreateColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        TextWidget(
                                          text: file.fileSize,
                                          fontSize: 12,
                                          color:
                                              TimeOffCreateColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        if (file.uploadBy.isNotEmpty) ...[
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.person_outline,
                                            size: 12,
                                            color: TimeOffCreateColors
                                                .textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          TextWidget(
                                            text: file.uploadBy,
                                            fontSize: 11,
                                            color: TimeOffCreateColors
                                                .textSecondary,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeUploadedFile(index),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }
}
