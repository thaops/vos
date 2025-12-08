import 'package:vos_flutter/feature/news/domain/models/news.dart';

class NewsDto {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final String? thumbnailUrl;
  final String? image;
  final String? url;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sourceName;
  final String? sourceUrl;
  final int? totalLike;
  final int? totalViewed;
  final int? totalComment;
  final String? creator;
  final String? categoryCode;

  NewsDto({
    required this.id,
    this.title,
    this.description,
    this.content,
    this.thumbnailUrl,
    this.image,
    this.url,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.sourceName,
    this.sourceUrl,
    this.totalLike,
    this.totalViewed,
    this.totalComment,
    this.creator,
    this.categoryCode,
  });

  factory NewsDto.fromJson(Map<String, dynamic> json) {
    // Parse date từ format "24-02-2025 11:44" hoặc ISO format
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      
      // Thử parse ISO format trước
      final isoDate = DateTime.tryParse(dateStr);
      if (isoDate != null) return isoDate;
      
      // Parse format "dd-MM-yyyy HH:mm"
      try {
        final parts = dateStr.split(' ');
        if (parts.length == 2) {
          final datePart = parts[0].split('-');
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

    return NewsDto(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] as String?,
      description: json['Description'] ?? json['description'] as String?,
      content: json['Content'] ?? json['content'] as String?,
      thumbnailUrl: json['ThumbAttachmentUrl'] ?? json['thumbnailUrl'] ?? json['image'] as String?,
      image: json['ThumbAttachmentUrl'] ?? json['image'] as String?,
      url: json['url'] as String?,
      publishedAt: parseDate(json['ApprovedDate'] ?? json['CreatedDate'] ?? json['publishedAt']?.toString()),
      createdAt: parseDate(json['CreatedDate'] ?? json['createdAt']?.toString()),
      updatedAt: parseDate(json['UpdatedDate'] ?? json['updatedAt']?.toString()),
      sourceName: json['Department'] ?? json['sourceName'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      totalLike: json['TotalLike'] ?? json['totalLike'] as int?,
      totalViewed: json['TotalViewed'] ?? json['totalViewed'] as int?,
      totalComment: json['TotalComment'] ?? json['totalComment'] as int?,
      creator: json['Creator'] ?? json['creator'] as String?,
      categoryCode: json['CategoryCode'] ?? json['categoryCode'] as String?,
    );
  }

  factory NewsDto.fromDomain(News entity) {
    return NewsDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      thumbnailUrl: entity.thumbnailUrl,
      image: entity.image,
      url: entity.url,
      publishedAt: entity.publishedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      sourceName: entity.sourceName,
      sourceUrl: entity.sourceUrl,
      totalLike: entity.totalLike,
      totalViewed: entity.totalViewed,
      totalComment: entity.totalComment,
      creator: entity.creator,
      categoryCode: entity.categoryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'thumbnailUrl': thumbnailUrl,
      'image': image,
      'url': url,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'source': sourceName != null || sourceUrl != null
          ? {
              'name': sourceName,
              'url': sourceUrl,
            }
          : null,
    };
  }

  News toDomain() {
    return News(
      id: id,
      title: title,
      description: description,
      content: content,
      thumbnailUrl: thumbnailUrl,
      image: image,
      url: url,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      totalLike: totalLike,
      totalViewed: totalViewed,
      totalComment: totalComment,
      creator: creator,
      categoryCode: categoryCode,
    );
  }
}