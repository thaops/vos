import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/news/data/models/news_dto.dart';

abstract class NewsLocalDataSource {
  Future<void> saveNews(NewsDto item);
  Future<NewsDto?> getNews(String id);
  Future<void> clearNews(String id);
  Future<void> clearAllNews();

  Future<void> saveNewsList(List<NewsDto> items);
  Future<List<NewsDto>> getNewsList();
  Future<void> clearNewsList();

  
  Future<void> saveNewsPage(
    int page,
    List<NewsDto> items,
  );
  Future<List<NewsDto>?> getNewsPage(int page);
  
}

class NewsLocalDataSourceImpl
    implements NewsLocalDataSource {
  static const String _boxName = 'news_box';
  static const String _listKey = 'news_list';
  
  static const String _pagePrefix = 'news_page_';
  

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> saveNews(NewsDto item) async {
    final box = await _ensureBox();
    await box.put('news_${item.id}', item.toJson());
  }

  @override
  Future<NewsDto?> getNews(String id) async {
    final box = await _ensureBox();
    final data = box.get('news_$id');
    if (data == null) return null;
    return NewsDto.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<void> clearNews(String id) async {
    final box = await _ensureBox();
    await box.delete('news_$id');
  }

  @override
  Future<void> clearAllNews() async {
    final box = await _ensureBox();
    final keys =
        box.keys.where((key) => key.toString().startsWith('news_')).toList();
    for (final key in keys) {
      await box.delete(key);
    }
    await box.delete(_listKey);
    
    final pageKeys =
        box.keys.where((key) => key.toString().startsWith(_pagePrefix)).toList();
    for (final key in pageKeys) {
      await box.delete(key);
    }
    
  }

  @override
  Future<void> saveNewsList(
    List<NewsDto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put(_listKey, listData);
    for (final item in items) {
      await box.put('news_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<NewsDto>> getNewsList() async {
    final box = await _ensureBox();
    final listData = box.get(_listKey);
    if (listData is List) {
      return listData
          .map(
            (item) => NewsDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<void> clearNewsList() async {
    final box = await _ensureBox();
    await box.delete(_listKey);
  }

  
  @override
  Future<void> saveNewsPage(
    int page,
    List<NewsDto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put('$_pagePrefix$page', listData);
    for (final item in items) {
      await box.put('news_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<NewsDto>?> getNewsPage(
    int page,
  ) async {
    final box = await _ensureBox();
    final listData = box.get('$_pagePrefix$page');
    if (listData is List) {
      return listData
          .map(
            (item) => NewsDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return null;
  }
  
}

