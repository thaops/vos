class NewsDetailArgs {
  final String? id;
  final String? url;
  final String? title;

  NewsDetailArgs({
    this.id,
    this.url,
    this.title,
  });

  // Helper để check xem có phải WEB type không
  bool get isWebType => url != null && url!.isNotEmpty;
  
  // Helper để check xem có phải APP type không
  bool get isAppType => id != null && id!.isNotEmpty;
}

