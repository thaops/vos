import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/news_detail/data/models/news_detail_dto.dart';

abstract class NewsDetailLocalDataSource {
  Future<void> saveNewsDetail(NewsDetailDto item);
  Future<NewsDetailDto?> getNewsDetail(String id);
  Future<void> clearNewsDetail(String id);
  Future<void> clearAllNewsDetail();

  Future<void> saveNewsDetailList(List<NewsDetailDto> items);
  Future<List<NewsDetailDto>> getNewsDetailList();
  Future<void> clearNewsDetailList();

  
}

class NewsDetailLocalDataSourceImpl
    implements NewsDetailLocalDataSource {
  static const String _boxName = 'news_detail_box';
  static const String _listKey = 'news_detail_list';
  

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> saveNewsDetail(NewsDetailDto item) async {
    final box = await _ensureBox();
    await box.put('news_detail_${item.id}', item.toJson());
  }

  @override
  Future<NewsDetailDto?> getNewsDetail(String id) async {
    final box = await _ensureBox();
    final data = box.get('news_detail_$id');
    if (data == null) return null;
    return NewsDetailDto.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<void> clearNewsDetail(String id) async {
    final box = await _ensureBox();
    await box.delete('news_detail_$id');
  }

  @override
  Future<void> clearAllNewsDetail() async {
    final box = await _ensureBox();
    final keys =
        box.keys.where((key) => key.toString().startsWith('news_detail_')).toList();
    for (final key in keys) {
      await box.delete(key);
    }
    await box.delete(_listKey);
    
  }

  @override
  Future<void> saveNewsDetailList(
    List<NewsDetailDto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put(_listKey, listData);
    for (final item in items) {
      await box.put('news_detail_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<NewsDetailDto>> getNewsDetailList() async {
    final box = await _ensureBox();
    final listData = box.get(_listKey);
    if (listData is List) {
      return listData
          .map(
            (item) => NewsDetailDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<void> clearNewsDetailList() async {
    final box = await _ensureBox();
    await box.delete(_listKey);
  }

  
}

