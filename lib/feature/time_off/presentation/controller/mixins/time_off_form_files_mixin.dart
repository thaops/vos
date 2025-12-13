import 'dart:io';

import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/upload_files_usecase.dart';

mixin TimeOffFormFilesMixin on BaseController, ApiResultMixin {
  RxList<File> get attachedFiles;
  RxList<FileAttachment> get uploadedFiles;
  RxBool get isUploading;
  UploadFilesUsecase get uploadFilesUsecase;

  void onFilesSelected(List<File> files) {
    attachedFiles.addAll(files);
  }

  void removeFile(int index) {
    if (index < attachedFiles.length) {
      attachedFiles.removeAt(index);
    }
  }

  void removeUploadedFile(int index) {
    if (index < uploadedFiles.length) {
      uploadedFiles.removeAt(index);
    }
  }

  Future<void> uploadFiles() async {
    if (attachedFiles.isEmpty) return;

    isUploading.value = true;

    await handleApiCall<List<FileAttachment>>(
      apiCall: () => uploadFilesUsecase.call(attachedFiles.toList()),
      onSuccess: (data) {
        uploadedFiles.addAll(data);
        attachedFiles.clear();
      },
      onError: (error) {
        Get.snackbar(
          'Lỗi',
          'Upload file thất bại: $error',
          snackPosition: SnackPosition.TOP,
        );
      },
    );

    isUploading.value = false;
  }
}


