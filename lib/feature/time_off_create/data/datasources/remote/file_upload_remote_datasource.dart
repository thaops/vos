import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/time_off_create/data/models/file_attachment_dto.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';

abstract class FileUploadRemoteDataSource {
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files);
}

class FileUploadRemoteDataSourceImpl implements FileUploadRemoteDataSource {
  static const String _apiKey =
      '8492f144615571ac043b943e58471ba3bc37d7a59d065b1e6ff2d0106c1a1dc2';
  static const String _uploadUrl =
      'https://viagsapi-eoffice-dev.azurewebsites.net/api/vos/upload-multiple-file';

  @override
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files) async {
    try {
      // Tạo FormData với multiple files
      final formData = FormData();
      
      for (var file in files) {
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
            ),
          ),
        );
      }

      // Tạo Dio instance riêng cho upload
      final dio = Dio();
      
      // Set headers
      final headers = {
        'accept': '*/*',
        'X-API-KEY': _apiKey,
        'Cookie':
            'ARRAffinity=a6e48b9e9d2653435be7b61998d8624b44115214104213d6c8b8c526cc56dc70; ARRAffinitySameSite=a6e48b9e9d2653435be7b61998d8624b44115214104213d6c8b8c526cc56dc70',
      };

      // Upload
      final response = await dio.post(
        _uploadUrl,
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Parse response
        final List<dynamic> data = response.data is String
            ? json.decode(response.data)
            : response.data;
        
        final attachments = data
            .map((item) => FileAttachmentDto.fromJson(item).toDomain())
            .toList();
        
        return ApiResult.success(attachments);
      } else {
        return ApiResult.error(
          'Upload failed: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return ApiResult.error('Upload error: $e');
    }
  }
}

