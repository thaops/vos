import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vos_flutter/common/widgets/text_widget.dart';
import 'package:vos_flutter/feature/time_off_create/domain/models/file_attachment.dart';

class FileAttachmentsSection extends StatelessWidget {
  final List<FileAttachment> attachments;

  const FileAttachmentsSection({super.key, required this.attachments});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'File đính kèm (${attachments.length})',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        SizedBox(height: 12.h),
        ...attachments.map((file) => _buildFileItem(file)),
      ],
    );
  }

  Widget _buildFileItem(FileAttachment file) {
    final isImage = file.isImage;

    return GestureDetector(
      onTap: () => _openFile(file.fileUrl),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Icon hoặc thumbnail
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  size: 32.sp,
                  color: Colors.blue.shade700,
                ),
              ),
            SizedBox(width: 12.w),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  TextWidget(
                    text: file.fileSize,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  if (file.uploadBy.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    TextWidget(
                      text: 'Bởi: ${file.uploadBy}',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.download, size: 20.sp, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
}
