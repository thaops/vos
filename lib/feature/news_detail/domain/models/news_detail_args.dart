class NewsDetailArgs {
  final String? id;
  final String? url;
  final String? title;
  final String? categoryCode;

  NewsDetailArgs({
    this.id,
    this.url,
    this.title,
    this.categoryCode,
  });

  // Helper để check xem có phải WEB type không
  bool get isWebType => url != null && url!.isNotEmpty;
  
  // Helper để check xem có phải APP type không
  bool get isAppType => id != null && id!.isNotEmpty;
}

