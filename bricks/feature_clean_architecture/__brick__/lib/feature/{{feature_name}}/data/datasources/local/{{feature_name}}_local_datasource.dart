import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/{{feature_name}}/data/models/{{model_name}}_dto.dart';

abstract class {{feature_name.pascalCase()}}LocalDataSource {
  Future<void> save{{model_name.pascalCase()}}({{model_name.pascalCase()}}Dto item);
  Future<{{model_name.pascalCase()}}Dto?> get{{model_name.pascalCase()}}(String id);
  Future<void> clear{{model_name.pascalCase()}}(String id);
  Future<void> clearAll{{model_name.pascalCase()}}();

  Future<void> save{{model_name.pascalCase()}}List(List<{{model_name.pascalCase()}}Dto> items);
  Future<List<{{model_name.pascalCase()}}Dto>> get{{model_name.pascalCase()}}List();
  Future<void> clear{{model_name.pascalCase()}}List();

  {{#has_pagination}}
  Future<void> save{{model_name.pascalCase()}}Page(
    int page,
    List<{{model_name.pascalCase()}}Dto> items,
  );
  Future<List<{{model_name.pascalCase()}}Dto>?> get{{model_name.pascalCase()}}Page(int page);
  {{/has_pagination}}
}

class {{feature_name.pascalCase()}}LocalDataSourceImpl
    implements {{feature_name.pascalCase()}}LocalDataSource {
  static const String _boxName = '{{feature_name}}_box';
  static const String _listKey = '{{model_name}}_list';
  {{#has_pagination}}
  static const String _pagePrefix = '{{model_name}}_page_';
  {{/has_pagination}}

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> save{{model_name.pascalCase()}}({{model_name.pascalCase()}}Dto item) async {
    final box = await _ensureBox();
    await box.put('{{model_name}}_${item.id}', item.toJson());
  }

  @override
  Future<{{model_name.pascalCase()}}Dto?> get{{model_name.pascalCase()}}(String id) async {
    final box = await _ensureBox();
    final data = box.get('{{model_name}}_$id');
    if (data == null) return null;
    return {{model_name.pascalCase()}}Dto.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<void> clear{{model_name.pascalCase()}}(String id) async {
    final box = await _ensureBox();
    await box.delete('{{model_name}}_$id');
  }

  @override
  Future<void> clearAll{{model_name.pascalCase()}}() async {
    final box = await _ensureBox();
    final keys =
        box.keys.where((key) => key.toString().startsWith('{{model_name}}_')).toList();
    for (final key in keys) {
      await box.delete(key);
    }
    await box.delete(_listKey);
    {{#has_pagination}}
    final pageKeys =
        box.keys.where((key) => key.toString().startsWith(_pagePrefix)).toList();
    for (final key in pageKeys) {
      await box.delete(key);
    }
    {{/has_pagination}}
  }

  @override
  Future<void> save{{model_name.pascalCase()}}List(
    List<{{model_name.pascalCase()}}Dto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put(_listKey, listData);
    for (final item in items) {
      await box.put('{{model_name}}_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<{{model_name.pascalCase()}}Dto>> get{{model_name.pascalCase()}}List() async {
    final box = await _ensureBox();
    final listData = box.get(_listKey);
    if (listData is List) {
      return listData
          .map(
            (item) => {{model_name.pascalCase()}}Dto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<void> clear{{model_name.pascalCase()}}List() async {
    final box = await _ensureBox();
    await box.delete(_listKey);
  }

  {{#has_pagination}}
  @override
  Future<void> save{{model_name.pascalCase()}}Page(
    int page,
    List<{{model_name.pascalCase()}}Dto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put('$_pagePrefix$page', listData);
    for (final item in items) {
      await box.put('{{model_name}}_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<{{model_name.pascalCase()}}Dto>?> get{{model_name.pascalCase()}}Page(
    int page,
  ) async {
    final box = await _ensureBox();
    final listData = box.get('$_pagePrefix$page');
    if (listData is List) {
      return listData
          .map(
            (item) => {{model_name.pascalCase()}}Dto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return null;
  }
  {{/has_pagination}}
}

