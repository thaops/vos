import 'dart:io';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';
import 'package:vos_flutter/feature/time_off_update/domain/repositories/time_off_update_repository.dart';

class UploadFilesUsecase {
  final TimeOffUpdateRepository repository;

  UploadFilesUsecase({required this.repository});

  Future<ApiResult<List<FileAttachment>>> call(List<File> files) {
    return repository.uploadFiles(files);
  }
}

