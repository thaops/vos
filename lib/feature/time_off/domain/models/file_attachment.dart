class FileAttachment {
  final String fileName;
  final String fileUrl;
  final String fileSize;
  final String width;
  final String height;
  final String requestNumber;
  final String uploadBy;

  const FileAttachment({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    this.width = '',
    this.height = '',
    required this.requestNumber,
    required this.uploadBy,
  });

  FileAttachment copyWith({
    String? fileName,
    String? fileUrl,
    String? fileSize,
    String? width,
    String? height,
    String? requestNumber,
    String? uploadBy,
  }) {
    return FileAttachment(
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      requestNumber: requestNumber ?? this.requestNumber,
      uploadBy: uploadBy ?? this.uploadBy,
    );
  }

  // Check if this is an image
  bool get isImage {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }
}

