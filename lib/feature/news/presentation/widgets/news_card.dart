import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vos_flutter/feature/news/data/models/news_item_model.dart';

class NewsCard extends StatelessWidget {
  final NewsItemModel newsItem;
  final VoidCallback? onTap;
  final bool isCompact;

  const NewsCard({
    super.key,
    required this.newsItem,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final marginH = isCompact ? 8.0 : 16.0;
    final marginV = isCompact ? 6.0 : 8.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildBannerImage(), _buildTitle(), _buildMetadataBar()],
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    final hasImage = newsItem.bannerImageUrl.isNotEmpty;
    final imageHeight = isCompact ? 140.0 : 180.0;

    return Container(
      width: double.infinity,
      height: imageHeight,

      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: hasImage
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFDD835), Color(0xFF135769), Colors.white],
              ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: newsItem.bannerImageUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,

                // ⚡ TỐI ƯU QUAN TRỌNG
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                memCacheHeight: 400, // tránh load ảnh 4K
                maxHeightDiskCache: 400,
                placeholder: (_, __) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) =>
                    _buildDefaultLogos(), // fallback
              )
            : _buildDefaultLogos(),
      ),
    );
  }

  Widget _buildDefaultLogos() {
    return Stack(
      children: [
        // Logo VIAGS góc trên phải
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'VIAGS',
              style: TextStyle(
                color: Color(0xFF135769),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        // Logo Công đoàn ở giữa phía trên
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'CÔNG ĐOÀN',
                style: TextStyle(
                  color: Color(0xFF135769),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    final padding = isCompact ? 12.0 : 16.0;
    final titleSize = isCompact ? 15.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        newsItem.title.toUpperCase(),
        style: TextStyle(
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMetadataBar() {
    final paddingH = isCompact ? 12.0 : 16.0;
    final paddingB = isCompact ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(paddingH, 0, paddingH, paddingB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            newsItem.formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionIcon(IconData icon, int? count) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.8)),
  //       if (count != null) ...[
  //         const SizedBox(width: 4),
  //         Text(
  //           _formatCount(count),
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: AppColors.primary.withOpacity(0.8),
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ],
  //   );
  // }
}
