import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

class NewsDetailDto {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? totalViewed;
  final int? totalLike;
  final int? totalComment;
  final bool? isLiked;

  NewsDetailDto({
    required this.id,
    this.title,
    this.description,
    this.content,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
    this.totalViewed,
    this.totalLike,
    this.totalComment,
    this.isLiked,
  });

  factory NewsDetailDto.fromJson(Map<String, dynamic> json) {
    // Parse date từ format "24/02/2025 11:44" hoặc ISO format
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;

      // Thử parse ISO format trước
      final isoDate = DateTime.tryParse(dateStr);
      if (isoDate != null) return isoDate;

      // Parse format "dd/MM/yyyy HH:mm"
      try {
        final parts = dateStr.split(' ');
        if (parts.length == 2) {
          final datePart = parts[0].split('/');
          final timePart = parts[1].split(':');
          if (datePart.length == 3 && timePart.length == 2) {
            return DateTime(
              int.parse(datePart[2]),
              int.parse(datePart[1]),
              int.parse(datePart[0]),
              int.parse(timePart[0]),
              int.parse(timePart[1]),
            );
          }
        }
      } catch (e) {
        // Ignore parse errors
      }
      return null;
    }

    return NewsDetailDto(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] as String?,
      description: json['Description'] ?? json['description'] as String?,
      content: json['Content'] ?? json['content'] as String?,
      thumbnailUrl:
          json['ThumbAttachmentUrl'] ?? json['thumbnailUrl'] as String?,
      createdAt: parseDate(
        json['CreatedDate'] ?? json['createdAt']?.toString(),
      ),
      updatedAt: parseDate(
        json['UpdatedDate'] ?? json['updatedAt']?.toString(),
      ),
      totalViewed: json['TotalViewed'] ?? json['totalViewed'] as int?,
      totalLike: json['TotalLike'] ?? json['totalLike'] as int?,
      totalComment: json['TotalComment'] ?? json['totalComment'] as int?,
      isLiked: json['IsLiked'] ?? json['isLiked'] as bool?,
    );
  }

  factory NewsDetailDto.fromDomain(NewsDetail entity) {
    return NewsDetailDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      thumbnailUrl: entity.thumbnailUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      totalViewed: entity.totalViewed,
      totalLike: entity.totalLike,
      totalComment: entity.totalComment,
      isLiked: entity.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  NewsDetail toDomain() {
    return NewsDetail(
      id: id,
      title: title,
      description: description,
      content: content,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalViewed: totalViewed,
      totalLike: totalLike,
      totalComment: totalComment,
      isLiked: isLiked,
    );
  }
}
