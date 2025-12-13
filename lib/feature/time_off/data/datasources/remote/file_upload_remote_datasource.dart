import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/core/network/api_endpoints.dart';
import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';

abstract class FileUploadRemoteDataSource {
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files);
}

class FileUploadRemoteDataSourceImpl implements FileUploadRemoteDataSource {
  @override
  Future<ApiResult<List<FileAttachment>>> uploadFiles(List<File> files) async {
    print('📤 [FileUpload] Bắt đầu upload ${files.length} file(s)');

    try {
      // Tạo FormData với multiple files
      final formData = FormData();

      for (var file in files) {
        final fileName = file.path.split('/').last;
        final fileSize = _getFileSize(file);
        print('📎 [FileUpload] Thêm file: $fileName (${fileSize})');

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      // Tạo Dio instance riêng cho upload
      final dio = Dio();

      // Set headers từ constants
      final headers = {
        'accept': '*/*',
        'X-API-KEY': ApiEndpoints.fileUploadApiKey,
        'Cookie': ApiEndpoints.fileUploadCookie,
      };

      print('🌐 [FileUpload] Gửi request đến: ${ApiEndpoints.fileUpload}');
      print(
        '🔑 [FileUpload] API Key: ${ApiEndpoints.fileUploadApiKey.substring(0, 10)}...',
      );

      // Upload
      final response = await dio.post(
        ApiEndpoints.fileUpload,
        data: formData,
        options: Options(headers: headers),
      );

      print('📥 [FileUpload] Response status: ${response.statusCode}');
      print('📥 [FileUpload] Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Parse response mới: {StatusCode, Message, TotalRecord, Data: [urls]}
        final responseData = response.data is String
            ? json.decode(response.data)
            : response.data;

        print('📋 [FileUpload] Parsed response: $responseData');

        if (responseData is Map<String, dynamic>) {
          final statusCode = responseData['StatusCode'] as int?;
          final message = responseData['Message'] as String?;
          final totalRecord = responseData['TotalRecord'] as int?;
          final dataList = responseData['Data'] as List<dynamic>?;

          print('📊 [FileUpload] StatusCode: $statusCode');
          print('📊 [FileUpload] Message: $message');
          print('📊 [FileUpload] TotalRecord: $totalRecord');
          print('📊 [FileUpload] Data length: ${dataList?.length ?? 0}');

          if (statusCode == 200 && dataList != null) {
            print('✅ [FileUpload] Upload thành công, bắt đầu parse URLs...');

            // Data là array of URLs
            // Tạo FileAttachment từ URLs và file names
            final attachments = <FileAttachment>[];

            for (int i = 0; i < dataList.length && i < files.length; i++) {
              final url = dataList[i] as String;
              final file = files[i];
              final fileName = file.path.split('/').last;
              final fileSize = _getFileSize(file);

              print('🔗 [FileUpload] File $i: $fileName');
              print('   URL: $url');

              // Extract file extension để check image
              final ext = fileName.toLowerCase();
              final isImage =
                  ext.endsWith('.jpg') ||
                  ext.endsWith('.jpeg') ||
                  ext.endsWith('.png') ||
                  ext.endsWith('.gif') ||
                  ext.endsWith('.webp');

              attachments.add(
                FileAttachment(
                  fileName: fileName,
                  fileUrl: url,
                  fileSize: fileSize,
                  width: isImage ? '' : '',
                  height: isImage ? '' : '',
                  requestNumber: '',
                  uploadBy: '',
                ),
              );
            }

            print(
              '✅ [FileUpload] Tạo thành công ${attachments.length} FileAttachment(s)',
            );
            return ApiResult.success(attachments);
          } else {
            print(
              '❌ [FileUpload] Upload thất bại: StatusCode=$statusCode, Message=$message',
            );
            return ApiResult.error(
              message ?? 'Upload failed: StatusCode $statusCode',
            );
          }
        } else {
          print(
            '❌ [FileUpload] Invalid response format: ${responseData.runtimeType}',
          );
          return ApiResult.error('Invalid response format');
        }
      } else {
        print(
          '❌ [FileUpload] HTTP Error: ${response.statusCode} - ${response.statusMessage}',
        );
        return ApiResult.error('Upload failed: ${response.statusMessage}');
      }
    } catch (e, stackTrace) {
      print('❌ [FileUpload] Exception: $e');
      print('❌ [FileUpload] StackTrace: $stackTrace');
      return ApiResult.error('Upload error: $e');
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
