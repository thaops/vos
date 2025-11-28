import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/controller/time_off_create_controller.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/widgets/time_off_create_colors.dart';

class FileAttachmentWidget extends GetView<TimeOffCreateController> {
  const FileAttachmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Đính kèm file',
          fontSize: 14,
          color: TimeOffCreateColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.onFileAttached('file_path_example'),
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
              ],
            ),
          ),
        ),
        Obx(
          () => controller.attachedFiles.isEmpty
              ? const SizedBox()
              : Column(
                  children: List.generate(
                    controller.attachedFiles.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(top: 8),
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
                            Icons.attach_file,
                            size: 20,
                            color: TimeOffCreateColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextWidget(
                              text: controller.attachedFiles[index],
                              fontSize: 14,
                              color: TimeOffCreateColors.textPrimary,
                              fontWeight: FontWeight.w400,
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
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

