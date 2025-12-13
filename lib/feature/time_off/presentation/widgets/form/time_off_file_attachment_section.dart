import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/common/widgets/custom_button.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class TimeOffFileAttachmentSection extends StatelessWidget {
  final RxList<File> attachedFiles;
  final RxList<FileAttachment> uploadedFiles;
  final RxBool isUploading;

  final void Function(List<File> files) onFilesSelected;
  final VoidCallback onUploadAll;
  final void Function(int index) onRemoveLocalFile;
  final void Function(int index) onRemoveUploadedFile;

  final bool enableOpenUploaded;

  const TimeOffFileAttachmentSection({
    super.key,
    required this.attachedFiles,
    required this.uploadedFiles,
    required this.isUploading,
    required this.onFilesSelected,
    required this.onUploadAll,
    required this.onRemoveLocalFile,
    required this.onRemoveUploadedFile,
    this.enableOpenUploaded = true,
  });

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );
      if (result == null) return;

      final files = result.paths.whereType<String>().map((p) => File(p)).toList();
      onFilesSelected(files);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể chọn file: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _getFileName(File file) => file.path.split('/').last;

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
              fontWeight: FontWeight.w600,
            ),
            Obx(
              () => attachedFiles.isNotEmpty
                  ? CustomButton(
                      text: 'Upload tất cả',
                      height: 36,
                      fontSize: 13,
                      isLoading: isUploading.value,
                      onPressed: onUploadAll,
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
                const Icon(
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
                      SizedBox(height: 2),
                      TextWidget(
                        text: 'JPG, PNG, PDF, DOC, DOCX',
                        fontSize: 11,
                        color: TimeOffCreateColors.textPlaceholder,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                const Icon(
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
          () => attachedFiles.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    ...List.generate(attachedFiles.length, (index) {
                      final file = attachedFiles[index];
                      return _LocalFileRow(
                        fileName: _getFileName(file),
                        fileSize: _getFileSize(file),
                        onRemove: () => onRemoveLocalFile(index),
                      );
                    }),
                  ],
                ),
        ),

        // Uploaded files
        Obx(
          () => uploadedFiles.isEmpty
              ? const SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    ...List.generate(uploadedFiles.length, (index) {
                      final file = uploadedFiles[index];
                      return _UploadedFileRow(
                        file: file,
                        enableOpen: enableOpenUploaded,
                        onOpen: () => _openFile(file.fileUrl),
                        onRemove: () => onRemoveUploadedFile(index),
                      );
                    }),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LocalFileRow extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final VoidCallback onRemove;

  const _LocalFileRow({
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
              color: TimeOffCreateColors.primary.withOpacity(0.1),
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
                  text: fileName,
                  fontSize: 14,
                  color: TimeOffCreateColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: TimeOffCreateColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    TextWidget(
                      text: fileSize,
                      fontSize: 12,
                      color: TimeOffCreateColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
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
    );
  }
}

class _UploadedFileRow extends StatelessWidget {
  final FileAttachment file;
  final bool enableOpen;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _UploadedFileRow({
    required this.file,
    required this.enableOpen,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
          if (file.isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: file.fileUrl,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TimeOffCreateColors.primary.withOpacity(0.1),
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
                  text: file.fileName,
                  fontSize: 14,
                  color: TimeOffCreateColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: TimeOffCreateColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    TextWidget(
                      text: file.fileSize,
                      fontSize: 12,
                      color: TimeOffCreateColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    if (file.uploadBy.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: TimeOffCreateColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: file.uploadBy,
                        fontSize: 11,
                        color: TimeOffCreateColors.textSecondary,
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
            onTap: onRemove,
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
    );

    if (!enableOpen) return content;
    return GestureDetector(onTap: onOpen, child: content);
  }
}


