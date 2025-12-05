import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              fontWeight: FontWeight.w500,
            ),
            Obx(
              () => controller.attachedFiles.isNotEmpty
                  ? CustomButton(
                      text: 'Upload',
                      height: 32,
                      fontSize: 12,
                      isLoading: controller.isUploading.value,
                      onPressed: controller.uploadFiles,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: TimeOffCreateColors.fileBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: TimeOffCreateColors.fileBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: TimeOffCreateColors.primary,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: 'Nhấn để chọn file đính kèm',
                  fontSize: 12,
                  color: TimeOffCreateColors.textPlaceholder,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text: 'Hỗ trợ: JPG, PNG, PDF, DOC, DOCX',
                  fontSize: 10,
                  color: TimeOffCreateColors.textPlaceholder,
                  fontWeight: FontWeight.w400,
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
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Chưa upload (${controller.attachedFiles.length})',
                      fontSize: 12,
                      color: TimeOffCreateColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      controller.attachedFiles.length,
                      (index) {
                        final file = controller.attachedFiles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TimeOffCreateColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: TimeOffCreateColors.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 20,
                                color: TimeOffCreateColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: _getFileName(file),
                                      fontSize: 14,
                                      color: TimeOffCreateColors.textPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    TextWidget(
                                      text: _getFileSize(file),
                                      fontSize: 12,
                                      color: TimeOffCreateColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.removeFile(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: TimeOffCreateColors.textPlaceholder,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
                    const SizedBox(height: 12),
                    TextWidget(
                      text: 'Đã upload (${controller.uploadedFiles.length})',
                      fontSize: 12,
                      color: TimeOffCreateColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      controller.uploadedFiles.length,
                      (index) {
                        final file = controller.uploadedFiles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TimeOffCreateColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: TimeOffCreateColors.success,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                file.isImage
                                    ? Icons.image
                                    : Icons.insert_drive_file,
                                size: 20,
                                color: TimeOffCreateColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: file.fileName,
                                      fontSize: 14,
                                      color: TimeOffCreateColors.textPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    TextWidget(
                                      text: file.fileSize,
                                      fontSize: 12,
                                      color: TimeOffCreateColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeUploadedFile(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: TimeOffCreateColors.textPlaceholder,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

