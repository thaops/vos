import 'package:vos_flutter/feature/time_off/domain/models/file_attachment.dart';

class FileAttachmentDto {
  final String fileName;
  final String fileUrl;
  final String fileSize;
  final String width;
  final String height;
  final String requestNumber;
  final String uploadBy;

  FileAttachmentDto({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.width = '',
    this.height = '',
    required this.requestNumber,
    required this.uploadBy,
  });

  factory FileAttachmentDto.fromJson(Map<String, dynamic> json) {
    return FileAttachmentDto(
      fileName: json['FileName'] as String? ?? '',
      fileUrl: json['FileUrl'] as String? ?? '',
      fileSize: json['FileSize'] as String? ?? '',
      width: json['Width'] as String? ?? '',
      height: json['Height'] as String? ?? '',
      requestNumber: json['RequestNumber'] as String? ?? '',
      uploadBy: json['UploadBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FileName': fileName,
      'FileUrl': fileUrl,
      'FileSize': fileSize,
      'Width': width,
      'Height': height,
      'RequestNumber': requestNumber,
      'UploadBy': uploadBy,
    };
  }

  FileAttachment toDomain() {
    return FileAttachment(
      fileName: fileName,
      fileUrl: fileUrl,
      fileSize: fileSize,
      width: width,
      height: height,
      requestNumber: requestNumber,
      uploadBy: uploadBy,
    );
  }

  factory FileAttachmentDto.fromDomain(FileAttachment file) {
    return FileAttachmentDto(
      fileName: file.fileName,
      fileUrl: file.fileUrl,
      fileSize: file.fileSize,
      width: file.width,
      height: file.height,
      requestNumber: file.requestNumber,
      uploadBy: file.uploadBy,
    );
  }
}

