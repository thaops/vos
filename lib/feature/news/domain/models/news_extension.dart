import 'package:vos_flutter/feature/news/domain/models/news.dart';
import 'package:vos_flutter/feature/news_v2/models/news_item_model.dart';

extension NewsToNewsItemModel on News {
  NewsItemModel toNewsItemModel() {
    return NewsItemModel(
      id: id,
      title: title ?? 'Untitled',
      bannerImageUrl: image ?? thumbnailUrl ?? '',
      publishDate: publishedAt ?? createdAt ?? DateTime.now(),
      viewCount: totalViewed ?? 0,
      likeCount: totalLike ?? 0,
      commentCount: totalComment ?? 0,
      content: content,
      author: creator ?? sourceName,
    );
  }
}

